import { NextRequest } from 'next/server'
import bcrypt from 'bcryptjs'
import { connectDB } from '@/lib/mongodb'
import { User } from '@/models/User'
import { withAuth, ok, err } from '@/lib/middleware'

export const POST = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const { currentPassword, newPassword } = await req.json()
    if (!currentPassword || !newPassword) return err('Both current and new password required')
    if (newPassword.length < 8) return err('New password must be at least 8 characters')

    const dbUser = await User.findById(user.userId)
    if (!dbUser) return err('User not found', 404)

    const valid = await bcrypt.compare(currentPassword, dbUser.passwordHash)
    if (!valid) return err('Current password is incorrect', 401)

    dbUser.passwordHash = await bcrypt.hash(newPassword, 12)
    await dbUser.save()

    return ok({ message: 'Password changed successfully' })
  } catch (e) {
    console.error(e)
    return err('Failed to change password', 500)
  }
})
