import { fetchStats } from '@/lib/api'
import { AnalyticsCharts } from '@/components/dashboard/analytics-charts'

export default async function AnalyticsPage() {
  const data = await fetchStats(30)
  const charts = data?.charts
  const stats = data?.stats

  const dailyUsers = (charts?.dailyUsers ?? []).map((d: { _id: string; count: number }) => ({
    date: d._id.slice(5),
    users: d.count,
  }))

  const dailyAI = (charts?.dailyAI ?? []).map((d: { _id: string; requests: number; tokens: number; cost: number }) => ({
    date: d._id.slice(5),
    requests: d.requests,
    tokens: Math.round(d.tokens / 100),
    cost: Number(d.cost.toFixed(3)),
  }))

  const dailyAppts = (charts?.dailyAppointments ?? []).map((d: { _id: string; count: number }) => ({
    date: d._id.slice(5),
    appointments: d.count,
  }))

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-bold text-white">Analytics</h1>
        <p className="text-secondary text-sm mt-0.5">
          Platform metrics — last 30 days
          {!data && <span className="ml-2 text-danger text-xs">(backend offline)</span>}
        </p>
      </div>

      {/* Summary KPIs */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: 'New Users', value: (stats?.users?.new ?? 0).toLocaleString() },
          { label: 'AI Requests', value: (stats?.ai?.requests ?? 0).toLocaleString() },
          { label: 'Tokens Used', value: `${((stats?.ai?.tokensUsed ?? 0) / 1000).toFixed(1)}K` },
          { label: 'AI Cost', value: `$${(stats?.ai?.cost ?? 0).toFixed(2)}` },
        ].map((k) => (
          <div key={k.label} className="bg-surface border border-border rounded-xl p-5">
            <p className="text-secondary text-xs uppercase tracking-wide font-medium">{k.label}</p>
            <p className="text-white text-2xl font-bold mt-2">{k.value}</p>
          </div>
        ))}
      </div>

      <AnalyticsCharts
        dailyUsers={dailyUsers}
        dailyAI={dailyAI}
        dailyAppts={dailyAppts}
      />
    </div>
  )
}
