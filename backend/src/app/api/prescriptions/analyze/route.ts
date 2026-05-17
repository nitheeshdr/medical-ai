import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Prescription } from '@/models/Prescription'
import { analyzeText } from '@/lib/openai'
import { withAuth, ok, err } from '@/lib/middleware'

const PRESCRIPTION_PROMPT = `You are a medical AI. Analyze this prescription text and return a JSON object with:
{
  "medicines": [{"name": "...", "dosage": "...", "frequency": "...", "duration": "..."}],
  "sideEffects": ["..."],
  "foodRestrictions": ["..."],
  "warnings": ["..."],
  "summary": "..."
}
Return only valid JSON.`

export const POST = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const { prescriptionId, ocrText } = await req.json()
    if (!prescriptionId || !ocrText) return err('Prescription ID and OCR text required')

    const prescription = await Prescription.findOne({ _id: prescriptionId, userId: user.userId })
    if (!prescription) return err('Prescription not found', 404)

    const raw = await analyzeText(PRESCRIPTION_PROMPT, ocrText)
    let analysis
    try {
      analysis = JSON.parse(raw)
    } catch {
      analysis = { summary: raw, medicines: [], sideEffects: [], foodRestrictions: [], warnings: [] }
    }

    prescription.ocrText = ocrText
    prescription.aiAnalysis = analysis
    await prescription.save()

    return ok(prescription)
  } catch (e) {
    console.error(e)
    return err('Analysis failed', 500)
  }
})
