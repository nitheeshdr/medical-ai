import { NextResponse } from 'next/server'

export async function POST() {
  const res = NextResponse.json({ success: true })
  // Clear the admin_token cookie
  res.cookies.set('admin_token', '', {
    path: '/',
    maxAge: 0,
    httpOnly: false,
    sameSite: 'strict',
  })
  return res
}
