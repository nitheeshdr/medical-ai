'use client'
import { useState } from 'react'
import { Bell, Send, Users, User, Megaphone, X, Plus } from 'lucide-react'

const SENT = [
  { id: 1, title: 'System Maintenance', body: 'Scheduled maintenance on May 20 from 2-4 AM UTC. Minimal downtime expected.', type: 'System', audience: 'All users', sent: 'May 14, 10:00 AM', delivered: 24381, opened: 14628, ctr: 60.0 },
  { id: 2, title: 'New Feature: Video Consultations', body: 'You can now book video calls with doctors directly from the app!', type: 'Feature', audience: 'Pro + Family', sent: 'May 12, 2:00 PM', delivered: 8100, opened: 6885, ctr: 85.0 },
  { id: 3, title: 'Your AI Health Report is Ready', body: 'Your weekly AI wellness summary has been generated. Tap to view insights.', type: 'Personal', audience: 'Pro users', sent: 'May 10, 9:00 AM', delivered: 6820, opened: 5456, ctr: 80.0 },
  { id: 4, title: 'Limited Offer: Upgrade to Pro', body: 'Get 3 months Pro for the price of 1. Offer ends Sunday.', type: 'Promo', audience: 'Free users', sent: 'May 8, 12:00 PM', delivered: 15240, opened: 7620, ctr: 50.0 },
  { id: 5, title: 'Prescription Reminder', body: 'Time to take your Metformin 500mg. Stay on track with your treatment.', type: 'Reminder', audience: 'Scheduled', sent: 'May 15, 8:00 AM', delivered: 3420, opened: 2906, ctr: 85.0 },
]

const TYPE_COLORS: Record<string, string> = {
  System: 'bg-border text-secondary',
  Feature: 'bg-white/10 text-white',
  Personal: 'bg-success/10 text-success',
  Promo: 'bg-yellow-500/10 text-yellow-400',
  Reminder: 'bg-blue-500/10 text-blue-400',
}

export default function NotificationsPage() {
  const [showCompose, setShowCompose] = useState(false)
  const [tab, setTab] = useState<'sent' | 'scheduled'>('sent')

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-white">Notifications</h1>
          <p className="text-secondary text-sm mt-0.5">Push notification campaigns and delivery stats</p>
        </div>
        <button
          onClick={() => setShowCompose(true)}
          className="flex items-center gap-2 text-sm bg-white text-black rounded-lg px-4 py-2 font-medium hover:bg-white/90 transition-colors"
        >
          <Plus size={14} />
          New Notification
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: 'Sent Today', value: '3,420', icon: Send },
          { label: 'Total Delivered', value: '58,961', icon: Bell },
          { label: 'Avg Open Rate', value: '72.1%', icon: Users },
          { label: 'Scheduled', value: '4', icon: Megaphone },
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

      {/* Tabs */}
      <div className="flex gap-1 bg-surface border border-border rounded-lg p-1 w-fit">
        {(['sent', 'scheduled'] as const).map(t => (
          <button
            key={t}
            onClick={() => setTab(t)}
            className={`px-4 py-1.5 text-sm rounded-md capitalize transition-colors ${
              tab === t ? 'bg-white text-black font-medium' : 'text-secondary hover:text-white'
            }`}
          >
            {t}
          </button>
        ))}
      </div>

      {/* Notification table */}
      <div className="bg-surface border border-border rounded-xl overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-border">
              {['Notification', 'Type', 'Audience', 'Sent', 'Delivered', 'Opened', 'CTR'].map(h => (
                <th key={h} className="px-5 py-3 text-left text-xs font-medium text-secondary uppercase tracking-wider">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {SENT.map(n => (
              <tr key={n.id} className="hover:bg-elevated/50 transition-colors">
                <td className="px-5 py-4 max-w-xs">
                  <p className="text-white text-sm font-medium truncate">{n.title}</p>
                  <p className="text-secondary text-xs truncate">{n.body}</p>
                </td>
                <td className="px-5 py-4">
                  <span className={`text-xs px-2 py-0.5 rounded-full ${TYPE_COLORS[n.type]}`}>{n.type}</span>
                </td>
                <td className="px-5 py-4">
                  <div className="flex items-center gap-1.5 text-secondary text-xs">
                    <User size={11} />
                    {n.audience}
                  </div>
                </td>
                <td className="px-5 py-4 text-secondary text-xs whitespace-nowrap">{n.sent}</td>
                <td className="px-5 py-4 text-white text-sm font-medium">{n.delivered.toLocaleString()}</td>
                <td className="px-5 py-4">
                  <div>
                    <p className="text-white text-sm font-medium">{n.opened.toLocaleString()}</p>
                    <div className="w-16 h-1 bg-elevated rounded-full overflow-hidden mt-1">
                      <div className="h-full bg-white/70 rounded-full" style={{ width: `${n.ctr}%` }} />
                    </div>
                  </div>
                </td>
                <td className="px-5 py-4">
                  <span className={`text-sm font-medium ${n.ctr >= 80 ? 'text-success' : n.ctr >= 60 ? 'text-white' : 'text-secondary'}`}>
                    {n.ctr}%
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
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
                <input className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white placeholder:text-secondary focus:outline-none focus:border-white/30" placeholder="Notification title..." />
              </div>
              <div>
                <label className="text-secondary text-xs mb-1.5 block">Body</label>
                <textarea className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white placeholder:text-secondary focus:outline-none focus:border-white/30 resize-none" rows={3} placeholder="Notification body..." />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-secondary text-xs mb-1.5 block">Type</label>
                  <select className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30">
                    {['System', 'Feature', 'Personal', 'Promo', 'Reminder'].map(t => <option key={t}>{t}</option>)}
                  </select>
                </div>
                <div>
                  <label className="text-secondary text-xs mb-1.5 block">Audience</label>
                  <select className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30">
                    {['All users', 'Free users', 'Pro users', 'Family plan', 'Enterprise'].map(a => <option key={a}>{a}</option>)}
                  </select>
                </div>
              </div>
              <div>
                <label className="text-secondary text-xs mb-1.5 block">Schedule (optional)</label>
                <input type="datetime-local" className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30" />
              </div>
            </div>
            <div className="flex gap-3 mt-6">
              <button onClick={() => setShowCompose(false)} className="flex-1 border border-border text-secondary rounded-lg py-2 text-sm hover:text-white transition-colors">Cancel</button>
              <button className="flex-1 border border-border text-secondary rounded-lg py-2 text-sm hover:text-white transition-colors">Schedule</button>
              <button onClick={() => setShowCompose(false)} className="flex-1 bg-white text-black rounded-lg py-2 text-sm font-medium hover:bg-white/90 transition-colors flex items-center justify-center gap-2">
                <Send size={14} /> Send Now
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
