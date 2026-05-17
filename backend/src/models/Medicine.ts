import mongoose, { Schema, Document } from 'mongoose'

export interface IMedicine extends Document {
  name: string
  genericName: string
  manufacturer: string
  category: string
  dosage: string
  description: string
  price: number
  stock: number
  requiresPrescription: boolean
  sideEffects: string[]
  imageUrl: string
}

const MedicineSchema = new Schema<IMedicine>({
  name: { type: String, required: true },
  genericName: { type: String },
  manufacturer: { type: String },
  category: { type: String, required: true },
  dosage: { type: String },
  description: { type: String },
  price: { type: Number, required: true },
  stock: { type: Number, default: 0 },
  requiresPrescription: { type: Boolean, default: false },
  sideEffects: [{ type: String }],
  imageUrl: { type: String },
}, { timestamps: true })

MedicineSchema.index({ name: 'text', genericName: 'text', category: 'text' })

export const Medicine = mongoose.models.Medicine || mongoose.model<IMedicine>('Medicine', MedicineSchema)
