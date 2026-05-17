import { NextRequest, NextResponse } from 'next/server'

const BACKEND = process.env.BACKEND_URL || 'http://localhost:3001/api'
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || ''
const auth = () => ({ Authorization: `Bearer ${ADMIN_TOKEN}`, 'Content-Type': 'application/json' })

export async function GET(_req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const res = await fetch(`${BACKEND}/admin/users/${params.id}`, { headers: auth() })
    const json = await res.json()
    return NextResponse.json(json.data ?? json, { status: res.status })
  } catch {
    return NextResponse.json({ error: 'Proxy error' }, { status: 500 })
  }
}
