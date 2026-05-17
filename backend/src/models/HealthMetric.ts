import mongoose, { Schema, Document } from 'mongoose'

export interface IHealthMetric extends Document {
  userId: mongoose.Types.ObjectId
  type: 'heart_rate' | 'blood_pressure' | 'temperature' | 'spo2' | 'weight' | 'steps' | 'sleep' | 'water' | 'calories'
  value: number
  secondaryValue?: number
  unit: string
  timestamp: Date
  source: 'manual' | 'wearable' | 'scanner'
}

const HealthMetricSchema = new Schema<IHealthMetric>({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  type: {
    type: String,
    enum: ['heart_rate', 'blood_pressure', 'temperature', 'spo2', 'weight', 'steps', 'sleep', 'water', 'calories'],
    required: true,
  },
  value: { type: Number, required: true },
  secondaryValue: { type: Number },
  unit: { type: String, required: true },
  timestamp: { type: Date, default: Date.now },
  source: { type: String, enum: ['manual', 'wearable', 'scanner'], default: 'manual' },
}, { timestamps: false })

HealthMetricSchema.index({ userId: 1, type: 1, timestamp: -1 })

export const HealthMetric = mongoose.models.HealthMetric || mongoose.model<IHealthMetric>('HealthMetric', HealthMetricSchema)
