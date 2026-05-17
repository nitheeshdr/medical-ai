import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { User } from '@/models/User'
import { withAuth, ok, err } from '@/lib/middleware'

// POST /api/users/fcm-token — register or update the FCM device token for the current user
export const POST = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const { token } = await req.json()
    if (!token || typeof token !== 'string') {
      return err('token is required', 400)
    }
    await User.findByIdAndUpdate(user.userId, { fcmToken: token })
    return ok({ message: 'FCM token registered' })
  } catch (e) {
    console.error(e)
    return err('Failed to register FCM token', 500)
  }
})

// DELETE /api/users/fcm-token — clear the token on logout / unsubscribe
export const DELETE = withAuth(async (_req: NextRequest, user) => {
  try {
    await connectDB()
    await User.findByIdAndUpdate(user.userId, { $unset: { fcmToken: 1 } })
    return ok({ message: 'FCM token removed' })
  } catch (e) {
    console.error(e)
    return err('Failed to remove FCM token', 500)
  }
})
