'use client'
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'
import { CheckCircle, TrendingUp, Users, DollarSign } from 'lucide-react'

const MRR_DATA = [
  { month: 'Jan', mrr: 12400, churn: 320 },
  { month: 'Feb', mrr: 18200, churn: 410 },
  { month: 'Mar', mrr: 22100, churn: 380 },
  { month: 'Apr', mrr: 28500, churn: 290 },
  { month: 'May', mrr: 35800, churn: 340 },
  { month: 'Jun', mrr: 42100, churn: 280 },
  { month: 'Jul', mrr: 48600, churn: 310 },
]

const PLAN_BREAKDOWN = [
  { plan: 'Free', count: 15240, pct: 62.5, color: '#2A2A2A', mrr: '$0' },
  { plan: 'Pro', count: 6820, pct: 28.0, color: '#fff', mrr: '$136,400' },
  { plan: 'Family', count: 1280, pct: 5.2, color: '#B5B5B5', mrr: '$51,200' },
  { plan: 'Enterprise', count: 41, pct: 0.2, color: '#6B6B6B', mrr: '$41,000' },
]

const RECENT_SUBS = [
  { user: 'John Johnson', from: 'Free', to: 'Pro', amount: '$19.99/mo', time: '2 min ago' },
  { user: 'Robert Kim', from: 'Pro', to: 'Family', amount: '$39.99/mo', time: '14 min ago' },
  { user: 'Priya Patel', from: 'Free', to: 'Pro', amount: '$19.99/mo', time: '31 min ago' },
  { user: 'Emma Davis', from: 'Pro', to: 'Free', amount: '$0', time: '1h ago', churn: true },
  { user: 'Tech Corp Ltd', from: 'Pro', to: 'Enterprise', amount: '$999/mo', time: '2h ago' },
  { user: 'Sarah Ahmed', from: 'Free', to: 'Family', amount: '$39.99/mo', time: '3h ago' },
]

const TOOLTIP_STYLE = { background: '#1A1A1A', border: '1px solid #2A2A2A', borderRadius: 8, color: '#fff', fontSize: 12 }

export default function SubscriptionsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-bold text-white">Subscriptions</h1>
        <p className="text-secondary text-sm mt-0.5">MRR, plan breakdown, and churn metrics</p>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: 'MRR', value: '$48,600', change: '+18.2%', icon: DollarSign },
          { label: 'Paid Subscribers', value: '8,141', change: '+8.4%', icon: Users },
          { label: 'Churn Rate', value: '2.3%', change: '-0.4%', icon: TrendingUp },
          { label: 'LTV (avg)', value: '$284', change: '+$12', icon: CheckCircle },
        ].map(k => (
          <div key={k.label} className="bg-surface border border-border rounded-xl p-4">
            <div className="flex items-center justify-between mb-2">
              <p className="text-secondary text-xs">{k.label}</p>
              <k.icon size={14} className="text-secondary" />
            </div>
            <p className="text-white text-2xl font-bold mb-0.5">{k.value}</p>
            <p className={`text-xs ${k.change.startsWith('+') ? 'text-success' : 'text-red-400'}`}>{k.change} vs last month</p>
          </div>
        ))}
      </div>

      {/* MRR Chart */}
      <div className="bg-surface border border-border rounded-xl p-5">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-white font-semibold">MRR Growth</h3>
            <p className="text-secondary text-xs mt-0.5">Monthly recurring revenue vs churn revenue</p>
          </div>
          <span className="text-success text-sm font-medium">+18.2%</span>
        </div>
        <ResponsiveContainer width="100%" height={200}>
          <AreaChart data={MRR_DATA}>
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
            <YAxis tick={{ fill: '#6B6B6B', fontSize: 11 }} axisLine={false} tickLine={false} tickFormatter={v => `$${v / 1000}k`} />
            <Tooltip contentStyle={TOOLTIP_STYLE} formatter={(v: number) => [`$${v.toLocaleString()}`]} />
            <Area type="monotone" dataKey="churn" stroke="#EF4444" fill="url(#churn)" strokeWidth={1.5} name="Churn" />
            <Area type="monotone" dataKey="mrr" stroke="#fff" fill="url(#mrr)" strokeWidth={2} name="MRR" />
          </AreaChart>
        </ResponsiveContainer>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Plan breakdown */}
        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="text-white font-semibold mb-5">Plan Distribution</h3>
          <div className="space-y-4">
            {PLAN_BREAKDOWN.map(p => (
              <div key={p.plan}>
                <div className="flex items-center justify-between mb-1.5">
                  <div className="flex items-center gap-2">
                    <div className="w-2 h-2 rounded-full" style={{ backgroundColor: p.color }} />
                    <span className="text-white text-sm">{p.plan}</span>
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
            <span className="text-white text-lg font-bold">$228,600</span>
          </div>
        </div>

        {/* Recent subscription events */}
        <div className="bg-surface border border-border rounded-xl p-5">
          <h3 className="text-white font-semibold mb-5">Recent Activity</h3>
          <div className="space-y-3">
            {RECENT_SUBS.map((s, i) => (
              <div key={i} className="flex items-start gap-3">
                <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5 ${
                  s.churn ? 'bg-red-500/10 text-red-400' : 'bg-success/10 text-success'
                }`}>
                  {s.user[0]}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-white text-sm font-medium">{s.user}</p>
                  <p className="text-secondary text-xs">
                    {s.from} → <span className={s.churn ? 'text-red-400' : 'text-success'}>{s.to}</span>
                    {' · '}{s.amount}
                  </p>
                </div>
                <span className="text-tertiary text-xs flex-shrink-0">{s.time}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Plan cards */}
      <div>
        <h3 className="text-white font-semibold mb-4">Plan Configuration</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {[
            { name: 'Free', price: '$0', features: ['5 AI chats/day', '3 Rx scans/mo', 'Basic health tracking'], active: 15240 },
            { name: 'Pro', price: '$19.99/mo', features: ['Unlimited AI chat', 'Unlimited Rx scans', 'Full reports', 'Appointments'], active: 6820 },
            { name: 'Family', price: '$39.99/mo', features: ['5 members', 'All Pro features', 'Family health hub', 'Priority support'], active: 1280 },
            { name: 'Enterprise', price: '$999/mo', features: ['Unlimited members', 'API access', 'Custom AI models', 'Dedicated CSM'], active: 41 },
          ].map(plan => (
            <div key={plan.name} className="bg-surface border border-border rounded-xl p-4">
              <div className="flex items-center justify-between mb-3">
                <h4 className="text-white font-semibold">{plan.name}</h4>
                <span className="text-secondary text-xs">{plan.active.toLocaleString()} users</span>
              </div>
              <p className="text-white text-lg font-bold mb-3">{plan.price}</p>
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
          ))}
        </div>
      </div>
    </div>
  )
}
