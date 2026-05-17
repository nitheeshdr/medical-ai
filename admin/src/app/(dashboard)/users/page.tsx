'use client'
import { useState, useEffect, useCallback, useRef } from 'react'
import {
  Search, Users, UserCheck, Brain, DollarSign, ChevronLeft, ChevronRight,
  Trash2, Loader2, RefreshCw, X, FileText, Pill, Calendar, Activity
} from 'lucide-react'

interface User {
  _id: string; name: string; email: string; phone?: string; plan: string
  subscriptionStatus: string; createdAt: string; aiRequests: number
  aiCost: number; role: string; gender?: string; profileComplete: boolean
}
interface Report {
  _id: string; type: string; fileName: string; fileUrl: string; fileSize: number
  createdAt: string
  aiAnalysis?: { summary: string; needsAttention: boolean; highlights?: { label: string; value: string; status: string }[] }
}
interface Prescription {
  _id: string; imageUrl: string; createdAt: string
  aiAnalysis?: { medicines?: { name: string; dosage: string }[]; summary: string }
}
interface Appointment {
  _id: string; doctorName?: string; specialty?: string; status: string
  scheduledAt?: string; createdAt: string
}
interface UserDetail {
  user: User & { aiTokens: number; subscriptionStart?: string; subscriptionRenewal?: string }
  reports: Report[]; prescriptions: Prescription[]; appointments: Appointment[]
}

const PLAN_COLORS: Record<string, string> = {
  free: 'text-secondary border-border',
  pro: 'text-white border-white/30',
  family: 'text-green-400 border-green-400/30',
  enterprise: 'text-yellow-400 border-yellow-400/30',
}
const REPORT_TYPE_LABELS: Record<string, string> = {
  blood: 'Blood Report', mri: 'MRI', ecg: 'ECG', ct: 'CT Scan', xray: 'X-Ray', diabetes: 'Diabetes', other: 'Other',
}

const fmtDate = (iso?: string) => iso ? new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : '—'
const fmtSize = (b: number) => b < 1024 ? `${b}B` : b < 1048576 ? `${(b / 1024).toFixed(1)}KB` : `${(b / 1048576).toFixed(1)}MB`
const timeAgo = (iso: string) => { const d = Math.floor((Date.now() - new Date(iso).getTime()) / 86400000); return d === 0 ? 'today' : d === 1 ? 'yesterday' : `${d}d ago` }

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [pagination, setPagination] = useState({ page: 1, pages: 1, total: 0 })
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [page, setPage] = useState(1)
  const [deleting, setDeleting] = useState<string | null>(null)
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [detail, setDetail] = useState<UserDetail | null>(null)
  const [detailLoading, setDetailLoading] = useState(false)
  const [activeTab, setActiveTab] = useState<'overview' | 'reports' | 'prescriptions' | 'appointments'>('overview')
  const [toast, setToast] = useState<{ msg: string; ok: boolean } | null>(null)
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  const showToast = (msg: string, ok: boolean) => { setToast({ msg, ok }); setTimeout(() => setToast(null), 3000) }

  const load = useCallback(async (p: number, q: string) => {
    setLoading(true)
    try {
      const params = new URLSearchParams({ page: String(p), limit: '20' })
      if (q) params.set('search', q)
      const res = await fetch(`/api/admin-users?${params}`)
      if (res.ok) { const d = await res.json(); setUsers(d.users ?? []); setPagination({ page: d.page ?? p, pages: d.pages ?? 1, total: d.total ?? 0 }) }
    } finally { setLoading(false) }
  }, [])

  const loadDetail = useCallback(async (userId: string) => {
    setDetailLoading(true); setDetail(null); setActiveTab('overview')
    try {
      const res = await fetch(`/api/admin-users/${userId}`)
      if (res.ok) { const d = await res.json(); setDetail(d) }
    } finally { setDetailLoading(false) }
  }, [])

  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current)
    debounceRef.current = setTimeout(() => setDebouncedSearch(search), 400)
  }, [search])
  useEffect(() => { setPage(1); load(1, debouncedSearch) }, [debouncedSearch, load])
  useEffect(() => { load(page, debouncedSearch) }, [page, load, debouncedSearch])

  const openUser = (u: User) => { setSelectedUser(u); loadDetail(u._id) }

  const handleDelete = async (userId: string, name: string) => {
    if (!confirm(`Delete "${name}"? This cannot be undone.`)) return
    setDeleting(userId)
    try {
      const res = await fetch('/api/admin-users', { method: 'DELETE', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ userId }) })
      if (res.ok) { showToast('User deleted', true); setSelectedUser(null); load(page, debouncedSearch) }
      else showToast('Failed to delete', false)
    } finally { setDeleting(null) }
  }

  const activeCount = users.filter(u => u.subscriptionStatus === 'active').length
  const totalAI = users.reduce((a, u) => a + u.aiRequests, 0)
  const totalSpend = users.reduce((a, u) => a + u.aiCost, 0)

  const TABS = [
    { key: 'overview', label: 'Overview', icon: Activity },
    { key: 'reports', label: `Reports${detail ? ` (${detail.reports.length})` : ''}`, icon: FileText },
    { key: 'prescriptions', label: `Rx${detail ? ` (${detail.prescriptions.length})` : ''}`, icon: Pill },
    { key: 'appointments', label: `Appts${detail ? ` (${detail.appointments.length})` : ''}`, icon: Calendar },
  ] as const

  return (
    <div className="space-y-5">
      {toast && (
        <div className={`fixed top-4 right-4 z-50 px-4 py-2.5 rounded-lg border text-sm font-medium shadow-xl ${toast.ok ? 'bg-surface border-success/40 text-success' : 'bg-surface border-red-500/40 text-red-400'}`}>
          {toast.msg}
        </div>
      )}

      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-white">Users</h1>
          <p className="text-secondary text-sm mt-0.5">{pagination.total.toLocaleString()} registered users</p>
        </div>
        <button onClick={() => load(page, debouncedSearch)} className="p-2 border border-border text-secondary rounded-lg hover:text-white transition-colors">
          <RefreshCw size={14} className={loading ? 'animate-spin' : ''} />
        </button>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {[
          { label: 'Total Users', value: pagination.total.toLocaleString(), icon: Users },
          { label: 'Active Subs', value: activeCount, icon: UserCheck },
          { label: 'AI Calls (page)', value: totalAI.toLocaleString(), icon: Brain },
          { label: 'AI Spend (page)', value: `$${totalSpend.toFixed(2)}`, icon: DollarSign },
        ].map(s => (
          <div key={s.label} className="bg-surface border border-border rounded-xl p-4">
            <div className="flex items-center justify-between mb-1">
              <p className="text-secondary text-xs">{s.label}</p>
              <s.icon size={13} className="text-secondary" />
            </div>
            <p className="text-white text-xl font-bold">{s.value}</p>
          </div>
        ))}
      </div>

      <div className="flex items-center gap-2 bg-surface border border-border rounded-xl px-4 py-2.5">
        <Search size={15} className="text-secondary flex-shrink-0" />
        <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search by name or email…" className="bg-transparent text-sm text-white placeholder:text-secondary outline-none flex-1" />
        {search && <button onClick={() => setSearch('')} className="text-secondary hover:text-white"><X size={14} /></button>}
      </div>

      <div className="bg-surface border border-border rounded-xl overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center py-16 gap-2"><Loader2 size={16} className="text-secondary animate-spin" /><span className="text-secondary text-sm">Loading…</span></div>
        ) : users.length === 0 ? (
          <div className="flex flex-col items-center py-16"><Users size={28} className="text-secondary mb-3" /><p className="text-secondary text-sm">{debouncedSearch ? `No users matching "${debouncedSearch}"` : 'No users found'}</p></div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border">
                  {['User', 'Plan', 'Status', 'Joined', 'AI Calls', 'Spend', ''].map(h => (
                    <th key={h} className={`px-5 py-3.5 text-secondary font-medium text-xs uppercase tracking-wide ${['AI Calls', 'Spend'].includes(h) ? 'text-right' : 'text-left'}`}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {users.map(u => (
                  <tr key={u._id} className="hover:bg-elevated transition-colors cursor-pointer" onClick={() => openUser(u)}>
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-elevated border border-border flex items-center justify-center text-xs font-bold text-white flex-shrink-0">
                          {(u.name || u.email)[0].toUpperCase()}
                        </div>
                        <div className="min-w-0">
                          <p className="text-white font-medium truncate">{u.name || '—'}</p>
                          <p className="text-secondary text-xs truncate">{u.email}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-5 py-4"><span className={`text-xs px-2 py-0.5 rounded border capitalize ${PLAN_COLORS[u.plan] ?? 'text-secondary border-border'}`}>{u.plan}</span></td>
                    <td className="px-5 py-4"><span className={`text-xs px-2 py-0.5 rounded ${u.subscriptionStatus === 'active' ? 'bg-success/10 text-success' : 'bg-elevated text-secondary'}`}>{u.subscriptionStatus || 'inactive'}</span></td>
                    <td className="px-5 py-4 text-secondary text-xs whitespace-nowrap">{fmtDate(u.createdAt)}</td>
                    <td className="px-5 py-4 text-right text-white text-xs font-medium">{u.aiRequests.toLocaleString()}</td>
                    <td className="px-5 py-4 text-right text-white text-xs font-medium">${u.aiCost.toFixed(2)}</td>
                    <td className="px-5 py-4 text-right" onClick={e => e.stopPropagation()}>
                      <button onClick={() => handleDelete(u._id, u.name || u.email)} disabled={deleting === u._id} className="p-1.5 text-secondary hover:text-red-400 transition-colors disabled:opacity-50">
                        {deleting === u._id ? <Loader2 size={13} className="animate-spin" /> : <Trash2 size={13} />}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        {pagination.pages > 1 && (
          <div className="flex items-center justify-between px-5 py-3 border-t border-border">
            <p className="text-secondary text-xs">Page {pagination.page} of {pagination.pages} · {pagination.total.toLocaleString()} users</p>
            <div className="flex items-center gap-2">
              <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page <= 1} className="p-1.5 border border-border rounded text-secondary hover:text-white disabled:opacity-30 transition-colors"><ChevronLeft size={14} /></button>
              <span className="text-white text-xs font-medium px-2">{page}</span>
              <button onClick={() => setPage(p => Math.min(pagination.pages, p + 1))} disabled={page >= pagination.pages} className="p-1.5 border border-border rounded text-secondary hover:text-white disabled:opacity-30 transition-colors"><ChevronRight size={14} /></button>
            </div>
          </div>
        )}
      </div>

      {/* Full User Detail Drawer */}
      {selectedUser && (
        <div className="fixed inset-0 bg-black/70 flex items-center justify-end z-50" onClick={() => setSelectedUser(null)}>
          <div className="h-full w-full max-w-xl bg-surface border-l border-border flex flex-col" onClick={e => e.stopPropagation()}>
            {/* Drawer header */}
            <div className="flex items-center justify-between px-6 py-4 border-b border-border flex-shrink-0">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-elevated border border-border flex items-center justify-center text-sm font-bold text-white">
                  {(selectedUser.name || selectedUser.email)[0].toUpperCase()}
                </div>
                <div>
                  <p className="text-white font-semibold text-sm">{selectedUser.name || '—'}</p>
                  <p className="text-secondary text-xs">{selectedUser.email}</p>
                </div>
              </div>
              <button onClick={() => setSelectedUser(null)} className="text-secondary hover:text-white p-1"><X size={18} /></button>
            </div>

            {/* Tabs */}
            <div className="flex border-b border-border flex-shrink-0 px-2">
              {TABS.map(tab => (
                <button
                  key={tab.key}
                  onClick={() => setActiveTab(tab.key)}
                  className={`flex items-center gap-1.5 px-4 py-3 text-xs font-medium border-b-2 transition-colors ${
                    activeTab === tab.key ? 'border-white text-white' : 'border-transparent text-secondary hover:text-white'
                  }`}
                >
                  <tab.icon size={12} />
                  {tab.label}
                </button>
              ))}
            </div>

            {/* Tab content */}
            <div className="flex-1 overflow-y-auto">
              {detailLoading ? (
                <div className="flex items-center justify-center py-16 gap-2">
                  <Loader2 size={16} className="text-secondary animate-spin" />
                  <span className="text-secondary text-sm">Loading user data…</span>
                </div>
              ) : (
                <>
                  {activeTab === 'overview' && (
                    <div className="p-6 space-y-4">
                      {/* Profile fields */}
                      <div className="space-y-1">
                        {[
                          { label: 'Plan', value: <span className={`text-xs px-2 py-0.5 rounded border capitalize ${PLAN_COLORS[selectedUser.plan]}`}>{selectedUser.plan}</span> },
                          { label: 'Status', value: <span className={`text-xs px-2 py-0.5 rounded ${selectedUser.subscriptionStatus === 'active' ? 'bg-success/10 text-success' : 'bg-elevated text-secondary'}`}>{selectedUser.subscriptionStatus || 'inactive'}</span> },
                          { label: 'Role', value: <span className="text-white text-sm capitalize">{selectedUser.role}</span> },
                          { label: 'Gender', value: <span className="text-white text-sm capitalize">{selectedUser.gender || '—'}</span> },
                          { label: 'Profile', value: <span className={`text-sm ${selectedUser.profileComplete ? 'text-success' : 'text-secondary'}`}>{selectedUser.profileComplete ? 'Complete' : 'Incomplete'}</span> },
                          { label: 'Phone', value: <span className="text-white text-sm">{selectedUser.phone || '—'}</span> },
                          { label: 'Joined', value: <span className="text-secondary text-sm">{fmtDate(selectedUser.createdAt)} · {timeAgo(selectedUser.createdAt)}</span> },
                          ...(detail ? [
                            { label: 'Sub Start', value: <span className="text-secondary text-sm">{fmtDate(detail.user.subscriptionStart)}</span> },
                            { label: 'Renews', value: <span className="text-secondary text-sm">{fmtDate(detail.user.subscriptionRenewal)}</span> },
                          ] : []),
                        ].map(row => (
                          <div key={row.label} className="flex items-center justify-between py-2.5 border-b border-border">
                            <span className="text-secondary text-xs w-24 flex-shrink-0">{row.label}</span>
                            {row.value}
                          </div>
                        ))}
                      </div>

                      {/* AI usage */}
                      <div className="bg-elevated rounded-xl p-4 mt-4">
                        <p className="text-secondary text-xs font-medium uppercase tracking-wide mb-3">AI Usage</p>
                        <div className="grid grid-cols-3 gap-3 text-center">
                          <div><p className="text-white font-bold text-lg">{selectedUser.aiRequests.toLocaleString()}</p><p className="text-secondary text-xs">Requests</p></div>
                          <div><p className="text-white font-bold text-lg">{detail ? `${(detail.user.aiTokens / 1000).toFixed(1)}K` : '—'}</p><p className="text-secondary text-xs">Tokens</p></div>
                          <div><p className="text-white font-bold text-lg">${selectedUser.aiCost.toFixed(2)}</p><p className="text-secondary text-xs">Cost</p></div>
                        </div>
                      </div>

                      <button
                        onClick={() => handleDelete(selectedUser._id, selectedUser.name || selectedUser.email)}
                        disabled={deleting === selectedUser._id}
                        className="w-full flex items-center justify-center gap-2 border border-red-500/30 text-red-400 rounded-lg py-2.5 text-sm hover:bg-red-500/5 transition-colors disabled:opacity-50 mt-2"
                      >
                        {deleting === selectedUser._id ? <Loader2 size={14} className="animate-spin" /> : <Trash2 size={14} />}
                        Delete User
                      </button>
                    </div>
                  )}

                  {activeTab === 'reports' && (
                    <div className="p-6">
                      {!detail || detail.reports.length === 0 ? (
                        <div className="flex flex-col items-center py-12">
                          <FileText size={28} className="text-secondary mb-3" />
                          <p className="text-secondary text-sm">No reports uploaded</p>
                        </div>
                      ) : (
                        <div className="space-y-3">
                          {detail.reports.map(r => (
                            <div key={r._id} className="bg-elevated rounded-xl p-4 border border-border">
                              <div className="flex items-start justify-between gap-3 mb-2">
                                <div className="flex items-center gap-2">
                                  <FileText size={14} className="text-secondary flex-shrink-0 mt-0.5" />
                                  <div>
                                    <p className="text-white text-sm font-medium">{r.fileName}</p>
                                    <p className="text-secondary text-xs">{REPORT_TYPE_LABELS[r.type] ?? r.type} · {fmtSize(r.fileSize)} · {fmtDate(r.createdAt)}</p>
                                  </div>
                                </div>
                                <div className="flex items-center gap-2 flex-shrink-0">
                                  {r.aiAnalysis?.needsAttention && (
                                    <span className="text-xs px-2 py-0.5 rounded bg-red-500/10 text-red-400 border border-red-500/20">⚠ Attention</span>
                                  )}
                                  {r.fileUrl && (
                                    <a href={r.fileUrl} target="_blank" rel="noopener noreferrer" className="text-xs text-secondary hover:text-white border border-border rounded px-2 py-0.5 transition-colors">View</a>
                                  )}
                                </div>
                              </div>
                              {r.aiAnalysis?.summary && (
                                <p className="text-secondary text-xs leading-relaxed mt-2 pl-5">{r.aiAnalysis.summary}</p>
                              )}
                              {r.aiAnalysis?.highlights && r.aiAnalysis.highlights.length > 0 && (
                                <div className="mt-2 pl-5 flex flex-wrap gap-1.5">
                                  {r.aiAnalysis.highlights.slice(0, 4).map((h, i) => (
                                    <span key={i} className={`text-xs px-2 py-0.5 rounded border ${
                                      h.status === 'critical' ? 'text-red-400 border-red-400/30' :
                                      h.status === 'high' ? 'text-yellow-400 border-yellow-400/30' :
                                      h.status === 'low' ? 'text-blue-400 border-blue-400/30' :
                                      'text-success border-success/30'
                                    }`}>{h.label}: {h.value}</span>
                                  ))}
                                </div>
                              )}
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  )}

                  {activeTab === 'prescriptions' && (
                    <div className="p-6">
                      {!detail || detail.prescriptions.length === 0 ? (
                        <div className="flex flex-col items-center py-12">
                          <Pill size={28} className="text-secondary mb-3" />
                          <p className="text-secondary text-sm">No prescriptions scanned</p>
                        </div>
                      ) : (
                        <div className="space-y-3">
                          {detail.prescriptions.map(p => (
                            <div key={p._id} className="bg-elevated rounded-xl p-4 border border-border">
                              <div className="flex items-center justify-between mb-2">
                                <p className="text-white text-sm font-medium">Prescription</p>
                                <p className="text-secondary text-xs">{fmtDate(p.createdAt)}</p>
                              </div>
                              {p.aiAnalysis?.summary && (
                                <p className="text-secondary text-xs leading-relaxed mb-2">{p.aiAnalysis.summary}</p>
                              )}
                              {p.aiAnalysis?.medicines && p.aiAnalysis.medicines.length > 0 && (
                                <div className="flex flex-wrap gap-1.5">
                                  {p.aiAnalysis.medicines.slice(0, 6).map((m, i) => (
                                    <span key={i} className="text-xs px-2 py-0.5 rounded border border-border text-secondary">
                                      {m.name}{m.dosage ? ` · ${m.dosage}` : ''}
                                    </span>
                                  ))}
                                </div>
                              )}
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  )}

                  {activeTab === 'appointments' && (
                    <div className="p-6">
                      {!detail || detail.appointments.length === 0 ? (
                        <div className="flex flex-col items-center py-12">
                          <Calendar size={28} className="text-secondary mb-3" />
                          <p className="text-secondary text-sm">No appointments found</p>
                        </div>
                      ) : (
                        <div className="space-y-3">
                          {detail.appointments.map(a => (
                            <div key={a._id} className="bg-elevated rounded-xl p-4 border border-border flex items-center gap-3">
                              <Calendar size={16} className="text-secondary flex-shrink-0" />
                              <div className="flex-1 min-w-0">
                                <p className="text-white text-sm font-medium">{a.doctorName || 'Doctor'}</p>
                                <p className="text-secondary text-xs">{a.specialty || ''} {a.scheduledAt ? `· ${fmtDate(a.scheduledAt)}` : ''}</p>
                              </div>
                              <span className={`text-xs px-2 py-0.5 rounded border flex-shrink-0 ${
                                a.status === 'confirmed' ? 'text-success border-success/30' :
                                a.status === 'completed' ? 'text-secondary border-border' :
                                'text-yellow-400 border-yellow-400/30'
                              }`}>{a.status}</span>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  )}
                </>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
