import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Report } from '@/models/Report'
import { analyzeText, analyzeImageWithVision } from '@/lib/openai'
import { withAuth, ok, err } from '@/lib/middleware'

const REPORT_PROMPT = `You are a medical AI assistant. Analyze this medical report/prescription image and return JSON:
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
    const { reportId, extractedText, imageBase64, mimeType = 'image/jpeg' } = await req.json()
    if (!reportId) return err('Report ID required')

    const report = await Report.findOne({ _id: reportId, userId: user.userId })
    if (!report) return err('Report not found', 404)

    let raw = ''
    
    if (imageBase64) {
      raw = await analyzeImageWithVision(imageBase64, mimeType, REPORT_PROMPT)
    } else {
      const content = extractedText || `${report.type} medical report for analysis.`
      raw = await analyzeText(REPORT_PROMPT, content)
    }

    // Clean markdown code blocks from JSON response
    const cleanedRaw = raw.replace(/```json\n?|\n?```/g, '').trim()

    let analysis
    try {
      analysis = JSON.parse(cleanedRaw)
    } catch {
      analysis = { summary: cleanedRaw, highlights: [], recommendations: [], needsAttention: false }
    }

    report.aiAnalysis = analysis
    await report.save()

    return ok(report)
  } catch (e) {
    console.error(e)
    return err('Analysis failed', 500)
  }
})
