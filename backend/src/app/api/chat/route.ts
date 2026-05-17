import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Chat } from '@/models/Chat'
import { withAuth, ok, err } from '@/lib/middleware'

// GET /api/chat — list all chat sessions for the authenticated user
export const GET = withAuth(async (_req: NextRequest, user) => {
  try {
    await connectDB()
    const sessions = await Chat.find({ userId: user.userId })
      .select('sessionId title createdAt updatedAt messages')
      .sort({ updatedAt: -1 })
      .lean()

    const result = sessions.map((s) => ({
      sessionId: s.sessionId,
      title: s.title,
      messageCount: (s.messages as unknown[]).length,
      lastMessage: (s.messages as { content: string; role: string }[]).at(-1)?.content?.slice(0, 80) ?? '',
      createdAt: s.createdAt,
      updatedAt: s.updatedAt,
    }))

    return ok(result)
  } catch (e) {
    console.error(e)
    return err('Failed to fetch chat sessions', 500)
  }
})

// DELETE /api/chat — clear all sessions for the user
export const DELETE = withAuth(async (_req: NextRequest, user) => {
  try {
    await connectDB()
    await Chat.deleteMany({ userId: user.userId })
    return ok({ deleted: true })
  } catch (e) {
    console.error(e)
    return err('Failed to clear chat history', 500)
  }
})
