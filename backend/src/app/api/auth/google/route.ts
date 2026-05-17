import { NextRequest } from 'next/server'
import bcrypt from 'bcryptjs'
import { connectDB } from '@/lib/mongodb'
import { User } from '@/models/User'
import { signToken, signRefreshToken } from '@/lib/jwt'
import { ok, err } from '@/lib/middleware'

export async function POST(req: NextRequest) {
  try {
    await connectDB()
    const { name, email, googleId } = await req.json()

    if (!email || !googleId) return err('Email and Google ID required')

    let user = await User.findOne({ email })
    
    // If user does not exist, create a new one using a random secure password
    if (!user) {
      if (!name) return err('Name is required for new users')
      const randomPassword = Math.random().toString(36).slice(-10) + Math.random().toString(36).slice(-10)
      const passwordHash = await bcrypt.hash(randomPassword, 12)
      user = await User.create({ name, email, passwordHash })
    }

    const payload = { userId: user._id, email: user.email, role: user.role }
    const token = signToken(payload)
    const refreshToken = signRefreshToken(payload)

    return ok({
      token,
      refreshToken,
      user: { id: user._id, name: user.name, email: user.email, role: user.role, subscriptionTier: user.subscriptionTier }
    })
  } catch (e) {
    console.error(e)
    return err('Google Login failed', 500)
  }
}
