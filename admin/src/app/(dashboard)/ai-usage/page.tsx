'use client'
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts'
import { Brain, DollarSign, Zap, TrendingUp } from 'lucide-react'

const DAILY_DATA = [
  { day: 'May 1', chat: 12000, scan: 3400, reports: 1800, wellness: 900, cost: 42.10 },
  { day: 'May 3', chat: 18000, scan: 5200, reports: 2400, wellness: 1200, cost: 61.80 },
  { day: 'May 5', chat: 15000, scan: 4100, reports: 2100, wellness: 1050, cost: 52.20 },
  { day: 'May 7', chat: 21000, scan: 6100, reports: 2900, wellness: 1450, cost: 72.40 },
  { day: 'May 9', chat: 28000, scan: 7200, reports: 3800, wellness: 1900, cost: 95.10 },
  { day: 'May 11', chat: 25000, scan: 6800, reports: 3400, wellness: 1700, cost: 88.20 },
  { day: 'May 13', day_label: 'Today', chat: 32000, scan: 8900, reports: 4200, wellness: 2100, cost: 112.50 },
]

const MODEL_USAGE = [
  { model: 'GPT-4o', tokens: 420000, cost: 63.00, calls: 8400, pct: 49.6 },
  { model: 'GPT-4o-mini', tokens: 280000, cost: 14.00, calls: 14000, pct: 33.0 },
  { model: 'GPT-4-vision', tokens: 98000, cost: 39.20, calls: 1960, pct: 11.6 },
  { model: 'Whisper', tokens: 49000, cost: 10.85, calls: 980, pct: 5.8 },
]

const TOP_USERS = [
  { name: 'Robert Kim', calls: 5200, tokens: 26000, cost: '$5.20', plan: 'Enterprise' },
  { name: 'Tech Corp Ltd', calls: 4100, tokens: 20500, cost: '$4.10', plan: 'Enterprise' },
  { name: 'Priya Patel', calls: 1100, tokens: 5500, cost: '$1.10', plan: 'Family' },
  { name: 'Sarah Ahmed', calls: 980, tokens: 4900, cost: '$0.98', plan: 'Pro' },
  { name: 'John Johnson', calls: 840, tokens: 4200, cost: '$0.84', plan: 'Pro' },
]

const FEATURE_COSTS = [
  { feature: 'AI Chat', daily: 64.20, monthly: 1926, pct: 51 },
  { feature: 'Report Analysis', daily: 22.10, monthly: 663, pct: 17.5 },
  { feature: 'Rx Scanner', daily: 18.90, monthly: 567, pct: 15 },
  { feature: 'Wellness AI', daily: 8.40, monthly: 252, pct: 6.7 },
  { feature: 'Voice/STT', daily: 5.20, monthly: 156, pct: 4.1 },
  { feature: 'Other', daily: 7.30, monthly: 219, pct: 5.7 },
]

const TOOLTIP_STYLE = { background: '#1A1A1A', border: '1px solid #2A2A2A', borderRadius: 8, color: '#fff', fontSize: 12 }

export default function AiUsagePage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-bold text-white">AI Usage</h1>
        <p className="text-secondary text-sm mt-0.5">Token consumption, costs, and model breakdown</p>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: 'Tokens Today', value: '847K', sub: '+24.8% vs yesterday', icon: Zap },
          { label: 'Daily Cost', value: '$127.05', sub: '+18.2% vs yesterday', icon: DollarSign },
          { label: 'Monthly Cost', value: '$3,783', sub: 'Projected $4,100', icon: TrendingUp },
          { label: 'AI Calls Today', value: '25,340', sub: 'Across all features', icon: Brain },
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

      {/* Daily usage chart */}
      <div className="bg-surface border border-border rounded-xl p-5">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-white font-semibold">Daily Token Usage</h3>
            <p className="text-secondary text-xs mt-0.5">API calls by feature (last 13 days)</p>
          </div>
          <div className="text-right">
            <p className="text-white text-sm font-bold">5.94M tokens</p>
            <p className="text-secondary text-xs">total this month · $526.30</p>
          </div>
        </div>
        <ResponsiveContainer width="100%" height={220}>
          <LineChart data={DAILY_DATA}>
            <CartesianGrid strokeDasharray="3 3" stroke="#2A2A2A" />
            <XAxis dataKey="day" tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
            <YAxis tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} tickFormatter={v => `${v / 1000}k`} />
            <Tooltip contentStyle={TOOLTIP_STYLE} />
            <Legend wrapperStyle={{ fontSize: 11, color: '#6B6B6B' }} />
            <Line type="monotone" dataKey="chat" stroke="#fff" strokeWidth={2} dot={false} name="Chat" />
            <Line type="monotone" dataKey="scan" stroke="#B5B5B5" strokeWidth={2} dot={false} name="Scanner" />
            <Line type="monotone" dataKey="reports" stroke="#6B6B6B" strokeWidth={2} dot={false} name="Reports" />
            <Line type="monotone" dataKey="wellness" stroke="#4B4B4B" strokeWidth={1.5} dot={false} name="Wellness" />
          </LineChart>
        </ResponsiveContainer>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Model breakdown */}
        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="text-white font-semibold mb-5">Model Usage</h3>
          <div className="space-y-4">
            {MODEL_USAGE.map(m => (
              <div key={m.model}>
                <div className="flex items-center justify-between mb-1.5">
                  <span className="text-white text-sm">{m.model}</span>
                  <div className="text-right">
                    <span className="text-white text-sm font-medium">${m.cost.toFixed(2)}</span>
                    <span className="text-secondary text-xs ml-2">{(m.tokens / 1000).toFixed(0)}k tokens</span>
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
        </div>

        {/* Feature cost breakdown */}
        <div className="bg-surface border border-border rounded-xl p-5">
          <div className="flex items-center justify-between mb-5">
            <h3 className="text-white font-semibold">Cost by Feature</h3>
            <span className="text-secondary text-xs">Today · Monthly</span>
          </div>
          <div className="space-y-3">
            {FEATURE_COSTS.map(f => (
              <div key={f.feature} className="flex items-center justify-between">
                <div className="flex items-center gap-3 flex-1 min-w-0">
                  <div className="w-1.5 h-1.5 rounded-full bg-white flex-shrink-0" />
                  <span className="text-secondary text-sm truncate">{f.feature}</span>
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
            <span className="text-white font-bold">$127.05</span>
          </div>
        </div>
      </div>

      {/* Top consumers */}
      <div className="bg-surface border border-border rounded-xl p-5">
        <h3 className="text-white font-semibold mb-5">Top AI Consumers</h3>
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
              {TOP_USERS.map((u, i) => (
                <tr key={i} className="hover:bg-elevated/50 transition-colors">
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <div className="w-7 h-7 rounded-full bg-elevated border border-border flex items-center justify-center text-xs font-bold text-white flex-shrink-0">
                        {u.name[0]}
                      </div>
                      <span className="text-white text-sm">{u.name}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-secondary text-sm">{u.plan}</td>
                  <td className="px-4 py-3 text-white text-sm font-medium">{u.calls.toLocaleString()}</td>
                  <td className="px-4 py-3 text-secondary text-sm">{(u.tokens / 1000).toFixed(1)}k</td>
                  <td className="px-4 py-3 text-white text-sm font-medium">{u.cost}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Daily cost bar */}
      <div className="bg-surface border border-border rounded-xl p-5">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-white font-semibold">Daily Cost</h3>
            <p className="text-secondary text-xs mt-0.5">AI spend per day this month</p>
          </div>
        </div>
        <ResponsiveContainer width="100%" height={160}>
          <BarChart data={DAILY_DATA}>
            <CartesianGrid strokeDasharray="3 3" stroke="#2A2A2A" />
            <XAxis dataKey="day" tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
            <YAxis tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} tickFormatter={v => `$${v}`} />
            <Tooltip contentStyle={TOOLTIP_STYLE} formatter={(v: number) => [`$${v}`]} />
            <Bar dataKey="cost" fill="#fff" radius={[4, 4, 0, 0]} opacity={0.85} name="Cost ($)" />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  )
}
