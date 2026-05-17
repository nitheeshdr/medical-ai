import { NextRequest, NextResponse } from 'next/server'

const BACKEND = process.env.BACKEND_URL || 'http://localhost:3001/api'
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || ''
const auth = () => ({ Authorization: `Bearer ${ADMIN_TOKEN}`, 'Content-Type': 'application/json' })

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url)
    const qs = new URLSearchParams({
      page: searchParams.get('page') || '1',
      limit: searchParams.get('limit') || '20',
      ...(searchParams.get('search') ? { search: searchParams.get('search')! } : {}),
    })
    const res = await fetch(`${BACKEND}/admin/doctors?${qs}`, { headers: auth() })
    const json = await res.json()
    return NextResponse.json(json.data ?? json)
  } catch {
    return NextResponse.json({ doctors: [], total: 0 }, { status: 500 })
  }
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json()
    const res = await fetch(`${BACKEND}/admin/doctors`, {
      method: 'POST',
      headers: auth(),
      body: JSON.stringify(body),
    })
    const json = await res.json()
    return NextResponse.json(json.data ?? json, { status: res.status })
  } catch {
    return NextResponse.json({ error: 'Proxy error' }, { status: 500 })
  }
}

export async function PUT(req: NextRequest) {
  try {
    const body = await req.json()
    const res = await fetch(`${BACKEND}/admin/doctors`, {
      method: 'PUT',
      headers: auth(),
      body: JSON.stringify(body),
    })
    const json = await res.json()
    return NextResponse.json(json.data ?? json, { status: res.status })
  } catch {
    return NextResponse.json({ error: 'Proxy error' }, { status: 500 })
  }
}
