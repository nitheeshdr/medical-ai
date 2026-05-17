import { NextRequest, NextResponse } from 'next/server'
import { verifyToken } from '@/lib/jwt'
import { getAIClient, getDefaultModel } from '@/lib/openai'
import { connectDB } from '@/lib/mongodb'
import { Chat } from '@/models/Chat'
import { AIUsageLog } from '@/models/AIUsageLog'

const SYSTEM_PROMPT = `You are MediNova AI, a knowledgeable and empathetic healthcare assistant. You help with:
- Symptom analysis and triage guidance
- Medication information, dosages, and drug interactions
- Medical report explanations in plain language
- Healthy lifestyle recommendations (diet, sleep, exercise)
- Scheduling and appointment advice

Guidelines:
- Always recommend consulting a licensed physician for clinical decisions
- Never diagnose conditions — explain possibilities and recommend professional evaluation
- Be warm, concise, and reassuring
- If the user seems in distress or describes emergencies, advise calling emergency services immediately`

export async function POST(req: NextRequest) {
  const auth = req.headers.get('authorization')
  if (!auth?.startsWith('Bearer ')) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  let userId: string
  try {
    const payload = verifyToken(auth.slice(7))
    userId = payload.userId
  } catch {
    return NextResponse.json({ error: 'Invalid token' }, { status: 401 })
  }

  const body = await req.json()
  const { message, sessionId } = body
  if (!message?.trim()) {
    return NextResponse.json({ error: 'Message is required' }, { status: 400 })
  }

  await connectDB()

  // Fetch or create chat session
  let chat = await Chat.findOne({ sessionId, userId })
  if (!chat) {
    chat = await Chat.create({
      userId,
      sessionId: sessionId || `${userId}_${Date.now()}`,
      messages: [],
    })
  }

  // Build message history (last 10 turns for context window efficiency)
  const history = chat.messages.slice(-20).map((m: { role: string; content: string }) => ({
    role: m.role as 'user' | 'assistant',
    content: m.content,
  }))
  history.push({ role: 'user' as const, content: message })

  const aiClient = getAIClient()
  const model = getDefaultModel()
  const start = Date.now()

  const stream = await aiClient.chat.completions.create({
    model,
    messages: [{ role: 'system', content: SYSTEM_PROMPT }, ...history],
    stream: true,
    temperature: 0.6,
    top_p: 0.9,
    max_tokens: 1024,
  })

  let fullResponse = ''
  const encoder = new TextEncoder()

  const readable = new ReadableStream({
    async start(controller) {
      try {
        for await (const chunk of stream) {
          const text = chunk.choices[0]?.delta?.content || ''
          fullResponse += text
          if (text) {
            controller.enqueue(encoder.encode(`data: ${JSON.stringify({ text })}\n\n`))
          }
        }

        // Persist messages
        await Chat.findByIdAndUpdate(chat._id, {
          $push: {
            messages: {
              $each: [
                { role: 'user', content: message, timestamp: new Date() },
                { role: 'assistant', content: fullResponse, timestamp: new Date() },
              ],
            },
          },
        })

        // Log AI usage
        const estimatedTokens = Math.ceil((SYSTEM_PROMPT.length + message.length + fullResponse.length) / 4)
        await AIUsageLog.create({
          userId,
          feature: 'chat',
          aiModel: model,
          tokensUsed: estimatedTokens,
          cost: estimatedTokens * 0.0000002, // approx NVIDIA NIM pricing
          responseTime: Date.now() - start,
        })

        controller.enqueue(encoder.encode('data: [DONE]\n\n'))
      } finally {
        controller.close()
      }
    },
  })

  return new NextResponse(readable, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      Connection: 'keep-alive',
      'X-AI-Model': model,
    },
  })
}
