import mongoose, { Schema, Document } from 'mongoose'

export interface IDoctor extends Document {
  name: string
  email: string
  specialization: string
  license: string
  qualifications: string[]
  experience: number
  consultationFee: number
  availability: { day: string; slots: string[] }[]
  ratings: { userId: string; rating: number; review: string }[]
  averageRating: number
  bio: string
  location: string
  languages: string[]
  isVerified: boolean
}

const DoctorSchema = new Schema<IDoctor>({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  specialization: { type: String, required: true },
  license: { type: String, required: true },
  qualifications: [{ type: String }],
  experience: { type: Number, default: 0 },
  consultationFee: { type: Number, required: true },
  availability: [{
    day: String,
    slots: [String],
  }],
  ratings: [{
    userId: { type: Schema.Types.ObjectId, ref: 'User' },
    rating: Number,
    review: String,
  }],
  averageRating: { type: Number, default: 0 },
  bio: { type: String },
  location: { type: String },
  languages: [{ type: String }],
  isVerified: { type: Boolean, default: false },
}, { timestamps: true })

export const Doctor = mongoose.models.Doctor || mongoose.model<IDoctor>('Doctor', DoctorSchema)
