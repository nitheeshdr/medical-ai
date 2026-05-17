import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Prescription } from '@/models/Prescription'
import { withAuth, ok, err } from '@/lib/middleware'

export const GET = withAuth(async (_, user) => {
  try {
    await connectDB()
    const prescriptions = await Prescription.find({ userId: user.userId }).sort({ createdAt: -1 }).lean()
    return ok(prescriptions)
  } catch (e) {
    console.error(e)
    return err('Failed to fetch prescriptions', 500)
  }
})

export const POST = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const { imageUrl, ocrText } = await req.json()
    if (!imageUrl) return err('Image URL required')

    const prescription = await Prescription.create({
      userId: user.userId,
      imageUrl,
      ocrText: ocrText || '',
      aiAnalysis: { medicines: [], sideEffects: [], foodRestrictions: [], warnings: [], summary: 'Pending analysis' },
    })

    return ok(prescription, 201)
  } catch (e) {
    console.error(e)
    return err('Failed to create prescription', 500)
  }
})
