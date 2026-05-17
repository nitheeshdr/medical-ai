'use client'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

interface DataPoint { label: string; count: number }

interface Props {
  data?: DataPoint[]
  total?: number
}

export function UsersChart({ data = [], total = 0 }: Props) {
  return (
    <div className="bg-surface border border-border rounded-xl p-5">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h3 className="text-white font-semibold">New Users</h3>
          <p className="text-secondary text-xs mt-0.5">Daily signups (last 30 days)</p>
        </div>
        <span className="text-white text-sm font-bold">{total.toLocaleString()}</span>
      </div>
      <ResponsiveContainer width="100%" height={160}>
        <BarChart data={data}>
          <CartesianGrid strokeDasharray="3 3" stroke="#2A2A2A" />
          <XAxis dataKey="label" tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
          <YAxis tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
          <Tooltip
            contentStyle={{ background: '#1A1A1A', border: '1px solid #2A2A2A', borderRadius: 8, color: '#fff', fontSize: 12 }}
          />
          <Bar dataKey="count" fill="#fff" radius={[4, 4, 0, 0]} opacity={0.9} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}
