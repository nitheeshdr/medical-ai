import { NextRequest } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { Prescription } from '@/models/Prescription'
import { AIUsageLog } from '@/models/AIUsageLog'
import { analyzeImageWithVision, analyzeText, getDefaultModel } from '@/lib/openai'
import { withAuth, ok, err } from '@/lib/middleware'

const PRESCRIPTION_SYSTEM_PROMPT = `You are a medical AI assistant specializing in prescription analysis.
Extract and analyze all information from this prescription and return a JSON object:
{
  "ocrText": "raw text extracted from the prescription",
  "medicines": [
    {"name": "medicine name", "dosage": "e.g. 500mg", "frequency": "e.g. twice daily", "duration": "e.g. 30 days"}
  ],
  "sideEffects": ["list of common side effects"],
  "foodRestrictions": ["list of food/drink restrictions"],
  "warnings": ["important warnings or contraindications"],
  "summary": "brief 1-2 sentence summary of the prescription"
}
Return only valid JSON. If you cannot read something clearly, indicate it with "unclear".`

export const POST = withAuth(async (req: NextRequest, user) => {
  try {
    await connectDB()
    const body = await req.json()
    const { imageBase64, mimeType = 'image/jpeg', prescriptionId } = body

    if (!imageBase64) return err('Image data (base64) is required')

    const start = Date.now()
    let raw: string

    try {
      raw = await analyzeImageWithVision(imageBase64, mimeType, PRESCRIPTION_SYSTEM_PROMPT)
    } catch (visionErr) {
      // Fallback to text-only if vision fails
      raw = await analyzeText(
        PRESCRIPTION_SYSTEM_PROMPT,
        'Unable to process image directly. Please provide extracted text if available.'
      )
    }

    let analysis: {
      ocrText?: string
      medicines: { name: string; dosage: string; frequency: string; duration: string }[]
      sideEffects: string[]
      foodRestrictions: string[]
      warnings: string[]
      summary: string
    }

    try {
      // Strip markdown code fences if present
      const cleaned = raw.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim()
      analysis = JSON.parse(cleaned)
    } catch {
      analysis = {
        ocrText: raw,
        medicines: [],
        sideEffects: [],
        foodRestrictions: [],
        warnings: [],
        summary: raw.slice(0, 200),
      }
    }

    // Persist or update prescription record
    let prescription
    if (prescriptionId) {
      prescription = await Prescription.findOneAndUpdate(
        { _id: prescriptionId, userId: user.userId },
        {
          ocrText: analysis.ocrText || '',
          aiAnalysis: {
            medicines: analysis.medicines || [],
            sideEffects: analysis.sideEffects || [],
            foodRestrictions: analysis.foodRestrictions || [],
            warnings: analysis.warnings || [],
            summary: analysis.summary || '',
          },
        },
        { new: true }
      )
    } else {
      prescription = await Prescription.create({
        userId: user.userId,
        imageUrl: `data:${mimeType};base64,${imageBase64.slice(0, 50)}...`, // store reference
        ocrText: analysis.ocrText || '',
        aiAnalysis: {
          medicines: analysis.medicines || [],
          sideEffects: analysis.sideEffects || [],
          foodRestrictions: analysis.foodRestrictions || [],
          warnings: analysis.warnings || [],
          summary: analysis.summary || '',
        },
      })
    }

    // Log AI usage
    const estimatedTokens = Math.ceil((raw.length + imageBase64.length / 4) / 4)
    await AIUsageLog.create({
      userId: user.userId,
      feature: 'prescription_scan',
      aiModel: process.env.NVIDIA_API_KEY ? 'nvidia/llama-3.2-11b-vision-instruct' : getDefaultModel(),
      tokensUsed: estimatedTokens,
      cost: estimatedTokens * 0.0000003,
      responseTime: Date.now() - start,
    })

    return ok({ prescription, analysis })
  } catch (e) {
    console.error('Scan error:', e)
    return err('Failed to analyze prescription', 500)
  }
})
