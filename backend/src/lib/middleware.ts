import { NextRequest, NextResponse } from 'next/server'
import { verifyToken } from './jwt'

export interface AuthUser {
  userId: string
  email: string
  role: string
}

export function withAuth(
  handler: (req: NextRequest, user: AuthUser) => Promise<NextResponse>
) {
  return async (req: NextRequest) => {
    const auth = req.headers.get('authorization')
    if (!auth?.startsWith('Bearer ')) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }
    try {
      const payload = verifyToken(auth.slice(7))
      const user: AuthUser = {
        userId: payload.userId,
        email: payload.email,
        role: payload.role || 'user',
      }
      return handler(req, user)
    } catch {
      return NextResponse.json({ error: 'Invalid token' }, { status: 401 })
    }
  }
}

export function withRole(role: string) {
  return (handler: (req: NextRequest, user: AuthUser) => Promise<NextResponse>) =>
    withAuth(async (req, user) => {
      if (user.role !== role && user.role !== 'admin') {
        return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
      }
      return handler(req, user)
    })
}

export function ok<T>(data: T, status = 200) {
  return NextResponse.json({ success: true, data }, { status })
}

export function err(message: string, status = 400) {
  return NextResponse.json({ success: false, error: message }, { status })
}
