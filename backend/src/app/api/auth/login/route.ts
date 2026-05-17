import { NextRequest } from 'next/server'
import bcrypt from 'bcryptjs'
import { connectDB } from '@/lib/mongodb'
import { User } from '@/models/User'
import { signToken, signRefreshToken } from '@/lib/jwt'
import { ok, err } from '@/lib/middleware'

export async function POST(req: NextRequest) {
  try {
    await connectDB()
    const { email, password } = await req.json()

    if (!email || !password) return err('Email and password required')

    const user = await User.findOne({ email })
    if (!user) return err('Invalid credentials', 401)

    const valid = await bcrypt.compare(password, user.passwordHash)
    if (!valid) return err('Invalid credentials', 401)

    const payload = { userId: user._id, email: user.email, role: user.role }
    const token = signToken(payload)
    const refreshToken = signRefreshToken(payload)

    return ok({ token, refreshToken, user: { id: user._id, name: user.name, email: user.email, role: user.role, subscriptionTier: user.subscriptionTier } })
  } catch (e) {
    console.error(e)
    return err('Login failed', 500)
  }
}
