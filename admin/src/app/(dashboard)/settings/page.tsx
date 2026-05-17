'use client'
import { useState } from 'react'
import { Shield, Bell, Key, Globe, Database, Mail, Save, RefreshCw, Eye, EyeOff } from 'lucide-react'

function Section({ title, description, children }: { title: string; description: string; children: React.ReactNode }) {
  return (
    <div className="bg-surface border border-border rounded-xl p-5">
      <div className="mb-5 pb-4 border-b border-border">
        <h3 className="text-white font-semibold">{title}</h3>
        <p className="text-secondary text-xs mt-0.5">{description}</p>
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

function Field({ label, value, type = 'text', placeholder }: { label: string; value?: string; type?: string; placeholder?: string }) {
  const [show, setShow] = useState(false)
  const isPassword = type === 'password'
  return (
    <div>
      <label className="text-secondary text-xs mb-1.5 block">{label}</label>
      <div className="relative">
        <input
          type={isPassword && !show ? 'password' : 'text'}
          defaultValue={value}
          placeholder={placeholder}
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

export default function SettingsPage() {
  const [notifs, setNotifs] = useState({ email: true, sms: false, slack: true, pagerduty: false })
  const [security, setSecurity] = useState({ twoFactor: true, ipWhitelist: false, auditLog: true, sessionTimeout: true })
  const [maintenance, setMaintenance] = useState(false)

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-white">Settings</h1>
          <p className="text-secondary text-sm mt-0.5">Platform configuration and admin preferences</p>
        </div>
        <button className="flex items-center gap-2 text-sm bg-white text-black rounded-lg px-4 py-2 font-medium hover:bg-white/90 transition-colors">
          <Save size={14} />
          Save All
        </button>
      </div>

      {/* General */}
      <Section title="General" description="Basic platform settings and branding">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <Field label="Platform Name" value="MediNova AI" />
          <Field label="Support Email" value="support@medinova.ai" />
          <Field label="Base URL" value="https://app.medinova.ai" />
          <Field label="Admin Portal URL" value="https://admin.medinova.ai" />
        </div>
        <div>
          <label className="text-secondary text-xs mb-1.5 block">Platform Description</label>
          <textarea
            defaultValue="AI-powered healthcare platform providing intelligent medical analysis, doctor consultations, and health monitoring."
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
            {maintenance && <span className="text-xs text-yellow-400">Active</span>}
            <button
              onClick={() => setMaintenance(v => !v)}
              className={`relative inline-flex h-5 w-9 rounded-full transition-colors ${maintenance ? 'bg-yellow-400' : 'bg-border'}`}
            >
              <span className={`absolute top-0.5 left-0.5 w-4 h-4 rounded-full bg-black transition-transform ${maintenance ? 'translate-x-4' : 'translate-x-0'}`} />
            </button>
          </div>
        </div>
      </Section>

      {/* API Keys */}
      <Section title="API Keys" description="Third-party service credentials">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <Field label="OpenAI API Key" value="sk-proj-xxxx" type="password" />
          <Field label="MongoDB URI" value="mongodb+srv://xxx" type="password" />
          <Field label="JWT Secret" type="password" placeholder="Enter JWT secret..." />
          <Field label="Firebase Project ID" value="medinova-ai" />
          <Field label="Stripe Secret Key" type="password" placeholder="sk_live_..." />
          <Field label="AWS S3 Bucket" value="medinova-uploads" />
        </div>
        <div className="flex items-center gap-3 pt-2">
          <button className="flex items-center gap-2 text-xs border border-border text-secondary rounded-lg px-3 py-1.5 hover:text-white transition-colors">
            <RefreshCw size={12} /> Rotate JWT Secret
          </button>
          <button className="flex items-center gap-2 text-xs border border-border text-secondary rounded-lg px-3 py-1.5 hover:text-white transition-colors">
            <Key size={12} /> Generate API Key
          </button>
        </div>
      </Section>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Security */}
        <Section title="Security" description="Access control and authentication settings">
          <Toggle label="Two-Factor Authentication" sub="Require 2FA for all admin accounts" checked={security.twoFactor} onChange={() => setSecurity(s => ({ ...s, twoFactor: !s.twoFactor }))} />
          <Toggle label="IP Whitelist" sub="Restrict admin access to specific IPs" checked={security.ipWhitelist} onChange={() => setSecurity(s => ({ ...s, ipWhitelist: !s.ipWhitelist }))} />
          <Toggle label="Audit Logging" sub="Log all admin actions with timestamps" checked={security.auditLog} onChange={() => setSecurity(s => ({ ...s, auditLog: !s.auditLog }))} />
          <Toggle label="Auto Session Timeout" sub="Logout after 30 minutes of inactivity" checked={security.sessionTimeout} onChange={() => setSecurity(s => ({ ...s, sessionTimeout: !s.sessionTimeout }))} />
          {security.ipWhitelist && (
            <div>
              <label className="text-secondary text-xs mb-1.5 block">Allowed IPs (comma separated)</label>
              <input className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white placeholder:text-secondary focus:outline-none focus:border-white/30" placeholder="192.168.1.0/24, 10.0.0.1" />
            </div>
          )}
        </Section>

        {/* Notifications */}
        <Section title="Alert Notifications" description="Where to send system alerts and reports">
          <Toggle label="Email Alerts" sub="Critical system alerts via email" checked={notifs.email} onChange={() => setNotifs(n => ({ ...n, email: !n.email }))} />
          <Toggle label="SMS Alerts" sub="Emergency alerts via SMS" checked={notifs.sms} onChange={() => setNotifs(n => ({ ...n, sms: !n.sms }))} />
          <Toggle label="Slack Integration" sub="Post alerts to Slack channel" checked={notifs.slack} onChange={() => setNotifs(n => ({ ...n, slack: !n.slack }))} />
          <Toggle label="PagerDuty" sub="On-call escalation for incidents" checked={notifs.pagerduty} onChange={() => setNotifs(n => ({ ...n, pagerduty: !n.pagerduty }))} />
          {notifs.slack && (
            <Field label="Slack Webhook URL" placeholder="https://hooks.slack.com/services/..." />
          )}
        </Section>
      </div>

      {/* AI Config */}
      <Section title="AI Configuration" description="Model selection, limits, and cost controls">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div>
            <label className="text-secondary text-xs mb-1.5 block">Default Chat Model</label>
            <select className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30">
              {['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo'].map(m => <option key={m}>{m}</option>)}
            </select>
          </div>
          <div>
            <label className="text-secondary text-xs mb-1.5 block">Vision/OCR Model</label>
            <select className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30">
              {['gpt-4o', 'gpt-4-vision-preview'].map(m => <option key={m}>{m}</option>)}
            </select>
          </div>
          <div>
            <label className="text-secondary text-xs mb-1.5 block">Max Tokens / Request</label>
            <input defaultValue="4096" type="number" className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30" />
          </div>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="text-secondary text-xs mb-1.5 block">Daily Spend Limit ($)</label>
            <input defaultValue="500" type="number" className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30" />
          </div>
          <div>
            <label className="text-secondary text-xs mb-1.5 block">Free Plan Daily AI Calls</label>
            <input defaultValue="5" type="number" className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30" />
          </div>
        </div>
      </Section>

      {/* Data */}
      <Section title="Data & Storage" description="Backup, retention, and storage configuration">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="text-secondary text-xs mb-1.5 block">Data Retention (days)</label>
            <input defaultValue="365" type="number" className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30" />
          </div>
          <div>
            <label className="text-secondary text-xs mb-1.5 block">Backup Frequency</label>
            <select className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30">
              {['Hourly', 'Daily', 'Weekly'].map(f => <option key={f}>{f}</option>)}
            </select>
          </div>
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
        </div>
      </Section>
    </div>
  )
}
