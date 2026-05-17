import { NextRequest, NextResponse } from 'next/server'

const PUBLIC_PATHS = ['/login', '/api/auth/login']

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl

  // Allow public paths and Next.js internals through
  if (PUBLIC_PATHS.some(p => pathname.startsWith(p)) || pathname.startsWith('/_next')) {
    return NextResponse.next()
  }

  // Check for admin token in cookie (set on login) or legacy ADMIN_TOKEN env header
  const cookieToken = req.cookies.get('admin_token')?.value
  const envToken = process.env.ADMIN_TOKEN

  if (!cookieToken && !envToken) {
    return NextResponse.redirect(new URL('/login', req.url))
  }

  // Forward the active token to backend-proxy API routes via header
  const token = cookieToken ?? envToken
  const res = NextResponse.next()
  res.headers.set('x-admin-token', token!)
  return res
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
