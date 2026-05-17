import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { User } from '@/models/User'
import { withAuth, ok, err } from '@/lib/middleware'

export const GET = withAuth(async (_, user) => {
  await connectDB()
  const profile = await User.findById(user.userId).select('-passwordHash')
  if (!profile) return err('User not found', 404)
  return ok(profile)
})

export const PUT = withAuth(async (req: NextRequest, user) => {
  await connectDB()
  const body = await req.json()
  const allowed = ['name', 'phone', 'bloodType', 'allergies', 'conditions', 'medications', 'dateOfBirth', 'gender']
  const update: Record<string, unknown> = {}
  for (const key of allowed) {
    if (key in body) update[key] = body[key]
  }
  const profile = await User.findByIdAndUpdate(user.userId, update, { new: true }).select('-passwordHash')
  return ok(profile)
})
