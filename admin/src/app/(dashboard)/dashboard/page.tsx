import {
  Users, Brain, DollarSign, Activity, Stethoscope,
  ShieldCheck, FileText, TrendingUp, TrendingDown, AlertCircle
} from 'lucide-react'
import { RevenueChart } from '@/components/dashboard/revenue-chart'
import { UsersChart } from '@/components/dashboard/users-chart'
import { AiUsageChart } from '@/components/dashboard/ai-usage-chart'
import { fetchStats } from '@/lib/api'

function timeAgo(iso: string) {
  const diff = Date.now() - new Date(iso).getTime()
  const m = Math.floor(diff / 60000)
  if (m < 1) return 'just now'
  if (m < 60) return `${m}m ago`
  const h = Math.floor(m / 60)
  if (h < 24) return `${h}h ago`
  return `${Math.floor(h / 24)}d ago`
}

function StatCard({
  label, value, sub, icon: Icon, trend,
}: { label: string; value: string; sub?: string; icon: React.ElementType; trend?: number }) {
  const positive = (trend ?? 0) >= 0
  return (
    <div className="bg-surface border border-border rounded-xl p-5">
      <div className="flex items-start justify-between mb-3">
        <p className="text-secondary text-xs font-medium uppercase tracking-wide">{label}</p>
        <div className="p-2 bg-elevated rounded-lg">
          <Icon size={16} className="text-secondary" />
        </div>
      </div>
      <p className="text-white text-3xl font-bold tracking-tight">{value}</p>
      {sub && <p className="text-secondary text-xs mt-1.5">{sub}</p>}
      {trend !== undefined && (
        <div className={`flex items-center gap-1 mt-2 text-xs ${positive ? 'text-success' : 'text-danger'}`}>
          {positive ? <TrendingUp size={11} /> : <TrendingDown size={11} />}
          <span>{positive ? '+' : ''}{trend}% vs last period</span>
        </div>
      )}
    </div>
  )
}

export default async function DashboardPage() {
  const data = await fetchStats(30)

  const stats = data?.stats
  const charts = data?.charts
  const activity: { user: string; action: string; time: string; type: string }[] = data?.recentActivity ?? []

  const dailyUsersData = (charts?.dailyUsers ?? []).map((d: { _id: string; count: number }) => ({
    label: d._id.slice(5),
    count: d.count,
  }))

  const dailyAIData = (charts?.dailyAI ?? []).map((d: { _id: string; requests: number; tokens: number; cost: number }) => ({
    label: d._id.slice(5),
    requests: d.requests,
    tokens: Math.round(d.tokens / 100),
    cost: d.cost,
  }))

  const totalUsers = stats?.users?.total ?? 0
  const newUsers = stats?.users?.new ?? 0
  const totalDoctors = stats?.doctors?.total ?? 0
  const activeSubs = stats?.subscriptions?.active ?? 0
  const aiRequests = stats?.ai?.requests ?? 0
  const aiCost = stats?.ai?.cost ?? 0
  const totalTokens = stats?.ai?.tokensUsed ?? 0
  const appointments = stats?.appointments?.total ?? 0
  const prescriptions = stats?.prescriptions?.total ?? 0
  const estimatedRevenue = stats?.estimatedRevenue ?? 0

  const revenueChartData = dailyUsersData.map((d: { label: string; count: number }) => ({
    label: d.label,
    value: Math.round(d.count * 29.99),
  }))

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-white">Dashboard</h1>
          <p className="text-secondary text-sm mt-0.5">
            MediNova AI — last 30 days
          </p>
        </div>
        <div className="flex items-center gap-2">
          {!data && (
            <div className="flex items-center gap-1.5 text-yellow-400 text-xs bg-yellow-400/10 border border-yellow-400/20 px-3 py-1.5 rounded-lg">
              <AlertCircle size={12} />
              Backend offline
            </div>
          )}
          {data && (
            <div className="flex items-center gap-1.5 text-success text-xs bg-success/10 border border-success/20 px-3 py-1.5 rounded-lg">
              <div className="w-1.5 h-1.5 rounded-full bg-success animate-pulse" />
              Live
            </div>
          )}
        </div>
      </div>

      {/* KPIs row 1 */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard label="Total Users" value={totalUsers.toLocaleString()} sub={`+${newUsers} this month`} icon={Users} />
        <StatCard label="Active Subscriptions" value={activeSubs.toLocaleString()} sub="Paid plans" icon={ShieldCheck} />
        <StatCard label="Est. Revenue (30d)" value={`$${(estimatedRevenue / 1000).toFixed(1)}K`} sub="Based on active subs" icon={DollarSign} />
        <StatCard label="AI Requests (30d)" value={aiRequests.toLocaleString()} sub={`$${aiCost.toFixed(2)} spent`} icon={Brain} />
      </div>

      {/* KPIs row 2 */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard label="Registered Doctors" value={totalDoctors.toLocaleString()} icon={Stethoscope} />
        <StatCard label="Appointments (30d)" value={appointments.toLocaleString()} icon={Activity} />
        <StatCard label="Prescriptions (30d)" value={prescriptions.toLocaleString()} icon={FileText} />
        <StatCard
          label="Tokens Used (30d)"
          value={totalTokens >= 1000000 ? `${(totalTokens / 1000000).toFixed(2)}M` : `${(totalTokens / 1000).toFixed(1)}K`}
          sub="All AI features"
          icon={TrendingUp}
        />
      </div>

      {/* Charts row 1 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <RevenueChart data={revenueChartData} total={Math.round(estimatedRevenue)} />
        <UsersChart data={dailyUsersData} total={newUsers} />
      </div>

      {/* Charts row 2 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <AiUsageChart data={dailyAIData} totalTokens={totalTokens} totalCost={aiCost} />

        {/* Recent Activity */}
        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="text-white font-semibold mb-4">Recent Activity</h3>
          {activity.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-10 text-center">
              <div className="w-10 h-10 rounded-full bg-elevated flex items-center justify-center mb-3">
                <Activity size={16} className="text-secondary" />
              </div>
              <p className="text-secondary text-sm">No recent activity</p>
              <p className="text-tertiary text-xs mt-1">Activity will appear as users interact with the platform</p>
            </div>
          ) : (
            <div className="space-y-3">
              {activity.slice(0, 9).map((r, i) => (
                <div key={i} className="flex items-start gap-3">
                  <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5 ${
                    r.type === 'ai' ? 'bg-elevated text-secondary' : 'bg-white/10 text-white'
                  }`}>
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
