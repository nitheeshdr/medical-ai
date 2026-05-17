import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { HealthMetric } from '@/models/HealthMetric'
import { withAuth, ok, err } from '@/lib/middleware'

export const GET = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const { searchParams } = new URL(req.url)
    const type = searchParams.get('type')
    const days = parseInt(searchParams.get('days') || '7')

    const since = new Date()
    since.setDate(since.getDate() - days)

    const query: Record<string, unknown> = { userId: user.userId, timestamp: { $gte: since } }
    if (type) query.type = type

    const metrics = await HealthMetric.find(query).sort({ timestamp: -1 }).lean()
    return ok(metrics)
  } catch (e) {
    console.error(e)
    return err('Failed to fetch metrics', 500)
  }
})

export const POST = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const body = await req.json()
    const { type, value, secondaryValue, unit, source } = body

    if (!type || value === undefined || !unit) return err('Type, value, and unit required')

    const metric = await HealthMetric.create({
      userId: user.userId,
      type,
      value,
      secondaryValue,
      unit,
      source: source || 'manual',
    })

    return ok(metric, 201)
  } catch (e) {
    console.error(e)
    return err('Failed to save metric', 500)
  }
})
