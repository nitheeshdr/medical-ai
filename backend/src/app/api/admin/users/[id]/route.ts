import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { User } from '@/models/User'
import { Subscription } from '@/models/Subscription'
import { AIUsageLog } from '@/models/AIUsageLog'
import { Report } from '@/models/Report'
import { Prescription } from '@/models/Prescription'
import { Appointment } from '@/models/Appointment'
import { withRole, ok, err } from '@/lib/middleware'

export const GET = withRole('admin')(async (_req: NextRequest, { params }: { params: { id: string } }) => {
  try {
    await connectDB()
    const { id } = params

    const [user, sub, aiLogs, reports, prescriptions, appointments] = await Promise.all([
      User.findById(id).select('-passwordHash').lean(),
      Subscription.findOne({ userId: id }).lean(),
      AIUsageLog.aggregate([
        { $match: { userId: id } },
        { $group: { _id: null, totalTokens: { $sum: '$tokensUsed' }, totalCost: { $sum: '$cost' }, requests: { $sum: 1 } } },
      ]),
      Report.find({ userId: id }).sort({ createdAt: -1 }).limit(20).lean(),
      Prescription.find({ userId: id }).sort({ createdAt: -1 }).limit(10).lean(),
      Appointment.find({ userId: id }).sort({ scheduledAt: -1 }).limit(10).lean(),
    ])

    if (!user) return err('User not found', 404)

    const ai = aiLogs[0] ?? { totalTokens: 0, totalCost: 0, requests: 0 }

    return ok({
      user: {
        ...user,
        plan: sub?.plan ?? 'free',
        subscriptionStatus: sub?.status ?? 'inactive',
        subscriptionStart: sub?.createdAt ?? null,
        subscriptionRenewal: sub?.currentPeriodEnd ?? null,
        aiRequests: ai.requests,
        aiTokens: ai.totalTokens,
        aiCost: Number(ai.totalCost.toFixed(4)),
      },
      reports,
      prescriptions,
      appointments,
    })
  } catch (e) {
    console.error(e)
    return err('Failed to fetch user detail', 500)
  }
})
