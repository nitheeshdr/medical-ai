import mongoose, { Schema, Document } from 'mongoose'

export interface IPlatformSettings extends Document {
  // General
  platformName: string
  supportEmail: string
  baseUrl: string
  adminUrl: string
  description: string
  maintenanceMode: boolean

  // Security
  twoFactorRequired: boolean
  ipWhitelistEnabled: boolean
  allowedIPs: string
  auditLogging: boolean
  sessionTimeoutMinutes: number

  // Alert channels
  alertEmail: boolean
  alertSms: boolean
  alertSlack: boolean
  alertPagerDuty: boolean
  slackWebhookUrl: string

  // AI config
  defaultChatModel: string
  visionModel: string
  maxTokensPerRequest: number
  dailySpendLimitUSD: number
  freePlanDailyAICalls: number

  // Data & storage
  dataRetentionDays: number
  backupFrequency: string
}

const PlatformSettingsSchema = new Schema<IPlatformSettings>(
  {
    platformName: { type: String, default: 'MediNova AI' },
    supportEmail: { type: String, default: 'support@medinova.ai' },
    baseUrl: { type: String, default: 'https://app.medinova.ai' },
    adminUrl: { type: String, default: 'https://admin.medinova.ai' },
    description: { type: String, default: 'AI-powered healthcare platform.' },
    maintenanceMode: { type: Boolean, default: false },

    twoFactorRequired: { type: Boolean, default: true },
    ipWhitelistEnabled: { type: Boolean, default: false },
    allowedIPs: { type: String, default: '' },
    auditLogging: { type: Boolean, default: true },
    sessionTimeoutMinutes: { type: Number, default: 30 },

    alertEmail: { type: Boolean, default: true },
    alertSms: { type: Boolean, default: false },
    alertSlack: { type: Boolean, default: true },
    alertPagerDuty: { type: Boolean, default: false },
    slackWebhookUrl: { type: String, default: '' },

    defaultChatModel: { type: String, default: 'gpt-4o-mini' },
    visionModel: { type: String, default: 'gpt-4o' },
    maxTokensPerRequest: { type: Number, default: 4096 },
    dailySpendLimitUSD: { type: Number, default: 500 },
    freePlanDailyAICalls: { type: Number, default: 10 },

    dataRetentionDays: { type: Number, default: 365 },
    backupFrequency: { type: String, default: 'Daily' },
  },
  { timestamps: true }
)

export const PlatformSettings =
  mongoose.models.PlatformSettings ||
  mongoose.model<IPlatformSettings>('PlatformSettings', PlatformSettingsSchema)
