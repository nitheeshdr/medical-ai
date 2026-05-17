import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Subscription } from '@/models/Subscription'
import { User } from '@/models/User'
import { withRole, ok, err } from '@/lib/middleware'

export const GET = withRole('admin')(async (_req: NextRequest) => {
  try {
    await connectDB()

    // Plan distribution
    const planDistRaw = await Subscription.aggregate([
      { $match: { status: 'active' } },
      { $group: { _id: '$plan', count: { $sum: 1 }, revenue: { $sum: '$amount' } } },
      { $sort: { count: -1 } },
    ])

    const planColors: Record<string, string> = {
      free: '#2A2A2A',
      pro: '#ffffff',
      family: '#B5B5B5',
      enterprise: '#6B6B6B',
    }
    const totalSubs = planDistRaw.reduce((a, p) => a + p.count, 0) || 1
    const planBreakdown = planDistRaw.map((p) => ({
      plan: p._id,
      count: p.count,
      pct: Number(((p.count / totalSubs) * 100).toFixed(1)),
      mrr: `$${Math.round(p.revenue).toLocaleString()}`,
      color: planColors[p._id] || '#6B6B6B',
    }))

    // MRR by month (last 7 months)
    const since = new Date()
    since.setMonth(since.getMonth() - 6)
    since.setDate(1)
    const mrrRaw = await Subscription.aggregate([
      { $match: { createdAt: { $gte: since }, status: { $in: ['active', 'cancelled'] } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m', date: '$createdAt' } },
          mrr: { $sum: '$amount' },
          cancelled: {
            $sum: { $cond: [{ $eq: ['$status', 'cancelled'] }, '$amount', 0] },
          },
        },
      },
      { $sort: { _id: 1 } },
    ])
    const MONTH_LABELS: Record<string, string> = {
      '01': 'Jan', '02': 'Feb', '03': 'Mar', '04': 'Apr',
      '05': 'May', '06': 'Jun', '07': 'Jul', '08': 'Aug',
      '09': 'Sep', '10': 'Oct', '11': 'Nov', '12': 'Dec',
    }
    const mrrChart = mrrRaw.map((r) => ({
      month: MONTH_LABELS[r._id.slice(5)] || r._id.slice(5),
      mrr: Math.round(r.mrr),
      churn: Math.round(r.cancelled),
    }))

    // KPIs
    const [totalMrrAgg, paidSubs, cancelledThisMonth, totalUsers] = await Promise.all([
      Subscription.aggregate([
        { $match: { status: 'active', plan: { $ne: 'free' } } },
        { $group: { _id: null, mrr: { $sum: '$amount' } } },
      ]),
      Subscription.countDocuments({ status: 'active', plan: { $ne: 'free' } }),
      Subscription.countDocuments({
        status: 'cancelled',
        updatedAt: { $gte: new Date(new Date().getFullYear(), new Date().getMonth(), 1) },
      }),
      User.countDocuments(),
    ])

    const mrr = totalMrrAgg[0]?.mrr || 0
    const churnRate = paidSubs > 0 ? Number(((cancelledThisMonth / paidSubs) * 100).toFixed(1)) : 0
    const avgLtv = paidSubs > 0 ? Math.round(mrr / paidSubs * 12) : 0

    // Recent subscription events (last 20)
    const recentSubs = await Subscription.find()
      .sort({ updatedAt: -1 })
      .limit(20)
      .populate('userId', 'name email')
      .lean<{
        plan: string
        status: string
        amount: number
        billingCycle: string
        updatedAt: Date
        userId: { name?: string; email?: string }
      }[]>()

    const recentActivity = recentSubs.map((s) => ({
      user: s.userId?.name || s.userId?.email || 'Unknown',
      plan: s.plan,
      status: s.status,
      amount: `$${s.amount}/${s.billingCycle === 'annual' ? 'yr' : 'mo'}`,
      time: s.updatedAt,
      churn: s.status === 'cancelled',
    }))

    return ok({
      kpis: {
        mrr: Math.round(mrr),
        paidSubscribers: paidSubs,
        churnRate,
        avgLtv,
        totalUsers,
      },
      planBreakdown,
      mrrChart,
      recentActivity,
    })
  } catch (e) {
    console.error(e)
    return err('Failed to fetch subscription data', 500)
  }
})
