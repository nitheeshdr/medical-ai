import mongoose, { Schema, Document } from 'mongoose'

export interface IEmergencyContact extends Document {
  userId: mongoose.Types.ObjectId
  name: string
  phone: string
  relation: string
  priority: number
  isDoctor: boolean
}

const EmergencyContactSchema = new Schema<IEmergencyContact>({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String, required: true },
  phone: { type: String, required: true },
  relation: { type: String, required: true },
  priority: { type: Number, default: 1 },
  isDoctor: { type: Boolean, default: false },
}, { timestamps: true })

export const EmergencyContact = mongoose.models.EmergencyContact || mongoose.model<IEmergencyContact>('EmergencyContact', EmergencyContactSchema)
