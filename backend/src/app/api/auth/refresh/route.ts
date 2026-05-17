import { NextRequest } from 'next/server'
import { verifyRefreshToken, signToken } from '@/lib/jwt'
import { ok, err } from '@/lib/middleware'

export async function POST(req: NextRequest) {
  try {
    const { refreshToken } = await req.json()
    if (!refreshToken) return err('Refresh token required')

    const payload = verifyRefreshToken(refreshToken)
    const token = signToken({ userId: payload.userId, email: payload.email, role: payload.role })
    return ok({ token })
  } catch {
    return err('Invalid refresh token', 401)
  }
}
