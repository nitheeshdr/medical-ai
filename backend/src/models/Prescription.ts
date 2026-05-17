import mongoose, { Schema, Document } from 'mongoose'

export interface IPrescription extends Document {
  userId: mongoose.Types.ObjectId
  imageUrl: string
  ocrText: string
  aiAnalysis: {
    medicines: { name: string; dosage: string; frequency: string; duration: string }[]
    sideEffects: string[]
    foodRestrictions: string[]
    warnings: string[]
    summary: string
  }
  reminders: { medicineId: string; times: string[]; active: boolean }[]
  createdAt: Date
}

const PrescriptionSchema = new Schema<IPrescription>({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  imageUrl: { type: String, required: true },
  ocrText: { type: String, default: '' },
  aiAnalysis: {
    medicines: [{ name: String, dosage: String, frequency: String, duration: String }],
    sideEffects: [String],
    foodRestrictions: [String],
    warnings: [String],
    summary: String,
  },
  reminders: [{ medicineId: String, times: [String], active: { type: Boolean, default: true } }],
}, { timestamps: true })

export const Prescription = mongoose.models.Prescription || mongoose.model<IPrescription>('Prescription', PrescriptionSchema)
