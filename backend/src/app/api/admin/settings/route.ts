import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { PlatformSettings } from '@/models/PlatformSettings'
import { withRole, ok, err } from '@/lib/middleware'

// GET /api/admin/settings
export const GET = withRole('admin')(async (_req: NextRequest) => {
  try {
    await connectDB()
    // Upsert on first read to seed defaults
    let settings = await PlatformSettings.findOne().lean()
    if (!settings) {
      settings = await PlatformSettings.create({})
    }
    return ok(settings)
  } catch (e) {
    console.error(e)
    return err('Failed to fetch settings', 500)
  }
})

// PATCH /api/admin/settings
export const PATCH = withRole('admin')(async (req: NextRequest) => {
  try {
    await connectDB()
    const body = await req.json()

    const updated = await PlatformSettings.findOneAndUpdate(
      {},
      { $set: body },
      { upsert: true, new: true, runValidators: false }
    ).lean()

    return ok(updated)
  } catch (e) {
    console.error(e)
    return err('Failed to update settings', 500)
  }
})
