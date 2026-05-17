import mongoose, { Schema, Document } from 'mongoose'

export interface IChat extends Document {
  userId: mongoose.Types.ObjectId
  sessionId: string
  title: string
  messages: { role: 'user' | 'assistant'; content: string; timestamp: Date }[]
  language: string
  createdAt: Date
  updatedAt: Date
}

const ChatSchema = new Schema<IChat>({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  sessionId: { type: String, required: true, unique: true },
  title: { type: String, default: 'Health Consultation' },
  messages: [{
    role: { type: String, enum: ['user', 'assistant'], required: true },
    content: { type: String, required: true },
    timestamp: { type: Date, default: Date.now },
  }],
  language: { type: String, default: 'en' },
}, { timestamps: true })

export const Chat = mongoose.models.Chat || mongoose.model<IChat>('Chat', ChatSchema)
