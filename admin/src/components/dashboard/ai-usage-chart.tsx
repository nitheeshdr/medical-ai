'use client'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts'

interface DataPoint { label: string; requests: number; tokens: number; cost: number }

interface Props {
  data?: DataPoint[]
  totalTokens?: number
  totalCost?: number
}

export function AiUsageChart({ data = [], totalTokens = 0, totalCost = 0 }: Props) {
  return (
    <div className="bg-surface border border-border rounded-xl p-5">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h3 className="text-white font-semibold">AI Usage</h3>
          <p className="text-secondary text-xs mt-0.5">API calls by day (30 days)</p>
        </div>
        <div className="text-right">
          <p className="text-white text-sm font-bold">{(totalTokens / 1000).toFixed(1)}K tokens</p>
          <p className="text-secondary text-xs">${totalCost.toFixed(2)} spent</p>
        </div>
      </div>
      <ResponsiveContainer width="100%" height={200}>
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" stroke="#2A2A2A" />
          <XAxis dataKey="label" tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
          <YAxis tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
          <Tooltip contentStyle={{ background: '#1A1A1A', border: '1px solid #2A2A2A', borderRadius: 8, color: '#fff', fontSize: 12 }} />
          <Legend wrapperStyle={{ fontSize: 11, color: '#6B6B6B' }} />
          <Line type="monotone" dataKey="requests" stroke="#fff" strokeWidth={2} dot={false} name="Requests" />
          <Line type="monotone" dataKey="tokens" stroke="#B5B5B5" strokeWidth={2} dot={false} name="Tokens (÷100)" />
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}
