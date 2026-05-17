import { CheckCircle, TrendingUp, Users, DollarSign, AlertCircle } from 'lucide-react'
import { fetchSubscriptions, fetchSubscriptionPlans } from '@/lib/api'
import { SubscriptionCharts } from '@/components/dashboard/subscription-charts'

interface SubKpis { mrr: number; paidSubscribers: number; churnRate: number; avgLtv: number; totalUsers: number }
interface PlanDist { plan: string; count: number; pct: number; mrr: string; color: string }
interface MrrPoint { month: string; mrr: number; churn: number }
interface RecentEvent { user: string; plan: string; status: string; amount: string; time: string; churn: boolean }
interface PlanConfig { id: string; name: string; monthlyPrice: number; features: string[] }
interface SubData { kpis: SubKpis; planBreakdown: PlanDist[]; mrrChart: MrrPoint[]; recentActivity: RecentEvent[] }

function timeAgo(iso: string) {
  const diff = Date.now() - new Date(iso).getTime()
  const m = Math.floor(diff / 60000)
  if (m < 1) return 'just now'
  if (m < 60) return `${m}m ago`
  const h = Math.floor(m / 60)
  if (h < 24) return `${h}h ago`
  return `${Math.floor(h / 24)}d ago`
}

export default async function SubscriptionsPage() {
  const [data, plans] = await Promise.all([fetchSubscriptions(), fetchSubscriptionPlans()])

  const subData = data as SubData | null
  const kpis = subData?.kpis ?? { mrr: 0, paidSubscribers: 0, churnRate: 0, avgLtv: 0, totalUsers: 0 }
  const planBreakdown = subData?.planBreakdown ?? []
  const mrrChart = subData?.mrrChart ?? []
  const recentActivity = subData?.recentActivity ?? []
  const plansConfig = (plans as PlanConfig[] | null) ?? []

  const totalPlanUsers = planBreakdown.reduce((a, p) => a + p.count, 0)

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-white">Subscriptions</h1>
          <p className="text-secondary text-sm mt-0.5">
            MRR, plan breakdown, and churn metrics
            {!data && <span className="ml-2 px-2 py-0.5 bg-elevated border border-border rounded text-tertiary text-xs">backend offline</span>}
          </p>
        </div>
        <div className="text-right">
          <p className="text-white text-sm font-bold">{totalPlanUsers.toLocaleString()} total users</p>
          <p className="text-secondary text-xs">{kpis.paidSubscribers.toLocaleString()} paid subscribers</p>
        </div>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: 'MRR', value: `$${kpis.mrr.toLocaleString()}`, change: null, icon: DollarSign },
          { label: 'Paid Subscribers', value: kpis.paidSubscribers.toLocaleString(), change: null, icon: Users },
          { label: 'Churn Rate', value: `${kpis.churnRate}%`, change: null, icon: TrendingUp, warn: kpis.churnRate > 5 },
          { label: 'Avg LTV', value: `$${kpis.avgLtv}`, change: null, icon: CheckCircle },
        ].map(k => (
          <div key={k.label} className="bg-surface border border-border rounded-xl p-4">
            <div className="flex items-center justify-between mb-2">
              <p className="text-secondary text-xs">{k.label}</p>
              {'warn' in k && k.warn
                ? <AlertCircle size={14} className="text-yellow-400" />
                : <k.icon size={14} className="text-secondary" />
              }
            </div>
            <p className="text-white text-2xl font-bold mb-0.5">{k.value}</p>
          </div>
        ))}
      </div>

      {/* Charts */}
      <SubscriptionCharts mrrChart={mrrChart} />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Plan breakdown */}
        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="text-white font-semibold mb-5">Plan Distribution</h3>
          {planBreakdown.length === 0 ? (
            <p className="text-secondary text-sm text-center py-8">No subscription data yet</p>
          ) : (
            <>
              <div className="space-y-4">
                {planBreakdown.map(p => (
                  <div key={p.plan}>
                    <div className="flex items-center justify-between mb-1.5">
                      <div className="flex items-center gap-2">
                        <div className="w-2 h-2 rounded-full" style={{ backgroundColor: p.color }} />
                        <span className="text-white text-sm capitalize">{p.plan}</span>
                      </div>
                      <div className="text-right">
                        <span className="text-white text-sm font-medium">{p.count.toLocaleString()}</span>
                        <span className="text-secondary text-xs ml-2">({p.pct}%)</span>
                      </div>
                    </div>
                    <div className="h-1.5 bg-elevated rounded-full overflow-hidden">
                      <div className="h-full rounded-full" style={{ width: `${p.pct}%`, backgroundColor: p.color }} />
                    </div>
                    <p className="text-secondary text-xs mt-1 text-right">MRR: {p.mrr}</p>
                  </div>
                ))}
              </div>
              <div className="mt-5 pt-4 border-t border-border flex justify-between items-center">
                <span className="text-secondary text-sm">Total MRR</span>
                <span className="text-white text-lg font-bold">${kpis.mrr.toLocaleString()}</span>
              </div>
            </>
          )}
        </div>

        {/* Recent subscription events */}
        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="text-white font-semibold mb-5">Recent Activity</h3>
          {recentActivity.length === 0 ? (
            <p className="text-secondary text-sm text-center py-8">No recent subscription changes</p>
          ) : (
            <div className="space-y-3">
              {recentActivity.slice(0, 10).map((s, i) => (
                <div key={i} className="flex items-start gap-3">
                  <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5 ${
                    s.churn ? 'bg-red-500/10 text-red-400' : 'bg-success/10 text-success'
                  }`}>
                    {s.user[0]?.toUpperCase() ?? '?'}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-white text-sm font-medium truncate">{s.user}</p>
                    <p className="text-secondary text-xs">
                      <span className="capitalize">{s.plan}</span>
                      {' · '}
                      <span className={s.churn ? 'text-red-400' : 'text-success capitalize'}>{s.status}</span>
                      {' · '}{s.amount}
                    </p>
                  </div>
                  <span className="text-tertiary text-xs flex-shrink-0">{timeAgo(s.time)}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Plan cards */}
      <div>
        <h3 className="text-white font-semibold mb-4">Plan Configuration</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {(plansConfig.length > 0 ? plansConfig : [
            { id: 'free', name: 'Free', monthlyPrice: 0, features: ['10 AI chats/day', 'Rx Scanner', 'Basic tracking'] },
            { id: 'pro', name: 'Pro', monthlyPrice: 9.99, features: ['Unlimited AI', 'Full reports', 'Appointments'] },
            { id: 'family', name: 'Family', monthlyPrice: 19.99, features: ['5 members', 'All Pro features', 'Emergency SOS'] },
            { id: 'enterprise', name: 'Enterprise', monthlyPrice: 49.99, features: ['Unlimited members', 'API access', 'HIPAA'] },
          ]).map(plan => {
            const liveData = planBreakdown.find(p => p.plan === plan.id)
            return (
              <div key={plan.id} className="bg-surface border border-border rounded-xl p-4">
                <div className="flex items-center justify-between mb-3">
                  <h4 className="text-white font-semibold">{plan.name}</h4>
                  <span className="text-secondary text-xs">{liveData?.count.toLocaleString() ?? '—'} users</span>
                </div>
                <p className="text-white text-lg font-bold mb-3">
                  {plan.monthlyPrice === 0 ? '$0' : `$${plan.monthlyPrice}/mo`}
                </p>
                <div className="space-y-1.5">
                  {plan.features.map(f => (
                    <div key={f} className="flex items-center gap-2">
                      <CheckCircle size={11} className="text-success flex-shrink-0" />
                      <span className="text-secondary text-xs">{f}</span>
                    </div>
                  ))}
                </div>
                <button className="mt-4 w-full border border-border text-secondary text-xs rounded-lg py-1.5 hover:text-white hover:border-white/30 transition-colors">
                  Edit Plan
                </button>
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}
