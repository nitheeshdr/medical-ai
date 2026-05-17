import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Doctor } from '@/models/Doctor'
import { Appointment } from '@/models/Appointment'
import { withRole, ok, err } from '@/lib/middleware'

export const GET = withRole('admin')(async (req: NextRequest) => {
  try {
    await connectDB()
    const { searchParams } = new URL(req.url)
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')
    const search = searchParams.get('search') || ''
    const skip = (page - 1) * limit

    const query = search
      ? { $or: [{ name: { $regex: search, $options: 'i' } }, { specialization: { $regex: search, $options: 'i' } }] }
      : {}

    const [doctors, total] = await Promise.all([
      Doctor.find(query).sort({ createdAt: -1 }).skip(skip).limit(limit).lean(),
      Doctor.countDocuments(query),
    ])

    const doctorIds = doctors.map((d) => d._id)
    const apptCounts = await Appointment.aggregate([
      { $match: { doctorId: { $in: doctorIds } } },
      { $group: { _id: '$doctorId', total: { $sum: 1 } } },
    ])
    const apptMap = new Map(apptCounts.map((a) => [String(a._id), a.total]))

    const enriched = doctors.map((d) => ({
      ...d,
      appointmentCount: apptMap.get(String(d._id)) ?? 0,
    }))

    return ok({ doctors: enriched, total, page, pages: Math.ceil(total / limit) })
  } catch (e) {
    console.error(e)
    return err('Failed to fetch doctors', 500)
  }
})

export const POST = withRole('admin')(async (req: NextRequest) => {
  try {
    await connectDB()
    const body = await req.json()
    const doctor = await Doctor.create(body)
    return ok(doctor, 201)
  } catch (e) {
    console.error(e)
    return err('Failed to create doctor', 500)
  }
})

export const PUT = withRole('admin')(async (req: NextRequest) => {
  try {
    await connectDB()
    const { id, ...updates } = await req.json()
    if (!id) return err('Doctor ID required')
    const doctor = await Doctor.findByIdAndUpdate(id, updates, { new: true })
    if (!doctor) return err('Doctor not found', 404)
    return ok(doctor)
  } catch (e) {
    console.error(e)
    return err('Failed to update doctor', 500)
  }
})
