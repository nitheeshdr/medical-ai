import { NextRequest } from 'next/server'
import bcrypt from 'bcryptjs'
import { connectDB } from '@/lib/mongodb'
import { User } from '@/models/User'
import { signToken, signRefreshToken } from '@/lib/jwt'
import { ok, err } from '@/lib/middleware'

export async function POST(req: NextRequest) {
  try {
    await connectDB()
    const { name, email, password } = await req.json()

    if (!name || !email || !password) return err('All fields required')
    if (password.length < 6) return err('Password must be at least 6 characters')

    const exists = await User.findOne({ email })
    if (exists) return err('Email already registered', 409)

    const passwordHash = await bcrypt.hash(password, 12)
    const user = await User.create({ name, email, passwordHash })

    const payload = { userId: user._id, email: user.email, role: user.role }
    const token = signToken(payload)
    const refreshToken = signRefreshToken(payload)

    return ok({ token, refreshToken, user: { id: user._id, name: user.name, email: user.email, role: user.role } }, 201)
  } catch (e) {
    console.error(e)
    return err('Registration failed', 500)
  }
}
