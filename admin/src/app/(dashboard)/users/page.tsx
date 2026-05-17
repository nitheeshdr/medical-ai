import { Search } from 'lucide-react'
import { fetchUsers } from '@/lib/api'

const PLAN_COLORS: Record<string, string> = {
  free: 'text-secondary border-border',
  pro: 'text-white border-white/30',
  family: 'text-green-400 border-green-400/30',
  enterprise: 'text-yellow-400 border-yellow-400/30',
}

function fmtDate(iso: string) {
  return new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

export default async function UsersPage() {
  const data = await fetchUsers(1, 50)
  const users: {
    _id: string
    name: string
    email: string
    plan: string
    subscriptionStatus: string
    createdAt: string
    aiRequests: number
    aiCost: number
    role: string
  }[] = data?.users ?? []
  const total: number = data?.total ?? 0

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-white">Users</h1>
          <p className="text-secondary text-sm mt-0.5">{total.toLocaleString()} registered users</p>
        </div>
      </div>

      {/* Search bar */}
      <div className="flex items-center gap-2 bg-surface border border-border rounded-xl px-4 py-3">
        <Search size={16} className="text-secondary" />
        <span className="text-secondary text-sm">Search by name or email (server-side — reload with ?search=)</span>
      </div>

      {/* Table */}
      <div className="bg-surface border border-border rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border">
                <th className="text-left px-5 py-4 text-secondary font-medium text-xs uppercase tracking-wide">User</th>
                <th className="text-left px-5 py-4 text-secondary font-medium text-xs uppercase tracking-wide">Plan</th>
                <th className="text-left px-5 py-4 text-secondary font-medium text-xs uppercase tracking-wide">Status</th>
                <th className="text-left px-5 py-4 text-secondary font-medium text-xs uppercase tracking-wide">Joined</th>
                <th className="text-right px-5 py-4 text-secondary font-medium text-xs uppercase tracking-wide">AI Reqs</th>
                <th className="text-right px-5 py-4 text-secondary font-medium text-xs uppercase tracking-wide">Spend</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {users.length === 0 ? (
                <tr>
                  <td colSpan={6} className="text-center py-12 text-secondary">
                    {data ? 'No users found' : 'Backend offline — cannot load users'}
                  </td>
                </tr>
              ) : (
                users.map((u) => (
                  <tr key={u._id} className="hover:bg-elevated transition-colors">
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
                      <span className={`text-xs px-2 py-1 rounded border capitalize ${PLAN_COLORS[u.plan] ?? 'text-secondary border-border'}`}>
                        {u.plan}
                      </span>
                    </td>
                    <td className="px-5 py-4">
                      <span className={`text-xs px-2 py-1 rounded ${
                        u.subscriptionStatus === 'active' ? 'bg-green-500/10 text-green-400' : 'bg-elevated text-secondary'
                      }`}>
                        {u.subscriptionStatus}
                      </span>
                    </td>
                    <td className="px-5 py-4 text-secondary text-xs">{fmtDate(u.createdAt)}</td>
                    <td className="px-5 py-4 text-right text-white text-xs">{u.aiRequests.toLocaleString()}</td>
                    <td className="px-5 py-4 text-right text-white text-xs">${u.aiCost.toFixed(2)}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
