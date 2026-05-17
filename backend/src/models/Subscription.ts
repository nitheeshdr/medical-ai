import mongoose, { Schema, Document } from 'mongoose'

export interface ISubscription extends Document {
  userId: mongoose.Types.ObjectId
  plan: 'free' | 'pro' | 'family' | 'enterprise'
  status: 'active' | 'cancelled' | 'expired' | 'trial'
  startDate: Date
  endDate: Date
  billingCycle: 'monthly' | 'annual'
  amount: number
  features: string[]
  paymentMethod?: string
}

const SubscriptionSchema = new Schema<ISubscription>({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  plan: { type: String, enum: ['free', 'pro', 'family', 'enterprise'], required: true },
  status: { type: String, enum: ['active', 'cancelled', 'expired', 'trial'], default: 'active' },
  startDate: { type: Date, required: true },
  endDate: { type: Date, required: true },
  billingCycle: { type: String, enum: ['monthly', 'annual'], default: 'monthly' },
  amount: { type: Number, default: 0 },
  features: [{ type: String }],
  paymentMethod: { type: String },
}, { timestamps: true })

export const Subscription = mongoose.models.Subscription || mongoose.model<ISubscription>('Subscription', SubscriptionSchema)
