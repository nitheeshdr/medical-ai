import mongoose, { Schema, Document } from 'mongoose'

export interface INotification extends Document {
  userId: mongoose.Types.ObjectId
  type: 'medicine_reminder' | 'appointment' | 'lab_result' | 'health_tip' | 'emergency' | 'system'
  title: string
  body: string
  read: boolean
  data?: Record<string, unknown>
  createdAt: Date
}

const NotificationSchema = new Schema<INotification>({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  type: {
    type: String,
    enum: ['medicine_reminder', 'appointment', 'lab_result', 'health_tip', 'emergency', 'system'],
    required: true,
  },
  title: { type: String, required: true },
  body: { type: String, required: true },
  read: { type: Boolean, default: false },
  data: { type: Schema.Types.Mixed },
}, { timestamps: true })

NotificationSchema.index({ userId: 1, createdAt: -1 })

export const Notification = mongoose.models.Notification || mongoose.model<INotification>('Notification', NotificationSchema)
