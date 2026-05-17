'use client'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import {
  LayoutDashboard, Users, UserCog, BarChart3,
  CreditCard, Brain, Bell, Settings, Stethoscope,
} from 'lucide-react'

const NAV = [
  { label: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { label: 'Users', href: '/users', icon: Users },
  { label: 'Doctors', href: '/doctors', icon: Stethoscope },
  { label: 'Analytics', href: '/analytics', icon: BarChart3 },
  { label: 'Subscriptions', href: '/subscriptions', icon: CreditCard },
  { label: 'AI Usage', href: '/ai-usage', icon: Brain },
  { label: 'Notifications', href: '/notifications', icon: Bell },
  { label: 'Settings', href: '/settings', icon: Settings },
]

export function Sidebar() {
  const path = usePathname()

  return (
    <aside className="w-56 flex-shrink-0 flex flex-col bg-surface border-r border-border">
      {/* Logo */}
      <div className="h-14 flex items-center px-5 border-b border-border">
        <span className="text-white font-bold text-sm tracking-wider">MEDINOVA</span>
        <span className="ml-1 text-tertiary text-xs font-medium">ADMIN</span>
      </div>

      {/* Nav */}
      <nav className="flex-1 py-4 overflow-y-auto">
        {NAV.map(({ label, href, icon: Icon }) => {
          const active = path.startsWith(href)
          return (
            <Link
              key={href}
              href={href}
              className={`flex items-center gap-3 px-5 py-2.5 text-sm transition-colors ${
                active
                  ? 'bg-elevated text-white border-r-2 border-white'
                  : 'text-secondary hover:text-white hover:bg-elevated'
              }`}
            >
              <Icon size={16} />
              {label}
            </Link>
          )
        })}
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-border">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-elevated flex items-center justify-center">
            <UserCog size={14} className="text-secondary" />
          </div>
          <div>
            <p className="text-xs text-white font-medium">Admin</p>
            <p className="text-xs text-tertiary">admin@medinova.ai</p>
          </div>
        </div>
      </div>
    </aside>
  )
}
