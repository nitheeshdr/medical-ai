import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { HealthMetric } from '@/models/HealthMetric'
import { analyzeText } from '@/lib/openai'
import { withAuth, ok, err } from '@/lib/middleware'

export const GET = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const since = new Date()
    since.setDate(since.getDate() - 7)

    const metrics = await HealthMetric.find({ userId: user.userId, timestamp: { $gte: since } })
      .sort({ timestamp: -1 })
      .lean()

    const metricsText = metrics.map(m => `${m.type}: ${m.value}${m.unit}`).join(', ')

    const prompt = `You are a wellness AI. Based on these health metrics from the past 7 days, generate wellness recommendations as JSON:
{
  "overallScore": 0-100,
  "dimensions": [{"label": "...", "score": 0-100}],
  "recommendations": [{"title": "...", "description": "...", "priority": "high|medium|low"}]
}
Return only valid JSON.`

    const raw = await analyzeText(prompt, metricsText || 'No metrics available')
    let wellness
    try {
      wellness = JSON.parse(raw)
    } catch {
      wellness = { overallScore: 75, dimensions: [], recommendations: [] }
    }

    return ok(wellness)
  } catch (e) {
    console.error(e)
    return err('Failed to generate wellness insights', 500)
  }
})
