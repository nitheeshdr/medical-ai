import { Brain, DollarSign, Zap, TrendingUp } from 'lucide-react'
import { fetchAiUsage } from '@/lib/api'
import { AiUsageCharts } from '@/components/dashboard/ai-usage-charts'

// ── types ──────────────────────────────────────────────────────────────────
interface AiKpis {
  tokensToday: number; costToday: number; callsToday: number
  tokensPeriod: number; costPeriod: number; callsPeriod: number; projectedMonthlyCost: number
}
interface DailyPoint { day: string; chat: number; scan: number; reports: number; wellness: number; cost: number }
interface ModelRow { model: string; tokens: number; cost: number; calls: number; pct: number }
interface FeatureRow { feature: string; daily: string; monthly: string; pct: number }
interface ConsumerRow { name: string; plan: string; calls: number; tokens: number; cost: string }
interface AiUsageData {
  kpis: AiKpis; dailyData: DailyPoint[]; modelUsage: ModelRow[]
  featureCosts: FeatureRow[]; topConsumers: ConsumerRow[]
}

function fmt(n: number, k = false) {
  if (k && n >= 1000) return `${(n / 1000).toFixed(1)}K`
  if (k && n >= 1000000) return `${(n / 1000000).toFixed(2)}M`
  return n.toLocaleString()
}

export default async function AiUsagePage() {
  const raw = await fetchAiUsage(14)
  const data = raw as AiUsageData | null

  const kpis: AiKpis = data?.kpis ?? { tokensToday: 0, costToday: 0, callsToday: 0, tokensPeriod: 0, costPeriod: 0, callsPeriod: 0, projectedMonthlyCost: 0 }
  const dailyData: DailyPoint[] = data?.dailyData ?? []
  const modelUsage: ModelRow[] = data?.modelUsage ?? []
  const featureCosts: FeatureRow[] = data?.featureCosts ?? []
  const topConsumers: ConsumerRow[] = data?.topConsumers ?? []

  const FEATURE_LABEL: Record<string, string> = {
    chat: 'AI Chat',
    prescription_scan: 'Rx Scanner',
    report_analysis: 'Report Analysis',
    wellness: 'Wellness AI',
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-white">AI Usage</h1>
          <p className="text-secondary text-sm mt-0.5">
            Token consumption, costs, and model breakdown — last 14 days
            {!data && <span className="ml-2 px-2 py-0.5 bg-elevated border border-border rounded text-tertiary text-xs">backend offline</span>}
          </p>
        </div>
        <div className="text-right">
          <p className="text-white text-sm font-bold">{fmt(kpis.tokensPeriod, true)} tokens</p>
          <p className="text-secondary text-xs">period total · ${kpis.costPeriod.toFixed(2)}</p>
        </div>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: 'Tokens Today', value: fmt(kpis.tokensToday, true), sub: `${kpis.callsToday.toLocaleString()} calls`, icon: Zap },
          { label: 'Cost Today', value: `$${kpis.costToday.toFixed(2)}`, sub: 'Across all features', icon: DollarSign },
          { label: 'Period Cost', value: `$${kpis.costPeriod.toFixed(2)}`, sub: `Projected $${kpis.projectedMonthlyCost}/mo`, icon: TrendingUp },
          { label: 'AI Calls (Period)', value: kpis.callsPeriod.toLocaleString(), sub: 'All features combined', icon: Brain },
        ].map(k => (
          <div key={k.label} className="bg-surface border border-border rounded-xl p-4">
            <div className="flex items-center justify-between mb-2">
              <p className="text-secondary text-xs">{k.label}</p>
              <k.icon size={14} className="text-secondary" />
            </div>
            <p className="text-white text-2xl font-bold mb-0.5">{k.value}</p>
            <p className="text-secondary text-xs">{k.sub}</p>
          </div>
        ))}
      </div>

      {/* Charts (client component) */}
      <AiUsageCharts dailyData={dailyData} />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Model breakdown */}
        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="text-white font-semibold mb-5">Model Usage</h3>
          {modelUsage.length === 0 ? (
            <p className="text-secondary text-sm text-center py-8">No model usage data yet</p>
          ) : (
            <div className="space-y-4">
              {modelUsage.map(m => (
                <div key={m.model}>
                  <div className="flex items-center justify-between mb-1.5">
                    <span className="text-white text-sm">{m.model}</span>
                    <div className="text-right">
                      <span className="text-white text-sm font-medium">${m.cost.toFixed(2)}</span>
                      <span className="text-secondary text-xs ml-2">{fmt(m.tokens, true)} tokens</span>
                    </div>
                  </div>
                  <div className="h-1.5 bg-elevated rounded-full overflow-hidden">
                    <div className="h-full bg-white/70 rounded-full" style={{ width: `${m.pct}%` }} />
                  </div>
                  <div className="flex justify-between mt-1">
                    <span className="text-tertiary text-xs">{m.calls.toLocaleString()} calls</span>
                    <span className="text-tertiary text-xs">{m.pct}%</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Feature cost breakdown */}
        <div className="bg-surface border border-border rounded-xl p-5">
          <div className="flex items-center justify-between mb-5">
            <h3 className="text-white font-semibold">Cost by Feature</h3>
            <span className="text-secondary text-xs">Daily · Monthly</span>
          </div>
          {featureCosts.length === 0 ? (
            <p className="text-secondary text-sm text-center py-8">No feature cost data yet</p>
          ) : (
            <>
              <div className="space-y-3">
                {featureCosts.map(f => (
                  <div key={f.feature} className="flex items-center justify-between">
                    <div className="flex items-center gap-3 flex-1 min-w-0">
                      <div className="w-1.5 h-1.5 rounded-full bg-white flex-shrink-0" />
                      <span className="text-secondary text-sm truncate">{FEATURE_LABEL[f.feature] || f.feature}</span>
                      <div className="flex-1 h-px bg-border mx-2" />
                    </div>
                    <div className="flex items-center gap-3 flex-shrink-0">
                      <span className="text-white text-sm font-medium">${f.daily}</span>
                      <span className="text-secondary text-xs">${f.monthly}/mo</span>
                      <div className="w-12 h-1 bg-elevated rounded-full overflow-hidden">
                        <div className="h-full bg-white/60 rounded-full" style={{ width: `${f.pct}%` }} />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
              <div className="mt-5 pt-4 border-t border-border flex justify-between">
                <span className="text-secondary text-sm">Today total</span>
                <span className="text-white font-bold">${kpis.costToday.toFixed(2)}</span>
              </div>
            </>
          )}
        </div>
      </div>

      {/* Top consumers */}
      <div className="bg-surface border border-border rounded-xl p-5">
        <h3 className="text-white font-semibold mb-5">Top AI Consumers Today</h3>
        {topConsumers.length === 0 ? (
          <div className="flex flex-col items-center py-10">
            <Brain size={24} className="text-secondary mb-2" />
            <p className="text-secondary text-sm">No usage data for today yet</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-border">
                  {['User', 'Plan', 'API Calls', 'Tokens', 'Cost Today'].map(h => (
                    <th key={h} className="px-4 py-2 text-left text-xs font-medium text-secondary uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {topConsumers.map((u, i) => (
                  <tr key={i} className="hover:bg-elevated/50 transition-colors">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <div className="w-7 h-7 rounded-full bg-elevated border border-border flex items-center justify-center text-xs font-bold text-white flex-shrink-0">
                          {u.name[0]?.toUpperCase() ?? '?'}
                        </div>
                        <span className="text-white text-sm">{u.name}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-xs px-2 py-0.5 rounded-full bg-white/10 text-white capitalize">{u.plan}</span>
                    </td>
                    <td className="px-4 py-3 text-white text-sm font-medium">{u.calls.toLocaleString()}</td>
                    <td className="px-4 py-3 text-secondary text-sm">{fmt(u.tokens, true)}</td>
                    <td className="px-4 py-3 text-white text-sm font-medium">{u.cost}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}
