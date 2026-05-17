import mongoose, { Schema, Document } from 'mongoose'

export interface IPayment extends Document {
  userId: mongoose.Types.ObjectId
  amount: number
  currency: string
  status: 'pending' | 'completed' | 'failed' | 'refunded'
  gateway: string
  gatewayPaymentId?: string
  purpose: 'subscription' | 'appointment' | 'medicine'
  metadata?: Record<string, unknown>
  createdAt: Date
}

const PaymentSchema = new Schema<IPayment>({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  amount: { type: Number, required: true },
  currency: { type: String, default: 'USD' },
  status: { type: String, enum: ['pending', 'completed', 'failed', 'refunded'], default: 'pending' },
  gateway: { type: String, required: true },
  gatewayPaymentId: { type: String },
  purpose: { type: String, enum: ['subscription', 'appointment', 'medicine'], required: true },
  metadata: { type: Schema.Types.Mixed },
}, { timestamps: true })

export const Payment = mongoose.models.Payment || mongoose.model<IPayment>('Payment', PaymentSchema)
