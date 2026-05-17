'use client'
import {
  AreaChart, Area, BarChart, Bar, LineChart, Line,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend,
} from 'recharts'

interface Props {
  dailyUsers: { date: string; users: number }[]
  dailyAI: { date: string; requests: number; tokens: number; cost: number }[]
  dailyAppts: { date: string; appointments: number }[]
}

const tooltipStyle = {
  contentStyle: { background: '#1A1A1A', border: '1px solid #2A2A2A', borderRadius: 8, color: '#fff', fontSize: 12 },
}

export function AnalyticsCharts({ dailyUsers, dailyAI, dailyAppts }: Props) {
  const isEmpty = dailyUsers.length === 0 && dailyAI.length === 0

  if (isEmpty) {
    return (
      <div className="bg-surface border border-border rounded-xl p-12 text-center">
        <p className="text-secondary">No data for the last 30 days yet.</p>
        <p className="text-tertiary text-xs mt-2">Charts will populate as users interact with the platform.</p>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      {/* User growth */}
      <div className="bg-surface border border-border rounded-xl p-5">
        <h3 className="text-white font-semibold mb-4">User Growth (30 days)</h3>
        <ResponsiveContainer width="100%" height={220}>
          <AreaChart data={dailyUsers}>
            <defs>
              <linearGradient id="ug" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#fff" stopOpacity={0.12} />
                <stop offset="95%" stopColor="#fff" stopOpacity={0} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke="#2A2A2A" />
            <XAxis dataKey="date" tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
            <YAxis tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
            <Tooltip {...tooltipStyle} />
            <Area type="monotone" dataKey="users" stroke="#fff" strokeWidth={2} fill="url(#ug)" name="New Users" />
          </AreaChart>
        </ResponsiveContainer>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* AI requests */}
        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="text-white font-semibold mb-4">AI Requests (30 days)</h3>
          <ResponsiveContainer width="100%" height={200}>
            <LineChart data={dailyAI}>
              <CartesianGrid strokeDasharray="3 3" stroke="#2A2A2A" />
              <XAxis dataKey="date" tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
              <Tooltip {...tooltipStyle} />
              <Legend wrapperStyle={{ fontSize: 11, color: '#6B6B6B' }} />
              <Line type="monotone" dataKey="requests" stroke="#fff" strokeWidth={2} dot={false} name="Requests" />
              <Line type="monotone" dataKey="tokens" stroke="#B5B5B5" strokeWidth={1.5} dot={false} name="Tokens ÷100" />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Appointments */}
        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="text-white font-semibold mb-4">Appointments (30 days)</h3>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={dailyAppts}>
              <CartesianGrid strokeDasharray="3 3" stroke="#2A2A2A" />
              <XAxis dataKey="date" tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} />
              <Tooltip {...tooltipStyle} />
              <Bar dataKey="appointments" fill="#fff" radius={[4, 4, 0, 0]} opacity={0.85} name="Appointments" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  )
}
