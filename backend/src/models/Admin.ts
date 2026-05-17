import mongoose, { Schema, Document } from 'mongoose'

export interface IAdmin extends Document {
  name: string
  email: string
  passwordHash: string
  role: 'super_admin' | 'admin' | 'analyst'
  permissions: string[]
  lastLogin?: Date
}

const AdminSchema = new Schema<IAdmin>({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  passwordHash: { type: String, required: true },
  role: { type: String, enum: ['super_admin', 'admin', 'analyst'], default: 'admin' },
  permissions: [{ type: String }],
  lastLogin: { type: Date },
}, { timestamps: true })

export const Admin = mongoose.models.Admin || mongoose.model<IAdmin>('Admin', AdminSchema)
