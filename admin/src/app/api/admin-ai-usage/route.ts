import { NextRequest, NextResponse } from 'next/server'

const BACKEND = process.env.BACKEND_URL || 'http://localhost:3001/api'
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || ''
const headers = () => ({ Authorization: `Bearer ${ADMIN_TOKEN}` })

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url)
    const days = searchParams.get('days') || '14'
    const res = await fetch(`${BACKEND}/admin/ai-usage?days=${days}`, { headers: headers() })
    const json = await res.json()
    return NextResponse.json(json.data ?? json)
  } catch {
    return NextResponse.json({}, { status: 500 })
  }
}
