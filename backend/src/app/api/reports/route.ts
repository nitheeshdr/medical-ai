import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Report } from '@/models/Report'
import { withAuth, ok, err } from '@/lib/middleware'

export const GET = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const { searchParams } = new URL(req.url)
    const type = searchParams.get('type')
    const query: Record<string, unknown> = { userId: user.userId }
    if (type) query.type = type
    const reports = await Report.find(query).sort({ createdAt: -1 }).lean()
    return ok(reports)
  } catch (e) {
    console.error(e)
    return err('Failed to fetch reports', 500)
  }
})

export const POST = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const { type, fileUrl, fileName, fileSize } = await req.json()
    if (!type || !fileUrl || !fileName) return err('Type, file URL, and file name required')

    const report = await Report.create({
      userId: user.userId,
      type,
      fileUrl,
      fileName,
      fileSize: fileSize || 0,
      aiAnalysis: { summary: 'Pending analysis', highlights: [], recommendations: [], needsAttention: false },
    })

    return ok(report, 201)
  } catch (e) {
    console.error(e)
    return err('Failed to create report', 500)
  }
})
