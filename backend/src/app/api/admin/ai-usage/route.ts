import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { AIUsageLog } from '@/models/AIUsageLog'
import { User } from '@/models/User'
import { withRole, ok, err } from '@/lib/middleware'

export const GET = withRole('admin')(async (req: NextRequest) => {
  try {
    await connectDB()
    const { searchParams } = new URL(req.url)
    const days = parseInt(searchParams.get('days') || '14')
    const since = new Date()
    since.setDate(since.getDate() - days)

    const today = new Date()
    today.setHours(0, 0, 0, 0)

    // Daily aggregation bucketed by date
    const dailyRaw = await AIUsageLog.aggregate([
      { $match: { createdAt: { $gte: since } } },
      {
        $group: {
          _id: {
            date: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
            feature: '$feature',
          },
          tokens: { $sum: '$tokensUsed' },
          cost: { $sum: '$cost' },
          calls: { $sum: 1 },
        },
      },
      { $sort: { '_id.date': 1 } },
    ])

    // Pivot into { day, chat, prescription_scan, report_analysis, wellness, cost }
    const dayMap: Record<string, Record<string, number>> = {}
    for (const r of dailyRaw) {
      const d = r._id.date
      if (!dayMap[d]) dayMap[d] = { chat: 0, prescription_scan: 0, report_analysis: 0, wellness: 0, cost: 0 }
      dayMap[d][r._id.feature] = (dayMap[d][r._id.feature] || 0) + r.tokens
      dayMap[d].cost = (dayMap[d].cost || 0) + r.cost
    }
    const dailyData = Object.entries(dayMap).map(([date, v]) => ({
      day: date.slice(5), // MM-DD
      chat: v.chat || 0,
      scan: v.prescription_scan || 0,
      reports: v.report_analysis || 0,
      wellness: v.wellness || 0,
      cost: Number((v.cost || 0).toFixed(2)),
    }))

    // Model breakdown
    const modelRaw = await AIUsageLog.aggregate([
      { $match: { createdAt: { $gte: since } } },
      {
        $group: {
          _id: '$aiModel',
          tokens: { $sum: '$tokensUsed' },
          cost: { $sum: '$cost' },
          calls: { $sum: 1 },
        },
      },
      { $sort: { tokens: -1 } },
    ])
    const totalTokensModel = modelRaw.reduce((a, m) => a + m.tokens, 0) || 1
    const modelUsage = modelRaw.map((m) => ({
      model: m._id || 'unknown',
      tokens: m.tokens,
      cost: Number(m.cost.toFixed(2)),
      calls: m.calls,
      pct: Number(((m.tokens / totalTokensModel) * 100).toFixed(1)),
    }))

    // Feature cost breakdown
    const featureRaw = await AIUsageLog.aggregate([
      { $match: { createdAt: { $gte: since } } },
      {
        $group: {
          _id: '$feature',
          cost: { $sum: '$cost' },
          calls: { $sum: 1 },
        },
      },
      { $sort: { cost: -1 } },
    ])
    const totalCostFeature = featureRaw.reduce((a, f) => a + f.cost, 0) || 1
    const featureCosts = featureRaw.map((f) => ({
      feature: f._id,
      daily: Number((f.cost / days).toFixed(2)),
      monthly: Number((f.cost * (30 / days)).toFixed(0)),
      pct: Number(((f.cost / totalCostFeature) * 100).toFixed(1)),
    }))

    // Today KPIs
    const [todayStats, periodStats] = await Promise.all([
      AIUsageLog.aggregate([
        { $match: { createdAt: { $gte: today } } },
        { $group: { _id: null, tokens: { $sum: '$tokensUsed' }, cost: { $sum: '$cost' }, calls: { $sum: 1 } } },
      ]),
      AIUsageLog.aggregate([
        { $match: { createdAt: { $gte: since } } },
        { $group: { _id: null, tokens: { $sum: '$tokensUsed' }, cost: { $sum: '$cost' }, calls: { $sum: 1 } } },
      ]),
    ])

    const todayKpi = todayStats[0] || { tokens: 0, cost: 0, calls: 0 }
    const periodKpi = periodStats[0] || { tokens: 0, cost: 0, calls: 0 }

    // Top consumers
    const topConsumersRaw = await AIUsageLog.aggregate([
      { $match: { createdAt: { $gte: today } } },
      {
        $group: {
          _id: '$userId',
          calls: { $sum: 1 },
          tokens: { $sum: '$tokensUsed' },
          cost: { $sum: '$cost' },
        },
      },
      { $sort: { calls: -1 } },
      { $limit: 10 },
    ])

    const userIds = topConsumersRaw.map((r) => r._id)
    const users = await User.find({ _id: { $in: userIds } })
      .select('name email subscription')
      .lean<{ _id: string; name?: string; email?: string; subscription?: { plan?: string } }[]>()
    const userMap = Object.fromEntries(users.map((u) => [u._id.toString(), u]))

    const topConsumers = topConsumersRaw.map((r) => {
      const u = userMap[r._id?.toString()]
      return {
        name: u?.name || u?.email || 'Unknown',
        calls: r.calls,
        tokens: r.tokens,
        cost: `$${r.cost.toFixed(2)}`,
        plan: u?.subscription?.plan || 'free',
      }
    })

    return ok({
      kpis: {
        tokensToday: todayKpi.tokens,
        costToday: Number(todayKpi.cost.toFixed(2)),
        callsToday: todayKpi.calls,
        tokensPeriod: periodKpi.tokens,
        costPeriod: Number(periodKpi.cost.toFixed(2)),
        callsPeriod: periodKpi.calls,
        projectedMonthlyCost: Number((periodKpi.cost * (30 / days)).toFixed(0)),
      },
      dailyData,
      modelUsage,
      featureCosts,
      topConsumers,
      period: `${days}d`,
    })
  } catch (e) {
    console.error(e)
    return err('Failed to fetch AI usage', 500)
  }
})
