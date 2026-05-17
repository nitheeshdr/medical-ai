import mongoose, { Schema, Document } from 'mongoose'

export interface IUser extends Document {
  name: string
  email: string
  phone?: string
  passwordHash: string
  role: 'user' | 'doctor' | 'admin'
  profileComplete: boolean
  subscriptionTier: 'free' | 'pro' | 'family' | 'enterprise'
  bloodType?: string
  allergies: string[]
  conditions: string[]
  medications: string[]
  dateOfBirth?: Date
  gender?: string
  fcmToken?: string
  createdAt: Date
  updatedAt: Date
}

const UserSchema = new Schema<IUser>({
  name: { type: String, required: true, trim: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  phone: { type: String },
  passwordHash: { type: String, required: true },
  role: { type: String, enum: ['user', 'doctor', 'admin'], default: 'user' },
  profileComplete: { type: Boolean, default: false },
  subscriptionTier: { type: String, enum: ['free', 'pro', 'family', 'enterprise'], default: 'free' },
  bloodType: { type: String },
  allergies: [{ type: String }],
  conditions: [{ type: String }],
  medications: [{ type: String }],
  dateOfBirth: { type: Date },
  gender: { type: String },
  fcmToken: { type: String },
}, { timestamps: true })

export const User = mongoose.models.User || mongoose.model<IUser>('User', UserSchema)
