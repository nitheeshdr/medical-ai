import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Notification } from '@/models/Notification'
import { User } from '@/models/User'
import { withRole, ok, err } from '@/lib/middleware'
import { sendPushNotification } from '@/lib/firebase'

// GET /api/admin/notifications — list all notifications with stats
export const GET = withRole('admin')(async (req: NextRequest) => {
  try {
    await connectDB()
    const { searchParams } = new URL(req.url)
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')
    const skip = (page - 1) * limit

    const [notifications, total] = await Promise.all([
      Notification.find()
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('userId', 'name email')
        .lean(),
      Notification.countDocuments(),
    ])

    // Stats for today
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const [sentToday, totalDelivered, unreadCount] = await Promise.all([
      Notification.countDocuments({ createdAt: { $gte: today } }),
      Notification.countDocuments(),
      Notification.countDocuments({ read: false }),
    ])

    // Open rate approximation (read/total)
    const readCount = await Notification.countDocuments({ read: true })
    const openRate = total > 0 ? Number(((readCount / total) * 100).toFixed(1)) : 0

    return ok({
      notifications,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
      stats: {
        sentToday,
        totalDelivered,
        openRate,
        unreadCount,
      },
    })
  } catch (e) {
    console.error(e)
    return err('Failed to fetch notifications', 500)
  }
})

// POST /api/admin/notifications — broadcast to a segment of users
export const POST = withRole('admin')(async (req: NextRequest) => {
  try {
    await connectDB()
    const { title, body, type = 'system', audience = 'all', scheduledAt } = await req.json()
    if (!title || !body) return err('title and body are required', 400)

    // Resolve target users based on audience
    type UserQuery = { 'subscription.plan'?: string }
    let userQuery: UserQuery = {}
    if (audience === 'free') userQuery['subscription.plan'] = 'free'
    else if (audience === 'pro') userQuery['subscription.plan'] = 'pro'
    else if (audience === 'family') userQuery['subscription.plan'] = 'family'
    else if (audience === 'enterprise') userQuery['subscription.plan'] = 'enterprise'

    const users = await User.find(userQuery).select('_id fcmToken').lean<{ _id: string; fcmToken?: string }[]>()

    // Create notification docs in bulk
    const docs = users.map((u) => ({
      userId: u._id,
      type,
      title,
      body,
      read: false,
      data: { audience, scheduledAt },
    }))

    if (docs.length > 0) {
      await Notification.insertMany(docs)
    }

    // Fire-and-forget FCM push to users with tokens
    const pushPromises = users
      .filter((u) => u.fcmToken)
      .map((u) => sendPushNotification(u.fcmToken!, title, body, { type }).catch(() => null))
    Promise.allSettled(pushPromises).catch(() => null)

    return ok({
      sent: docs.length,
      audience,
      title,
    })
  } catch (e) {
    console.error(e)
    return err('Failed to send notification', 500)
  }
})
