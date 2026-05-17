'use client'
import { useState, useEffect, useCallback } from 'react'
import { Bell, Send, Users, Megaphone, X, Plus, Loader2, RefreshCw, CheckCircle, User, Clock } from 'lucide-react'

// ── types ──────────────────────────────────────────────────────────────────
interface NotifDoc {
  _id: string
  title: string
  body: string
  type: string
  read: boolean
  createdAt: string
  userId?: { name?: string; email?: string }
}

interface Stats {
  sentToday: number
  totalDelivered: number
  openRate: number
  unreadCount: number
}

const TYPE_COLORS: Record<string, string> = {
  medicine_reminder: 'bg-blue-500/10 text-blue-400',
  appointment: 'bg-white/10 text-white',
  lab_result: 'bg-success/10 text-success',
  health_tip: 'bg-yellow-500/10 text-yellow-400',
  emergency: 'bg-red-500/10 text-red-400',
  system: 'bg-border text-secondary',
  general: 'bg-border text-secondary',
}

const TYPE_LABEL: Record<string, string> = {
  medicine_reminder: 'Reminder',
  appointment: 'Appointment',
  lab_result: 'Lab Result',
  health_tip: 'Health Tip',
  emergency: 'Emergency',
  system: 'System',
  general: 'General',
}

function timeAgo(iso: string) {
  const diff = Date.now() - new Date(iso).getTime()
  const m = Math.floor(diff / 60000)
  if (m < 1) return 'just now'
  if (m < 60) return `${m}m ago`
  const h = Math.floor(m / 60)
  if (h < 24) return `${h}h ago`
  return `${Math.floor(h / 24)}d ago`
}

// ── page ───────────────────────────────────────────────────────────────────
export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<NotifDoc[]>([])
  const [stats, setStats] = useState<Stats>({ sentToday: 0, totalDelivered: 0, openRate: 0, unreadCount: 0 })
  const [loading, setLoading] = useState(true)
  const [showCompose, setShowCompose] = useState(false)
  const [sending, setSending] = useState(false)
  const [toast, setToast] = useState<{ msg: string; ok: boolean } | null>(null)

  // compose form
  const [form, setForm] = useState({ title: '', body: '', type: 'system', audience: 'all', scheduledAt: '' })

  const load = useCallback(async () => {
    setLoading(true)
    try {
      const res = await fetch('/api/admin-notifications')
      if (res.ok) {
        const d = await res.json()
        setNotifications(d.notifications ?? [])
        setStats(d.stats ?? { sentToday: 0, totalDelivered: 0, openRate: 0, unreadCount: 0 })
      }
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { load() }, [load])

  const showToast = (msg: string, ok: boolean) => {
    setToast({ msg, ok })
    setTimeout(() => setToast(null), 3500)
  }

  const handleSend = async () => {
    if (!form.title || !form.body) return showToast('Title and body are required', false)
    setSending(true)
    try {
      const res = await fetch('/api/admin-notifications', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      })
      if (res.ok) {
        const d = await res.json()
        showToast(`Sent to ${d.sent ?? 0} users`, true)
        setShowCompose(false)
        setForm({ title: '', body: '', type: 'system', audience: 'all', scheduledAt: '' })
        load()
      } else {
        showToast('Failed to send notification', false)
      }
    } catch {
      showToast('Network error', false)
    } finally {
      setSending(false)
    }
  }

  return (
    <div className="space-y-6">
      {/* Toast */}
      {toast && (
        <div className={`fixed top-4 right-4 z-50 flex items-center gap-2 px-4 py-2.5 rounded-lg border text-sm font-medium shadow-xl ${
          toast.ok ? 'bg-surface border-success/40 text-success' : 'bg-surface border-red-500/40 text-red-400'
        }`}>
          <CheckCircle size={14} />
          {toast.msg}
        </div>
      )}

      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-white">Notifications</h1>
          <p className="text-secondary text-sm mt-0.5">Push notification campaigns and delivery stats</p>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={load}
            className="p-2 border border-border text-secondary rounded-lg hover:text-white transition-colors"
          >
            <RefreshCw size={14} className={loading ? 'animate-spin' : ''} />
          </button>
          <button
            onClick={() => setShowCompose(true)}
            className="flex items-center gap-2 text-sm bg-white text-black rounded-lg px-4 py-2 font-medium hover:bg-white/90 transition-colors"
          >
            <Plus size={14} />
            New Notification
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: 'Sent Today', value: stats.sentToday.toLocaleString(), icon: Send },
          { label: 'Total Delivered', value: stats.totalDelivered.toLocaleString(), icon: Bell },
          { label: 'Open Rate', value: `${stats.openRate}%`, icon: Users },
          { label: 'Unread', value: stats.unreadCount.toLocaleString(), icon: Megaphone },
        ].map(s => (
          <div key={s.label} className="bg-surface border border-border rounded-xl p-4">
            <div className="flex items-center justify-between mb-2">
              <p className="text-secondary text-xs">{s.label}</p>
              <s.icon size={14} className="text-secondary" />
            </div>
            <p className="text-white text-2xl font-bold">{s.value}</p>
          </div>
        ))}
      </div>

      {/* Table */}
      <div className="bg-surface border border-border rounded-xl overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center py-16 gap-2">
            <Loader2 size={16} className="text-secondary animate-spin" />
            <span className="text-secondary text-sm">Loading notifications…</span>
          </div>
        ) : notifications.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16">
            <Bell size={28} className="text-secondary mb-3" />
            <p className="text-secondary text-sm">No notifications yet</p>
            <p className="text-tertiary text-xs mt-1">Send your first notification to get started</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-border">
                  {['Notification', 'Type', 'Recipient', 'Status', 'Time'].map(h => (
                    <th key={h} className="px-5 py-3 text-left text-xs font-medium text-secondary uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {notifications.map(n => (
                  <tr key={n._id} className="hover:bg-elevated/50 transition-colors">
                    <td className="px-5 py-4 max-w-xs">
                      <p className="text-white text-sm font-medium truncate">{n.title}</p>
                      <p className="text-secondary text-xs truncate">{n.body}</p>
                    </td>
                    <td className="px-5 py-4">
                      <span className={`text-xs px-2 py-0.5 rounded-full ${TYPE_COLORS[n.type] || 'bg-border text-secondary'}`}>
                        {TYPE_LABEL[n.type] || n.type}
                      </span>
                    </td>
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-1.5 text-secondary text-xs">
                        <User size={11} />
                        <span className="truncate max-w-[120px]">
                          {n.userId?.name || n.userId?.email || 'Unknown'}
                        </span>
                      </div>
                    </td>
                    <td className="px-5 py-4">
                      <span className={`text-xs px-2 py-0.5 rounded-full ${n.read ? 'bg-success/10 text-success' : 'bg-border text-secondary'}`}>
                        {n.read ? 'Read' : 'Unread'}
                      </span>
                    </td>
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-1 text-tertiary text-xs">
                        <Clock size={11} />
                        {timeAgo(n.createdAt)}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Compose modal */}
      {showCompose && (
        <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4">
          <div className="bg-surface border border-border rounded-xl w-full max-w-lg p-6">
            <div className="flex items-center justify-between mb-5">
              <h3 className="text-white font-semibold text-lg">New Notification</h3>
              <button onClick={() => setShowCompose(false)} className="text-secondary hover:text-white">
                <X size={18} />
              </button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-secondary text-xs mb-1.5 block">Title</label>
                <input
                  value={form.title}
                  onChange={e => setForm(f => ({ ...f, title: e.target.value }))}
                  className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white placeholder:text-secondary focus:outline-none focus:border-white/30"
                  placeholder="Notification title…"
                />
              </div>
              <div>
                <label className="text-secondary text-xs mb-1.5 block">Body</label>
                <textarea
                  value={form.body}
                  onChange={e => setForm(f => ({ ...f, body: e.target.value }))}
                  className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white placeholder:text-secondary focus:outline-none focus:border-white/30 resize-none"
                  rows={3}
                  placeholder="Notification body…"
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-secondary text-xs mb-1.5 block">Type</label>
                  <select
                    value={form.type}
                    onChange={e => setForm(f => ({ ...f, type: e.target.value }))}
                    className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30"
                  >
                    {['system', 'medicine_reminder', 'appointment', 'lab_result', 'health_tip', 'emergency'].map(t => (
                      <option key={t} value={t}>{TYPE_LABEL[t]}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="text-secondary text-xs mb-1.5 block">Audience</label>
                  <select
                    value={form.audience}
                    onChange={e => setForm(f => ({ ...f, audience: e.target.value }))}
                    className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30"
                  >
                    {[
                      { val: 'all', label: 'All Users' },
                      { val: 'free', label: 'Free Plan' },
                      { val: 'pro', label: 'Pro Plan' },
                      { val: 'family', label: 'Family Plan' },
                      { val: 'enterprise', label: 'Enterprise' },
                    ].map(a => <option key={a.val} value={a.val}>{a.label}</option>)}
                  </select>
                </div>
              </div>
              <div>
                <label className="text-secondary text-xs mb-1.5 block">Schedule (optional)</label>
                <input
                  type="datetime-local"
                  value={form.scheduledAt}
                  onChange={e => setForm(f => ({ ...f, scheduledAt: e.target.value }))}
                  className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30"
                />
              </div>
            </div>
            <div className="flex gap-3 mt-6">
              <button
                onClick={() => setShowCompose(false)}
                className="flex-1 border border-border text-secondary rounded-lg py-2 text-sm hover:text-white transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleSend}
                disabled={sending}
                className="flex-1 bg-white text-black rounded-lg py-2 text-sm font-medium hover:bg-white/90 transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
              >
                {sending ? <Loader2 size={14} className="animate-spin" /> : <Send size={14} />}
                {sending ? 'Sending…' : 'Send Now'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
