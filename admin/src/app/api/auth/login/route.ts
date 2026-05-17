import { NextRequest, NextResponse } from 'next/server'

const BACKEND = process.env.BACKEND_URL ?? 'http://localhost:3001/api'

export async function POST(req: NextRequest) {
  const body = await req.json()
  const res = await fetch(`${BACKEND}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  const json = await res.json()
  if (!res.ok) {
    return NextResponse.json({ error: json.error ?? 'Invalid credentials' }, { status: res.status })
  }
  // json.data contains { token, refreshToken, user }
  const data = json.data ?? json
  return NextResponse.json({
    token: data.token,
    role: data.user?.role ?? data.role,
  })
}
