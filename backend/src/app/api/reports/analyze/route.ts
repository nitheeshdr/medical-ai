import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Report } from '@/models/Report'
import { analyzeText } from '@/lib/openai'
import { withAuth, ok, err } from '@/lib/middleware'

const REPORT_PROMPT = `You are a medical AI assistant. Analyze this medical report data and return JSON:
{
  "summary": "Plain English summary for patient",
  "highlights": [{"label": "...", "value": "...", "status": "normal|high|low|critical"}],
  "recommendations": ["..."],
  "needsAttention": true|false
}
Return only valid JSON.`

export const POST = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const { reportId, extractedText } = await req.json()
    if (!reportId) return err('Report ID required')

    const report = await Report.findOne({ _id: reportId, userId: user.userId })
    if (!report) return err('Report not found', 404)

    const content = extractedText || `${report.type} medical report for analysis.`
    const raw = await analyzeText(REPORT_PROMPT, content)
    let analysis
    try {
      analysis = JSON.parse(raw)
    } catch {
      analysis = { summary: raw, highlights: [], recommendations: [], needsAttention: false }
    }

    report.aiAnalysis = analysis
    await report.save()

    return ok(report)
  } catch (e) {
    console.error(e)
    return err('Analysis failed', 500)
  }
})
