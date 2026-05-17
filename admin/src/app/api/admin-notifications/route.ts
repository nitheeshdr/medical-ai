import { NextRequest, NextResponse } from 'next/server'

const BACKEND = process.env.BACKEND_URL || 'http://localhost:3001/api'
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || ''
const headers = () => ({ Authorization: `Bearer ${ADMIN_TOKEN}`, 'Content-Type': 'application/json' })

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url)
    const page = searchParams.get('page') || '1'
    const res = await fetch(`${BACKEND}/admin/notifications?page=${page}&limit=20`, { headers: headers() })
    const json = await res.json()
    return NextResponse.json(json.data ?? json)
  } catch {
    return NextResponse.json({ notifications: [], stats: {} }, { status: 500 })
  }
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json()
    const res = await fetch(`${BACKEND}/admin/notifications`, {
      method: 'POST',
      headers: headers(),
      body: JSON.stringify(body),
    })
    const json = await res.json()
    return NextResponse.json(json.data ?? json, { status: res.status })
  } catch {
    return NextResponse.json({ error: 'Proxy error' }, { status: 500 })
  }
}
