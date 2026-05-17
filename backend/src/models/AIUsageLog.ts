import mongoose, { Schema, Document } from 'mongoose'

export interface IAIUsageLog extends Document {
  userId: mongoose.Types.ObjectId
  feature: 'chat' | 'prescription_scan' | 'report_analysis' | 'wellness'
  aiModel: string
  tokensUsed: number
  cost: number
  responseTime: number
  createdAt: Date
}

const AIUsageLogSchema = new Schema<IAIUsageLog>({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  feature: { type: String, enum: ['chat', 'prescription_scan', 'report_analysis', 'wellness'], required: true },
  aiModel: { type: String, default: 'gpt-4o-mini' },
  tokensUsed: { type: Number, default: 0 },
  cost: { type: Number, default: 0 },
  responseTime: { type: Number, default: 0 },
}, { timestamps: true })

AIUsageLogSchema.index({ userId: 1, createdAt: -1 })
AIUsageLogSchema.index({ feature: 1, createdAt: -1 })

export const AIUsageLog = mongoose.models.AIUsageLog || mongoose.model<IAIUsageLog>('AIUsageLog', AIUsageLogSchema)
