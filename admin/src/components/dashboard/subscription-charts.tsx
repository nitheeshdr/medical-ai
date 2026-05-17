'use client'
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

interface MrrPoint { month: string; mrr: number; churn: number }

const TOOLTIP_STYLE = { background: '#1A1A1A', border: '1px solid #2A2A2A', borderRadius: 8, color: '#fff', fontSize: 12 }

export function SubscriptionCharts({ mrrChart }: { mrrChart: MrrPoint[] }) {
  return (
    <div className="bg-surface border border-border rounded-xl p-5">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h3 className="text-white font-semibold">MRR Growth</h3>
          <p className="text-secondary text-xs mt-0.5">Monthly recurring revenue vs churn revenue</p>
        </div>
      </div>
      {mrrChart.length === 0 ? (
        <div className="flex items-center justify-center h-[200px] text-secondary text-sm">
          No MRR data yet — subscriptions will appear here
        </div>
      ) : (
        <ResponsiveContainer width="100%" height={200}>
          <AreaChart data={mrrChart}>
            <defs>
              <linearGradient id="mrr" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#fff" stopOpacity={0.15} />
                <stop offset="95%" stopColor="#fff" stopOpacity={0} />
              </linearGradient>
              <linearGradient id="churn" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#EF4444" stopOpacity={0.15} />
                <stop offset="95%" stopColor="#EF4444" stopOpacity={0} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke="#2A2A2A" />
            <XAxis dataKey="month" tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
            <YAxis tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} tickFormatter={v => `$${(v / 1000).toFixed(0)}k`} />
            <Tooltip contentStyle={TOOLTIP_STYLE} formatter={(v: number) => [`$${v.toLocaleString()}`]} />
            <Area type="monotone" dataKey="churn" stroke="#EF4444" fill="url(#churn)" strokeWidth={1.5} name="Churn" />
            <Area type="monotone" dataKey="mrr" stroke="#fff" fill="url(#mrr)" strokeWidth={2} name="MRR" />
          </AreaChart>
        </ResponsiveContainer>
      )}
    </div>
  )
}
