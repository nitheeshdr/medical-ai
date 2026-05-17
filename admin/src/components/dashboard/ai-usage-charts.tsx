'use client'
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts'

interface DailyPoint {
  day: string
  chat: number
  scan: number
  reports: number
  wellness: number
  cost: number
}

const TOOLTIP_STYLE = { background: '#1A1A1A', border: '1px solid #2A2A2A', borderRadius: 8, color: '#fff', fontSize: 12 }

export function AiUsageCharts({ dailyData }: { dailyData: DailyPoint[] }) {
  return (
    <>
      {/* Daily token usage line chart */}
      <div className="bg-surface border border-border rounded-xl p-5">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-white font-semibold">Daily Token Usage</h3>
            <p className="text-secondary text-xs mt-0.5">Tokens by feature (last 14 days)</p>
          </div>
        </div>
        {dailyData.length === 0 ? (
          <div className="flex items-center justify-center h-[220px] text-secondary text-sm">No usage data in this period</div>
        ) : (
          <ResponsiveContainer width="100%" height={220}>
            <LineChart data={dailyData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#2A2A2A" />
              <XAxis dataKey="day" tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} tickFormatter={v => `${(v / 1000).toFixed(0)}k`} />
              <Tooltip contentStyle={TOOLTIP_STYLE} formatter={(v: number) => [`${(v / 1000).toFixed(1)}k tokens`]} />
              <Legend wrapperStyle={{ fontSize: 11, color: '#6B6B6B' }} />
              <Line type="monotone" dataKey="chat" stroke="#fff" strokeWidth={2} dot={false} name="Chat" />
              <Line type="monotone" dataKey="scan" stroke="#B5B5B5" strokeWidth={2} dot={false} name="Rx Scanner" />
              <Line type="monotone" dataKey="reports" stroke="#6B6B6B" strokeWidth={2} dot={false} name="Reports" />
              <Line type="monotone" dataKey="wellness" stroke="#4B4B4B" strokeWidth={1.5} dot={false} name="Wellness" />
            </LineChart>
          </ResponsiveContainer>
        )}
      </div>

      {/* Daily cost bar chart */}
      <div className="bg-surface border border-border rounded-xl p-5">
        <div className="mb-6">
          <h3 className="text-white font-semibold">Daily Cost</h3>
          <p className="text-secondary text-xs mt-0.5">AI spend per day (last 14 days)</p>
        </div>
        {dailyData.length === 0 ? (
          <div className="flex items-center justify-center h-[160px] text-secondary text-sm">No cost data in this period</div>
        ) : (
          <ResponsiveContainer width="100%" height={160}>
            <BarChart data={dailyData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#2A2A2A" />
              <XAxis dataKey="day" tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} tickFormatter={v => `$${v}`} />
              <Tooltip contentStyle={TOOLTIP_STYLE} formatter={(v: number) => [`$${v.toFixed(2)}`]} />
              <Bar dataKey="cost" fill="#fff" radius={[4, 4, 0, 0]} opacity={0.85} name="Cost ($)" />
            </BarChart>
          </ResponsiveContainer>
        )}
      </div>
    </>
  )
}
