import mongoose, { Schema, Document } from 'mongoose'

export interface IAppointment extends Document {
  userId: mongoose.Types.ObjectId
  doctorId: mongoose.Types.ObjectId
  slot: Date
  status: 'pending' | 'confirmed' | 'cancelled' | 'completed'
  type: 'in-person' | 'video'
  notes: string
  symptoms: string[]
  fee: number
  meetingLink?: string
  createdAt: Date
}

const AppointmentSchema = new Schema<IAppointment>({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  doctorId: { type: Schema.Types.ObjectId, ref: 'Doctor', required: true },
  slot: { type: Date, required: true },
  status: { type: String, enum: ['pending', 'confirmed', 'cancelled', 'completed'], default: 'pending' },
  type: { type: String, enum: ['in-person', 'video'], default: 'video' },
  notes: { type: String, default: '' },
  symptoms: [{ type: String }],
  fee: { type: Number, default: 0 },
  meetingLink: { type: String },
}, { timestamps: true })

export const Appointment = mongoose.models.Appointment || mongoose.model<IAppointment>('Appointment', AppointmentSchema)
