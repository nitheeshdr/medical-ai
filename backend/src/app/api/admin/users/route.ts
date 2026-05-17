import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { User } from '@/models/User'
import { Subscription } from '@/models/Subscription'
import { AIUsageLog } from '@/models/AIUsageLog'
import { withRole, ok, err } from '@/lib/middleware'

export const GET = withRole('admin')(async (req: NextRequest) => {
  try {
    await connectDB()
    const { searchParams } = new URL(req.url)
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')
    const search = searchParams.get('search') || ''
    const skip = (page - 1) * limit

    const query = search
      ? { $or: [{ name: { $regex: search, $options: 'i' } }, { email: { $regex: search, $options: 'i' } }] }
      : {}

    const [users, total] = await Promise.all([
      User.find(query).sort({ createdAt: -1 }).skip(skip).limit(limit).select('-passwordHash').lean(),
      User.countDocuments(query),
    ])

    // Enrich with subscription and AI usage data
    const userIds = users.map((u) => u._id)
    const [subs, aiLogs] = await Promise.all([
      Subscription.find({ userId: { $in: userIds } }).lean(),
      AIUsageLog.aggregate([
        { $match: { userId: { $in: userIds } } },
        { $group: { _id: '$userId', totalTokens: { $sum: '$tokensUsed' }, totalCost: { $sum: '$cost' }, requests: { $sum: 1 } } },
      ]),
    ])

    const subMap = new Map(subs.map((s) => [String(s.userId), s]))
    const aiMap = new Map(aiLogs.map((a) => [String(a._id), a]))

    const enriched = users.map((u) => {
      const sub = subMap.get(String(u._id))
      const ai = aiMap.get(String(u._id))
      return {
        ...u,
        plan: sub?.plan ?? 'free',
        subscriptionStatus: sub?.status ?? 'inactive',
        aiRequests: ai?.requests ?? 0,
        aiCost: Number((ai?.totalCost ?? 0).toFixed(2)),
      }
    })

    return ok({ users: enriched, total, page, pages: Math.ceil(total / limit) })
  } catch (e) {
    console.error(e)
    return err('Failed to fetch users', 500)
  }
})

export const DELETE = withRole('admin')(async (req: NextRequest) => {
  try {
    await connectDB()
    const { userId } = await req.json()
    if (!userId) return err('User ID required')
    await User.findByIdAndDelete(userId)
    return ok({ deleted: true })
  } catch (e) {
    console.error(e)
    return err('Failed to delete user', 500)
  }
})
