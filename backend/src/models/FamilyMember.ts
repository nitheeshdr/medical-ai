import mongoose, { Schema, Document } from 'mongoose'

export interface IFamilyMember extends Document {
  ownerId: mongoose.Types.ObjectId
  memberId?: mongoose.Types.ObjectId
  name: string
  email: string
  relation: string
  age?: number
  healthScore?: number
  permissions: string[]
  inviteStatus: 'pending' | 'accepted' | 'declined'
}

const FamilyMemberSchema = new Schema<IFamilyMember>({
  ownerId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  memberId: { type: Schema.Types.ObjectId, ref: 'User' },
  name: { type: String, required: true },
  email: { type: String, required: true },
  relation: { type: String, required: true },
  age: { type: Number },
  healthScore: { type: Number, default: 0 },
  permissions: [{ type: String }],
  inviteStatus: { type: String, enum: ['pending', 'accepted', 'declined'], default: 'pending' },
}, { timestamps: true })

export const FamilyMember = mongoose.models.FamilyMember || mongoose.model<IFamilyMember>('FamilyMember', FamilyMemberSchema)
