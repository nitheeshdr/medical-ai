import { Users, Brain, DollarSign, Activity, Stethoscope, ShieldCheck, FileText } from 'lucide-react'
import { StatCard } from '@/components/dashboard/stat-card'
import { RevenueChart } from '@/components/dashboard/revenue-chart'
import { UsersChart } from '@/components/dashboard/users-chart'
import { AiUsageChart } from '@/components/dashboard/ai-usage-chart'
import { fetchStats } from '@/lib/api'

function timeAgo(iso: string) {
  const diff = Date.now() - new Date(iso).getTime()
  const m = Math.floor(diff / 60000)
  if (m < 1) return 'just now'
  if (m < 60) return `${m} min ago`
  const h = Math.floor(m / 60)
  if (h < 24) return `${h}h ago`
  return `${Math.floor(h / 24)}d ago`
}

export default async function DashboardPage() {
  const data = await fetchStats(30)

  const stats = data?.stats
  const charts = data?.charts
  const activity: { user: string; action: string; time: string }[] = data?.recentActivity ?? []

  const dailyUsersData = (charts?.dailyUsers ?? []).map((d: { _id: string; count: number }) => ({
    label: d._id.slice(5), // MM-DD
    count: d.count,
  }))

  const dailyAIData = (charts?.dailyAI ?? []).map((d: { _id: string; requests: number; tokens: number; cost: number }) => ({
    label: d._id.slice(5),
    requests: d.requests,
    tokens: Math.round(d.tokens / 100),
    cost: d.cost,
  }))

  const estimatedRevenue = stats?.estimatedRevenue ?? 0
  const totalTokens = stats?.ai?.tokensUsed ?? 0
  const totalCost = stats?.ai?.cost ?? 0
  const newUsers = stats?.users?.new ?? 0

  const STATS = [
    { label: 'Total Users', value: (stats?.users?.total ?? 0).toLocaleString(), icon: Users, color: 'text-white' },
    { label: 'Active Subscriptions', value: (stats?.subscriptions?.active ?? 0).toLocaleString(), icon: ShieldCheck, color: 'text-white' },
    { label: 'Est. Revenue (30d)', value: `$${(estimatedRevenue / 1000).toFixed(1)}K`, icon: DollarSign, color: 'text-white' },
    { label: 'AI Requests (30d)', value: (stats?.ai?.requests ?? 0).toLocaleString(), icon: Brain, color: 'text-white' },
    { label: 'Doctors', value: (stats?.doctors?.total ?? 0).toLocaleString(), icon: Stethoscope, color: 'text-white' },
    { label: 'Appointments (30d)', value: (stats?.appointments?.total ?? 0).toLocaleString(), icon: Activity, color: 'text-white' },
    { label: 'Prescriptions (30d)', value: (stats?.prescriptions?.total ?? 0).toLocaleString(), icon: FileText, color: 'text-white' },
  ]

  const revenueChartData = dailyUsersData.map((d: { label: string; count: number }) => ({
    label: d.label,
    value: Math.round(d.count * 29.99),
  }))

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-bold text-white">Dashboard</h1>
        <p className="text-secondary text-sm mt-0.5">
          MediNova AI — last 30 days
          {!data && (
            <span className="ml-2 px-2 py-0.5 bg-elevated border border-border rounded text-tertiary text-xs">
              backend offline
            </span>
          )}
        </p>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {STATS.map((s) => <StatCard key={s.label} {...s} />)}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <RevenueChart data={revenueChartData} total={Math.round(estimatedRevenue)} />
        <UsersChart data={dailyUsersData} total={newUsers} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <AiUsageChart data={dailyAIData} totalTokens={totalTokens} totalCost={totalCost} />

        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="text-white font-semibold mb-4">Recent Activity</h3>
          {activity.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-10 text-center">
              <p className="text-secondary text-sm">No recent activity</p>
              <p className="text-tertiary text-xs mt-1">Activity will appear here once users start using the app</p>
            </div>
          ) : (
            <div className="space-y-3">
              {activity.slice(0, 8).map((r, i) => (
                <div key={i} className="flex items-start gap-3">
                  <div className="w-7 h-7 rounded-full bg-elevated flex items-center justify-center text-xs text-white font-bold flex-shrink-0 mt-0.5">
                    {r.user?.[0]?.toUpperCase() ?? '?'}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-white text-sm font-medium truncate">{r.user}</p>
                    <p className="text-secondary text-xs">{r.action}</p>
                  </div>
                  <span className="text-tertiary text-xs flex-shrink-0 whitespace-nowrap">{timeAgo(r.time)}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
