import { NextRequest, NextResponse } from 'next/server'

const PUBLIC_PATHS = ['/login', '/api/auth/login']

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl

  // Allow public paths and Next.js internals through
  if (PUBLIC_PATHS.some(p => pathname.startsWith(p)) || pathname.startsWith('/_next')) {
    return NextResponse.next()
  }

  // Only the cookie set at login time authenticates the browser session
  const cookieToken = req.cookies.get('admin_token')?.value
  if (!cookieToken) {
    return NextResponse.redirect(new URL('/login', req.url))
  }

  // Forward the cookie token to server-side API routes via header
  const res = NextResponse.next()
  res.headers.set('x-admin-token', cookieToken)
  return res
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
