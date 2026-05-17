import mongoose, { Schema, Document } from 'mongoose'

export interface IReport extends Document {
  userId: mongoose.Types.ObjectId
  type: 'blood' | 'mri' | 'ecg' | 'ct' | 'xray' | 'diabetes' | 'other'
  fileUrl: string
  fileName: string
  fileSize: number
  aiAnalysis: {
    summary: string
    highlights: { label: string; value: string; status: 'normal' | 'high' | 'low' | 'critical' }[]
    recommendations: string[]
    needsAttention: boolean
  }
  createdAt: Date
}

const ReportSchema = new Schema<IReport>({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  type: { type: String, enum: ['blood', 'mri', 'ecg', 'ct', 'xray', 'diabetes', 'other'], required: true },
  fileUrl: { type: String, required: true },
  fileName: { type: String, required: true },
  fileSize: { type: Number, default: 0 },
  aiAnalysis: {
    summary: String,
    highlights: [{ label: String, value: String, status: String }],
    recommendations: [String],
    needsAttention: { type: Boolean, default: false },
  },
}, { timestamps: true })

export const Report = mongoose.models.Report || mongoose.model<IReport>('Report', ReportSchema)
