import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Medicine } from '@/models/Medicine'
import { withAuth, ok, err } from '@/lib/middleware'

export const GET = withAuth(async (req: NextRequest) => {
  try {
    await connectDB()
    const { searchParams } = new URL(req.url)
    const category = searchParams.get('category')
    const search = searchParams.get('search')
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '50')

    const query: Record<string, unknown> = {}
    if (category && category !== 'All') query.category = category
    if (search) query.$text = { $search: search }

    const medicines = await Medicine.find(query)
      .skip((page - 1) * limit)
      .limit(limit)
      .lean()

    const total = await Medicine.countDocuments(query)
    return ok({ medicines, total, page, pages: Math.ceil(total / limit) })
  } catch (e) {
    console.error(e)
    return err('Failed to fetch medicines', 500)
  }
})
