'use client'
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

interface DataPoint { label: string; value: number }
interface Props { data?: DataPoint[]; total?: number; changePercent?: number }

export function RevenueChart({ data = [], total = 0, changePercent = 0 }: Props) {
  const hasData = data.some(d => d.value > 0)
  return (
    <div className="bg-surface border border-border rounded-xl p-5">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h3 className="text-white font-semibold">Revenue</h3>
          <p className="text-secondary text-xs mt-0.5">Estimated from active subscriptions (30d)</p>
        </div>
        <div className="text-right">
          <p className="text-white text-sm font-bold">${total.toLocaleString()}</p>
          {changePercent !== 0 && (
            <p className={`text-xs ${changePercent > 0 ? 'text-success' : 'text-danger'}`}>
              {changePercent > 0 ? '+' : ''}{changePercent.toFixed(1)}%
            </p>
          )}
        </div>
      </div>
      {!hasData ? (
        <div className="flex items-center justify-center h-[200px] text-secondary text-sm">
          No revenue data yet
        </div>
      ) : (
        <ResponsiveContainer width="100%" height={200}>
          <AreaChart data={data}>
            <defs>
              <linearGradient id="rev" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#fff" stopOpacity={0.15} />
                <stop offset="95%" stopColor="#fff" stopOpacity={0} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke="#2A2A2A" />
            <XAxis dataKey="label" tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
            <YAxis tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} tickFormatter={v => `$${(v / 1000).toFixed(0)}k`} />
            <Tooltip
              contentStyle={{ background: '#1A1A1A', border: '1px solid #2A2A2A', borderRadius: 8, color: '#fff', fontSize: 12 }}
              formatter={(v: number) => [`$${v.toLocaleString()}`, 'Revenue']}
            />
            <Area type="monotone" dataKey="value" stroke="#fff" strokeWidth={2} fill="url(#rev)" />
          </AreaChart>
        </ResponsiveContainer>
      )}
    </div>
  )
}
