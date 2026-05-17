import { NextRequest, NextResponse } from 'next/server'
import { cookies } from 'next/headers'

const BACKEND = process.env.BACKEND_URL || 'http://localhost:3001/api'

export async function GET(
  _req: NextRequest,
  context: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await context.params
    const cookieStore = await cookies()
    const token = cookieStore.get('admin_token')?.value ?? ''

    const res = await fetch(`${BACKEND}/admin/users/${id}`, {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      cache: 'no-store',
    })

    const json = await res.json()
    // Backend wraps in { success, data } — unwrap for the frontend
    return NextResponse.json(json.data ?? json, { status: res.status })
  } catch {
    return NextResponse.json({ error: 'Proxy error' }, { status: 500 })
  }
}
