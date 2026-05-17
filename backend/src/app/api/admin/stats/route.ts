import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { User } from '@/models/User'
import { Doctor } from '@/models/Doctor'
import { Appointment } from '@/models/Appointment'
import { AIUsageLog } from '@/models/AIUsageLog'
import { Subscription } from '@/models/Subscription'
import { Prescription } from '@/models/Prescription'
import { withRole, ok, err } from '@/lib/middleware'

export const GET = withRole('admin')(async (req: NextRequest) => {
  try {
    await connectDB()
    const { searchParams } = new URL(req.url)
    const days = parseInt(searchParams.get('days') || '30')
    const since = new Date()
    since.setDate(since.getDate() - days)

    // Build daily-bucketed data for charts (last N days)
    const dailyUsers = await User.aggregate([
      { $match: { createdAt: { $gte: since } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ])

    const dailyAI = await AIUsageLog.aggregate([
      { $match: { createdAt: { $gte: since } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          requests: { $sum: 1 },
          tokens: { $sum: '$tokensUsed' },
          cost: { $sum: '$cost' },
        },
      },
      { $sort: { _id: 1 } },
    ])

    const dailyAppointments = await Appointment.aggregate([
      { $match: { createdAt: { $gte: since } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ])

    const [
      totalUsers,
      newUsers,
      totalDoctors,
      totalAppointments,
      totalAIUsage,
      activeSubs,
      totalPrescriptions,
    ] = await Promise.all([
      User.countDocuments(),
      User.countDocuments({ createdAt: { $gte: since } }),
      Doctor.countDocuments(),
      Appointment.countDocuments({ createdAt: { $gte: since } }),
      AIUsageLog.aggregate([
        { $match: { createdAt: { $gte: since } } },
        { $group: { _id: null, tokens: { $sum: '$tokensUsed' }, cost: { $sum: '$cost' }, requests: { $sum: 1 } } },
      ]),
      Subscription.countDocuments({ status: 'active', plan: { $ne: 'free' } }),
      Prescription.countDocuments({ createdAt: { $gte: since } }),
    ])

    const aiStats = totalAIUsage[0] || { tokens: 0, cost: 0, requests: 0 }

    // Recent activity: last 10 users + recent AI logs
    const recentUsers = await User.find()
      .sort({ createdAt: -1 })
      .limit(5)
      .select('name email createdAt')
      .lean()

    const recentAILogs = await AIUsageLog.find()
      .sort({ createdAt: -1 })
      .limit(5)
      .populate('userId', 'name email')
      .lean()

    const recentActivity = [
      ...recentUsers.map((u) => ({
        user: u.name || u.email,
        action: 'New user registered',
        time: u.createdAt,
        type: 'user',
      })),
      ...recentAILogs.map((l) => ({
        user: (l.userId as { name?: string; email?: string })?.name || 'User',
        action: `AI ${l.feature} request`,
        time: l.createdAt,
        type: 'ai',
      })),
    ]
      .sort((a, b) => new Date(b.time).getTime() - new Date(a.time).getTime())
      .slice(0, 10)

    return ok({
      stats: {
        users: { total: totalUsers, new: newUsers },
        doctors: { total: totalDoctors },
        appointments: { total: totalAppointments },
        prescriptions: { total: totalPrescriptions },
        ai: { requests: aiStats.requests, tokensUsed: aiStats.tokens, cost: Number(aiStats.cost.toFixed(4)) },
        subscriptions: { active: activeSubs },
        estimatedRevenue: activeSubs * 29.99, // Pro plan price
      },
      charts: {
        dailyUsers,
        dailyAI,
        dailyAppointments,
      },
      recentActivity,
      period: `${days}d`,
    })
  } catch (e) {
    console.error(e)
    return err('Failed to fetch stats', 500)
  }
})
