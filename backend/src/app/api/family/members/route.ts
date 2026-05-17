import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { FamilyMember } from '@/models/FamilyMember'
import { withAuth, ok, err } from '@/lib/middleware'

export const GET = withAuth(async (_, user) => {
  try {
    await connectDB()
    const members = await FamilyMember.find({ ownerId: user.userId }).lean()
    return ok(members)
  } catch (e) {
    console.error(e)
    return err('Failed to fetch family members', 500)
  }
})

export const POST = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const { name, email, relation } = await req.json()
    if (!name || !email || !relation) return err('Name, email, and relation required')

    const member = await FamilyMember.create({
      ownerId: user.userId,
      name,
      email,
      relation,
      permissions: ['view_health_score'],
      inviteStatus: 'pending',
    })

    return ok(member, 201)
  } catch (e) {
    console.error(e)
    return err('Failed to add family member', 500)
  }
})
