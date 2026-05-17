import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Appointment } from '@/models/Appointment'
import { withAuth, ok, err } from '@/lib/middleware'

export const GET = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const { searchParams } = new URL(req.url)
    const status = searchParams.get('status')
    const query: Record<string, unknown> = { userId: user.userId }
    if (status) query.status = status

    const appointments = await Appointment.find(query)
      .populate('doctorId', 'name specialization consultationFee')
      .sort({ slot: -1 })
      .lean()

    return ok(appointments)
  } catch (e) {
    console.error(e)
    return err('Failed to fetch appointments', 500)
  }
})

export const POST = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const body = await req.json()
    const { doctorId, slot, type, notes, symptoms } = body

    if (!doctorId || !slot) return err('Doctor and slot required')

    const existing = await Appointment.findOne({ doctorId, slot: new Date(slot), status: { $ne: 'cancelled' } })
    if (existing) return err('Slot already booked', 409)

    const appointment = await Appointment.create({
      userId: user.userId,
      doctorId,
      slot: new Date(slot),
      type: type || 'video',
      notes,
      symptoms,
    })

    return ok(appointment, 201)
  } catch (e) {
    console.error(e)
    return err('Failed to book appointment', 500)
  }
})
