import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { User } from '@/models/User'
import { Subscription } from '@/models/Subscription'
import { AIUsageLog } from '@/models/AIUsageLog'
import { Report } from '@/models/Report'
import { Prescription } from '@/models/Prescription'
import { Appointment } from '@/models/Appointment'
import { withRole, AuthUser, ok, err } from '@/lib/middleware'

export const GET = withRole('admin')(async (req: NextRequest, _user: AuthUser) => {
  try {
    await connectDB()

    // Extract id from URL path: /api/admin/users/[id]
    const segments = req.nextUrl.pathname.split('/')
    const id = segments[segments.length - 1]
    if (!id) return err('User ID required')

    const [user, sub, aiLogs, reports, prescriptions, appointments] = await Promise.all([
      User.findById(id).select('-passwordHash').lean(),
      Subscription.findOne({ userId: id }).lean(),
      AIUsageLog.aggregate([
        { $match: { userId: id } },
        {
          $group: {
            _id: null,
            totalTokens: { $sum: '$tokensUsed' },
            totalCost: { $sum: '$cost' },
            requests: { $sum: 1 },
          },
        },
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
        plan: (sub as any)?.plan ?? 'free',
        subscriptionStatus: (sub as any)?.status ?? 'inactive',
        subscriptionStart: (sub as any)?.createdAt ?? null,
        subscriptionRenewal: (sub as any)?.currentPeriodEnd ?? null,
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
