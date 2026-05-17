import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Doctor } from '@/models/Doctor'
import { withAuth, ok, err } from '@/lib/middleware'

export const GET = withAuth(async (req: NextRequest) => {
  try {
    await connectDB()
    const { searchParams } = new URL(req.url)
    const specialty = searchParams.get('specialty')
    const search = searchParams.get('search')
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')

    const query: Record<string, unknown> = { isVerified: true }
    if (specialty) query.specialization = specialty
    if (search) query.$text = { $search: search }

    const doctors = await Doctor.find(query)
      .select('-ratings')
      .skip((page - 1) * limit)
      .limit(limit)
      .lean()

    const total = await Doctor.countDocuments(query)
    return ok({ doctors, total, page, pages: Math.ceil(total / limit) })
  } catch (e) {
    console.error(e)
    return err('Failed to fetch doctors', 500)
  }
})
