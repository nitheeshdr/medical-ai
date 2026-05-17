import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Notification } from '@/models/Notification'
import { User } from '@/models/User'
import { withAuth, ok, err } from '@/lib/middleware'
import { sendPushNotification } from '@/lib/firebase'

export const GET = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const { searchParams } = new URL(req.url)
    const unreadOnly = searchParams.get('unread') === 'true'
    const query: Record<string, unknown> = { userId: user.userId }
    if (unreadOnly) query.read = false

    const notifications = await Notification.find(query).sort({ createdAt: -1 }).limit(50).lean()
    const unreadCount = await Notification.countDocuments({ userId: user.userId, read: false })
    return ok({ notifications, unreadCount })
  } catch (e) {
    console.error(e)
    return err('Failed to fetch notifications', 500)
  }
})

// POST /api/notifications — create a notification and optionally push via FCM
export const POST = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const { title, body, type = 'general', targetUserId } = await req.json()
    if (!title || !body) return err('title and body are required', 400)

    const recipientId = targetUserId ?? user.userId
    const notification = await Notification.create({
      userId: recipientId,
      type,
      title,
      body,
      read: false,
    })

    // Fire-and-forget FCM push
    const recipient = await User.findById(recipientId).select('fcmToken').lean<{ fcmToken?: string }>()
    if (recipient?.fcmToken) {
      sendPushNotification(recipient.fcmToken, title, body, { type }).catch(() => null)
    }

    return ok({ notification })
  } catch (e) {
    console.error(e)
    return err('Failed to create notification', 500)
  }
})

export const PUT = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const { ids, markAll } = await req.json()
    if (markAll) {
      await Notification.updateMany({ userId: user.userId }, { read: true })
    } else if (ids?.length) {
      await Notification.updateMany({ _id: { $in: ids }, userId: user.userId }, { read: true })
    }
    return ok({ message: 'Notifications marked as read' })
  } catch (e) {
    console.error(e)
    return err('Failed to update notifications', 500)
  }
})
