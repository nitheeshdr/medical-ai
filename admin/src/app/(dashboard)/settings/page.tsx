'use client'
import { useState, useEffect, useCallback } from 'react'
import { Shield, Bell, Key, Globe, Database, Mail, Save, RefreshCw, Eye, EyeOff, CheckCircle, AlertCircle, Loader2 } from 'lucide-react'

// ── types ──────────────────────────────────────────────────────────────────
interface Settings {
  platformName: string
  supportEmail: string
  baseUrl: string
  adminUrl: string
  description: string
  maintenanceMode: boolean
  twoFactorRequired: boolean
  ipWhitelistEnabled: boolean
  allowedIPs: string
  auditLogging: boolean
  sessionTimeoutMinutes: number
  alertEmail: boolean
  alertSms: boolean
  alertSlack: boolean
  alertPagerDuty: boolean
  slackWebhookUrl: string
  defaultChatModel: string
  visionModel: string
  maxTokensPerRequest: number
  dailySpendLimitUSD: number
  freePlanDailyAICalls: number
  dataRetentionDays: number
  backupFrequency: string
}

const DEFAULTS: Settings = {
  platformName: 'MediNova AI',
  supportEmail: 'support@medinova.ai',
  baseUrl: 'https://app.medinova.ai',
  adminUrl: 'https://admin.medinova.ai',
  description: 'AI-powered healthcare platform.',
  maintenanceMode: false,
  twoFactorRequired: true,
  ipWhitelistEnabled: false,
  allowedIPs: '',
  auditLogging: true,
  sessionTimeoutMinutes: 30,
  alertEmail: true,
  alertSms: false,
  alertSlack: true,
  alertPagerDuty: false,
  slackWebhookUrl: '',
  defaultChatModel: 'gpt-4o-mini',
  visionModel: 'gpt-4o',
  maxTokensPerRequest: 4096,
  dailySpendLimitUSD: 500,
  freePlanDailyAICalls: 10,
  dataRetentionDays: 365,
  backupFrequency: 'Daily',
}

// ── sub-components ─────────────────────────────────────────────────────────
function Section({ title, icon: Icon, description, children }: { title: string; icon: React.ElementType; description: string; children: React.ReactNode }) {
  return (
    <div className="bg-surface border border-border rounded-xl p-5">
      <div className="mb-5 pb-4 border-b border-border flex items-start gap-3">
        <div className="p-1.5 rounded-lg bg-elevated border border-border mt-0.5">
          <Icon size={13} className="text-secondary" />
        </div>
        <div>
          <h3 className="text-white font-semibold text-sm">{title}</h3>
          <p className="text-secondary text-xs mt-0.5">{description}</p>
        </div>
      </div>
      <div className="space-y-4">{children}</div>
    </div>
  )
}

function Toggle({ label, sub, checked, onChange }: { label: string; sub?: string; checked: boolean; onChange: () => void }) {
  return (
    <div className="flex items-center justify-between">
      <div>
        <p className="text-white text-sm">{label}</p>
        {sub && <p className="text-secondary text-xs mt-0.5">{sub}</p>}
      </div>
      <button
        onClick={onChange}
        className={`relative inline-flex h-5 w-9 rounded-full transition-colors ${checked ? 'bg-white' : 'bg-border'}`}
      >
        <span className={`absolute top-0.5 left-0.5 w-4 h-4 rounded-full bg-black transition-transform ${checked ? 'translate-x-4' : 'translate-x-0'}`} />
      </button>
    </div>
  )
}

function Field({
  label, value, type = 'text', placeholder, onChange,
}: {
  label: string; value?: string | number; type?: string; placeholder?: string
  onChange?: (v: string) => void
}) {
  const [show, setShow] = useState(false)
  const isPassword = type === 'password'
  return (
    <div>
      <label className="text-secondary text-xs mb-1.5 block">{label}</label>
      <div className="relative">
        <input
          type={isPassword && !show ? 'password' : 'text'}
          value={value ?? ''}
          placeholder={placeholder}
          onChange={(e) => onChange?.(e.target.value)}
          className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white placeholder:text-secondary focus:outline-none focus:border-white/30 pr-10"
        />
        {isPassword && (
          <button onClick={() => setShow(v => !v)} className="absolute right-3 top-1/2 -translate-y-1/2 text-secondary hover:text-white">
            {show ? <EyeOff size={14} /> : <Eye size={14} />}
          </button>
        )}
      </div>
    </div>
  )
}

function NumberField({ label, value, onChange }: { label: string; value: number; onChange: (v: number) => void }) {
  return (
    <div>
      <label className="text-secondary text-xs mb-1.5 block">{label}</label>
      <input
        type="number"
        value={value}
        onChange={(e) => onChange(Number(e.target.value))}
        className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30"
      />
    </div>
  )
}

function SelectField({ label, value, options, onChange }: { label: string; value: string; options: string[]; onChange: (v: string) => void }) {
  return (
    <div>
      <label className="text-secondary text-xs mb-1.5 block">{label}</label>
      <select
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30"
      >
        {options.map(o => <option key={o}>{o}</option>)}
      </select>
    </div>
  )
}

// ── page ───────────────────────────────────────────────────────────────────
export default function SettingsPage() {
  const [s, setS] = useState<Settings>(DEFAULTS)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [toast, setToast] = useState<{ msg: string; ok: boolean } | null>(null)

  const set = useCallback(<K extends keyof Settings>(key: K, val: Settings[K]) => {
    setS(prev => ({ ...prev, [key]: val }))
  }, [])

  // Load settings from backend
  useEffect(() => {
    fetch('/api/settings')
      .then(r => r.ok ? r.json() : null)
      .then(d => {
        if (d) setS({ ...DEFAULTS, ...d })
        setLoading(false)
      })
      .catch(() => setLoading(false))
  }, [])

  const showToast = (msg: string, ok: boolean) => {
    setToast({ msg, ok })
    setTimeout(() => setToast(null), 3500)
  }

  const handleSave = async () => {
    setSaving(true)
    try {
      const res = await fetch('/api/settings', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(s),
      })
      if (res.ok) showToast('Settings saved successfully', true)
      else showToast('Failed to save settings', false)
    } catch {
      showToast('Network error', false)
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 size={20} className="text-secondary animate-spin" />
        <span className="ml-2 text-secondary text-sm">Loading settings…</span>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Toast */}
      {toast && (
        <div className={`fixed top-4 right-4 z-50 flex items-center gap-2 px-4 py-2.5 rounded-lg border text-sm font-medium shadow-xl transition-all ${
          toast.ok ? 'bg-surface border-success/40 text-success' : 'bg-surface border-red-500/40 text-red-400'
        }`}>
          {toast.ok ? <CheckCircle size={14} /> : <AlertCircle size={14} />}
          {toast.msg}
        </div>
      )}

      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-white">Settings</h1>
          <p className="text-secondary text-sm mt-0.5">Platform configuration and admin preferences</p>
        </div>
        <button
          onClick={handleSave}
          disabled={saving}
          className="flex items-center gap-2 text-sm bg-white text-black rounded-lg px-4 py-2 font-medium hover:bg-white/90 transition-colors disabled:opacity-50"
        >
          {saving ? <Loader2 size={14} className="animate-spin" /> : <Save size={14} />}
          {saving ? 'Saving…' : 'Save All'}
        </button>
      </div>

      {/* General */}
      <Section title="General" icon={Globe} description="Basic platform settings and branding">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <Field label="Platform Name" value={s.platformName} onChange={v => set('platformName', v)} />
          <Field label="Support Email" value={s.supportEmail} onChange={v => set('supportEmail', v)} />
          <Field label="Base URL" value={s.baseUrl} onChange={v => set('baseUrl', v)} />
          <Field label="Admin Portal URL" value={s.adminUrl} onChange={v => set('adminUrl', v)} />
        </div>
        <div>
          <label className="text-secondary text-xs mb-1.5 block">Platform Description</label>
          <textarea
            value={s.description}
            onChange={(e) => set('description', e.target.value)}
            rows={2}
            className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white placeholder:text-secondary focus:outline-none focus:border-white/30 resize-none"
          />
        </div>
        <div className="flex items-center justify-between pt-2">
          <div>
            <p className="text-white text-sm">Maintenance Mode</p>
            <p className="text-secondary text-xs mt-0.5">Disables user access and shows maintenance page</p>
          </div>
          <div className="flex items-center gap-3">
            {s.maintenanceMode && <span className="text-xs text-yellow-400">Active</span>}
            <button
              onClick={() => set('maintenanceMode', !s.maintenanceMode)}
              className={`relative inline-flex h-5 w-9 rounded-full transition-colors ${s.maintenanceMode ? 'bg-yellow-400' : 'bg-border'}`}
            >
              <span className={`absolute top-0.5 left-0.5 w-4 h-4 rounded-full bg-black transition-transform ${s.maintenanceMode ? 'translate-x-4' : 'translate-x-0'}`} />
            </button>
          </div>
        </div>
      </Section>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Security */}
        <Section title="Security" icon={Shield} description="Access control and authentication settings">
          <Toggle label="Two-Factor Authentication" sub="Require 2FA for all admin accounts" checked={s.twoFactorRequired} onChange={() => set('twoFactorRequired', !s.twoFactorRequired)} />
          <Toggle label="IP Whitelist" sub="Restrict admin access to specific IPs" checked={s.ipWhitelistEnabled} onChange={() => set('ipWhitelistEnabled', !s.ipWhitelistEnabled)} />
          <Toggle label="Audit Logging" sub="Log all admin actions with timestamps" checked={s.auditLogging} onChange={() => set('auditLogging', !s.auditLogging)} />
          <NumberField label="Session Timeout (minutes)" value={s.sessionTimeoutMinutes} onChange={v => set('sessionTimeoutMinutes', v)} />
          {s.ipWhitelistEnabled && (
            <Field label="Allowed IPs (comma-separated)" value={s.allowedIPs} placeholder="192.168.1.0/24, 10.0.0.1" onChange={v => set('allowedIPs', v)} />
          )}
        </Section>

        {/* Alert Notifications */}
        <Section title="Alert Notifications" icon={Bell} description="Where to send system alerts and reports">
          <Toggle label="Email Alerts" sub="Critical system alerts via email" checked={s.alertEmail} onChange={() => set('alertEmail', !s.alertEmail)} />
          <Toggle label="SMS Alerts" sub="Emergency alerts via SMS" checked={s.alertSms} onChange={() => set('alertSms', !s.alertSms)} />
          <Toggle label="Slack Integration" sub="Post alerts to Slack channel" checked={s.alertSlack} onChange={() => set('alertSlack', !s.alertSlack)} />
          <Toggle label="PagerDuty" sub="On-call escalation for incidents" checked={s.alertPagerDuty} onChange={() => set('alertPagerDuty', !s.alertPagerDuty)} />
          {s.alertSlack && (
            <Field label="Slack Webhook URL" value={s.slackWebhookUrl} placeholder="https://hooks.slack.com/services/..." onChange={v => set('slackWebhookUrl', v)} />
          )}
        </Section>
      </div>

      {/* AI Config */}
      <Section title="AI Configuration" icon={Key} description="Model selection, limits, and cost controls">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <SelectField label="Default Chat Model" value={s.defaultChatModel} options={['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo', 'meta/llama-3.1-70b-instruct']} onChange={v => set('defaultChatModel', v)} />
          <SelectField label="Vision / OCR Model" value={s.visionModel} options={['gpt-4o', 'gpt-4-vision-preview']} onChange={v => set('visionModel', v)} />
          <NumberField label="Max Tokens / Request" value={s.maxTokensPerRequest} onChange={v => set('maxTokensPerRequest', v)} />
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <NumberField label="Daily Spend Limit ($)" value={s.dailySpendLimitUSD} onChange={v => set('dailySpendLimitUSD', v)} />
          <NumberField label="Free Plan Daily AI Calls" value={s.freePlanDailyAICalls} onChange={v => set('freePlanDailyAICalls', v)} />
        </div>
      </Section>

      {/* Data & Storage */}
      <Section title="Data & Storage" icon={Database} description="Backup, retention, and storage configuration">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <NumberField label="Data Retention (days)" value={s.dataRetentionDays} onChange={v => set('dataRetentionDays', v)} />
          <SelectField label="Backup Frequency" value={s.backupFrequency} options={['Hourly', 'Daily', 'Weekly']} onChange={v => set('backupFrequency', v)} />
        </div>
        <div className="flex items-center gap-3 pt-2">
          <button className="flex items-center gap-2 text-xs border border-border text-secondary rounded-lg px-3 py-1.5 hover:text-white transition-colors">
            <Database size={12} /> Manual Backup
          </button>
          <button className="flex items-center gap-2 text-xs border border-border text-secondary rounded-lg px-3 py-1.5 hover:text-white transition-colors">
            <Globe size={12} /> Export Data
          </button>
          <button className="flex items-center gap-2 text-xs border border-border text-secondary rounded-lg px-3 py-1.5 hover:text-white transition-colors">
            <Mail size={12} /> GDPR Report
          </button>
          <button className="flex items-center gap-2 text-xs border border-border text-secondary rounded-lg px-3 py-1.5 hover:text-white transition-colors">
            <RefreshCw size={12} /> Rotate JWT
          </button>
        </div>
      </Section>
    </div>
  )
}
