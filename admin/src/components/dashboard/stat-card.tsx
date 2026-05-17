import { LucideIcon, TrendingUp, TrendingDown } from 'lucide-react'

interface StatCardProps {
  label: string
  value: string | number
  change?: number
  icon: LucideIcon
  color?: string
}

export function StatCard({ label, value, change, icon: Icon, color = 'text-white' }: StatCardProps) {
  const isPositive = (change ?? 0) >= 0

  return (
    <div className="bg-surface border border-border rounded-xl p-5">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-secondary text-xs font-medium uppercase tracking-wide">{label}</p>
          <p className={`text-3xl font-bold mt-2 ${color}`}>{value}</p>
          {change !== undefined && (
            <div className={`flex items-center gap-1 mt-2 text-xs ${isPositive ? 'text-success' : 'text-danger'}`}>
              {isPositive ? <TrendingUp size={12} /> : <TrendingDown size={12} />}
              <span>{Math.abs(change)}% vs last period</span>
            </div>
          )}
        </div>
        <div className="p-2.5 bg-elevated rounded-lg">
          <Icon size={18} className={color} />
        </div>
      </div>
    </div>
  )
}
