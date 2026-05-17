'use client'
import { useState, useEffect, useCallback, useRef } from 'react'
import { Search, Users, UserCheck, UserX, Brain, DollarSign, ChevronLeft, ChevronRight, Trash2, Loader2, RefreshCw, X } from 'lucide-react'

interface User {
  _id: string
  name: string
  email: string
  phone?: string
  plan: string
  subscriptionStatus: string
  createdAt: string
  aiRequests: number
  aiCost: number
  role: string
  gender?: string
  profileComplete: boolean
}

interface Pagination { page: number; pages: number; total: number }

const PLAN_COLORS: Record<string, string> = {
  free: 'text-secondary border-border',
  pro: 'text-white border-white/30',
  family: 'text-green-400 border-green-400/30',
  enterprise: 'text-yellow-400 border-yellow-400/30',
}

function fmtDate(iso: string) {
  return new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

function timeAgo(iso: string) {
  const diff = Date.now() - new Date(iso).getTime()
  const d = Math.floor(diff / 86400000)
  if (d === 0) return 'today'
  if (d === 1) return 'yesterday'
  return `${d}d ago`
}

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [pagination, setPagination] = useState<Pagination>({ page: 1, pages: 1, total: 0 })
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [page, setPage] = useState(1)
  const [deleting, setDeleting] = useState<string | null>(null)
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [toast, setToast] = useState<{ msg: string; ok: boolean } | null>(null)
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  const showToast = (msg: string, ok: boolean) => {
    setToast({ msg, ok })
    setTimeout(() => setToast(null), 3000)
  }

  const load = useCallback(async (p: number, q: string) => {
    setLoading(true)
    try {
      const params = new URLSearchParams({ page: String(p), limit: '20' })
      if (q) params.set('search', q)
      const res = await fetch(`/api/admin-users?${params}`)
      if (res.ok) {
        const d = await res.json()
        setUsers(d.users ?? [])
        setPagination({ page: d.page ?? p, pages: d.pages ?? 1, total: d.total ?? 0 })
      }
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current)
    debounceRef.current = setTimeout(() => setDebouncedSearch(search), 400)
  }, [search])

  useEffect(() => {
    setPage(1)
    load(1, debouncedSearch)
  }, [debouncedSearch, load])

  useEffect(() => {
    load(page, debouncedSearch)
  }, [page, load, debouncedSearch])

  const handleDelete = async (userId: string, name: string) => {
    if (!confirm(`Delete user "${name}"? This cannot be undone.`)) return
    setDeleting(userId)
    try {
      const res = await fetch('/api/admin-users', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId }),
      })
      if (res.ok) {
        showToast('User deleted', true)
        setSelectedUser(null)
        load(page, debouncedSearch)
      } else {
        showToast('Failed to delete user', false)
      }
    } finally {
      setDeleting(null)
    }
  }

  // Summary stats derived from loaded page
  const activeCount = users.filter(u => u.subscriptionStatus === 'active').length
  const paidCount = users.filter(u => u.plan !== 'free').length
  const totalAICalls = users.reduce((a, u) => a + u.aiRequests, 0)
  const totalSpend = users.reduce((a, u) => a + u.aiCost, 0)

  return (
    <div className="space-y-5">
      {/* Toast */}
      {toast && (
        <div className={`fixed top-4 right-4 z-50 flex items-center gap-2 px-4 py-2.5 rounded-lg border text-sm font-medium shadow-xl ${
          toast.ok ? 'bg-surface border-success/40 text-success' : 'bg-surface border-red-500/40 text-red-400'
        }`}>
          {toast.msg}
        </div>
      )}

      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-white">Users</h1>
          <p className="text-secondary text-sm mt-0.5">{pagination.total.toLocaleString()} registered users</p>
        </div>
        <button onClick={() => load(page, debouncedSearch)} className="p-2 border border-border text-secondary rounded-lg hover:text-white transition-colors">
          <RefreshCw size={14} className={loading ? 'animate-spin' : ''} />
        </button>
      </div>

      {/* Mini stats from current page */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {[
          { label: 'Total Users', value: pagination.total.toLocaleString(), icon: Users },
          { label: 'Active Subs', value: activeCount, icon: UserCheck },
          { label: 'AI Calls (page)', value: totalAICalls.toLocaleString(), icon: Brain },
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

      {/* Search */}
      <div className="flex items-center gap-2 bg-surface border border-border rounded-xl px-4 py-2.5">
        <Search size={15} className="text-secondary flex-shrink-0" />
        <input
          value={search}
          onChange={e => setSearch(e.target.value)}
          placeholder="Search by name or email…"
          className="bg-transparent text-sm text-white placeholder:text-secondary outline-none flex-1"
        />
        {search && (
          <button onClick={() => setSearch('')} className="text-secondary hover:text-white">
            <X size={14} />
          </button>
        )}
      </div>

      {/* Table */}
      <div className="bg-surface border border-border rounded-xl overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center py-16 gap-2">
            <Loader2 size={16} className="text-secondary animate-spin" />
            <span className="text-secondary text-sm">Loading users…</span>
          </div>
        ) : users.length === 0 ? (
          <div className="flex flex-col items-center py-16">
            <UserX size={28} className="text-secondary mb-3" />
            <p className="text-secondary text-sm">{debouncedSearch ? `No users matching "${debouncedSearch}"` : 'No users found'}</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border">
                  {['User', 'Plan', 'Status', 'Joined', 'AI Calls', 'Spend', ''].map(h => (
                    <th key={h} className={`px-5 py-3.5 text-secondary font-medium text-xs uppercase tracking-wide ${h === 'AI Calls' || h === 'Spend' ? 'text-right' : 'text-left'}`}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {users.map(u => (
                  <tr
                    key={u._id}
                    className="hover:bg-elevated transition-colors cursor-pointer"
                    onClick={() => setSelectedUser(u)}
                  >
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
                    <td className="px-5 py-4">
                      <span className={`text-xs px-2 py-0.5 rounded border capitalize ${PLAN_COLORS[u.plan] ?? 'text-secondary border-border'}`}>
                        {u.plan}
                      </span>
                    </td>
                    <td className="px-5 py-4">
                      <span className={`text-xs px-2 py-0.5 rounded ${u.subscriptionStatus === 'active' ? 'bg-success/10 text-success' : 'bg-elevated text-secondary'}`}>
                        {u.subscriptionStatus || 'inactive'}
                      </span>
                    </td>
                    <td className="px-5 py-4 text-secondary text-xs whitespace-nowrap">{fmtDate(u.createdAt)}</td>
                    <td className="px-5 py-4 text-right text-white text-xs font-medium">{u.aiRequests.toLocaleString()}</td>
                    <td className="px-5 py-4 text-right text-white text-xs font-medium">${u.aiCost.toFixed(2)}</td>
                    <td className="px-5 py-4 text-right">
                      <button
                        onClick={e => { e.stopPropagation(); handleDelete(u._id, u.name || u.email) }}
                        disabled={deleting === u._id}
                        className="p-1.5 text-secondary hover:text-red-400 transition-colors disabled:opacity-50"
                      >
                        {deleting === u._id ? <Loader2 size={13} className="animate-spin" /> : <Trash2 size={13} />}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {/* Pagination */}
        {pagination.pages > 1 && (
          <div className="flex items-center justify-between px-5 py-3 border-t border-border">
            <p className="text-secondary text-xs">
              Page {pagination.page} of {pagination.pages} · {pagination.total.toLocaleString()} users
            </p>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page <= 1}
                className="p-1.5 border border-border rounded text-secondary hover:text-white disabled:opacity-30 transition-colors"
              >
                <ChevronLeft size={14} />
              </button>
              <span className="text-white text-xs font-medium px-2">{page}</span>
              <button
                onClick={() => setPage(p => Math.min(pagination.pages, p + 1))}
                disabled={page >= pagination.pages}
                className="p-1.5 border border-border rounded text-secondary hover:text-white disabled:opacity-30 transition-colors"
              >
                <ChevronRight size={14} />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* User detail drawer */}
      {selectedUser && (
        <div className="fixed inset-0 bg-black/70 flex items-center justify-end z-50" onClick={() => setSelectedUser(null)}>
          <div
            className="h-full w-full max-w-sm bg-surface border-l border-border p-6 overflow-y-auto"
            onClick={e => e.stopPropagation()}
          >
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-white font-semibold">User Details</h3>
              <button onClick={() => setSelectedUser(null)} className="text-secondary hover:text-white">
                <X size={18} />
              </button>
            </div>

            {/* Avatar */}
            <div className="flex items-center gap-4 mb-6">
              <div className="w-14 h-14 rounded-full bg-elevated border border-border flex items-center justify-center text-xl font-bold text-white">
                {(selectedUser.name || selectedUser.email)[0].toUpperCase()}
              </div>
              <div>
                <p className="text-white font-semibold">{selectedUser.name || '—'}</p>
                <p className="text-secondary text-sm">{selectedUser.email}</p>
                {selectedUser.phone && <p className="text-tertiary text-xs">{selectedUser.phone}</p>}
              </div>
            </div>

            {/* Details grid */}
            <div className="space-y-3 mb-6">
              {[
                { label: 'Plan', value: <span className={`text-xs px-2 py-0.5 rounded border capitalize ${PLAN_COLORS[selectedUser.plan]}`}>{selectedUser.plan}</span> },
                { label: 'Status', value: <span className={`text-xs px-2 py-0.5 rounded ${selectedUser.subscriptionStatus === 'active' ? 'bg-success/10 text-success' : 'bg-elevated text-secondary'}`}>{selectedUser.subscriptionStatus || 'inactive'}</span> },
                { label: 'Role', value: <span className="text-white text-sm capitalize">{selectedUser.role}</span> },
                { label: 'Gender', value: <span className="text-white text-sm capitalize">{selectedUser.gender || '—'}</span> },
                { label: 'Profile', value: <span className={`text-sm ${selectedUser.profileComplete ? 'text-success' : 'text-secondary'}`}>{selectedUser.profileComplete ? 'Complete' : 'Incomplete'}</span> },
                { label: 'Joined', value: <span className="text-secondary text-sm">{fmtDate(selectedUser.createdAt)} · {timeAgo(selectedUser.createdAt)}</span> },
                { label: 'AI Calls', value: <span className="text-white text-sm font-medium">{selectedUser.aiRequests.toLocaleString()}</span> },
                { label: 'AI Spend', value: <span className="text-white text-sm font-medium">${selectedUser.aiCost.toFixed(4)}</span> },
              ].map(row => (
                <div key={row.label} className="flex items-center justify-between py-2 border-b border-border">
                  <span className="text-secondary text-xs">{row.label}</span>
                  {row.value}
                </div>
              ))}
            </div>

            <button
              onClick={() => handleDelete(selectedUser._id, selectedUser.name || selectedUser.email)}
              disabled={deleting === selectedUser._id}
              className="w-full flex items-center justify-center gap-2 border border-red-500/30 text-red-400 rounded-lg py-2.5 text-sm hover:bg-red-500/5 transition-colors disabled:opacity-50"
            >
              {deleting === selectedUser._id ? <Loader2 size={14} className="animate-spin" /> : <Trash2 size={14} />}
              Delete User
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
