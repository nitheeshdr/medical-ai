'use client'
import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import {
  LayoutDashboard, Users, BarChart3, CreditCard,
  Brain, Bell, Settings, Stethoscope, LogOut,
} from 'lucide-react'
import { useState } from 'react'

const NAV = [
  { label: 'Dashboard',     href: '/dashboard',     icon: LayoutDashboard },
  { label: 'Users',         href: '/users',         icon: Users },
  { label: 'Doctors',       href: '/doctors',       icon: Stethoscope },
  { label: 'Analytics',     href: '/analytics',     icon: BarChart3 },
  { label: 'Subscriptions', href: '/subscriptions', icon: CreditCard },
  { label: 'AI Usage',      href: '/ai-usage',      icon: Brain },
  { label: 'Notifications', href: '/notifications', icon: Bell },
  { label: 'Settings',      href: '/settings',      icon: Settings },
]

export function Sidebar() {
  const path = usePathname()
  const router = useRouter()
  const [loggingOut, setLoggingOut] = useState(false)

  const handleLogout = async () => {
    setLoggingOut(true)
    try {
      await fetch('/api/auth/logout', { method: 'POST' })
    } finally {
      // Clear cookie client-side too as a fallback
      document.cookie = 'admin_token=; path=/; max-age=0; SameSite=Strict'
      router.replace('/login')
    }
  }

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

      {/* Footer with logout */}
      <div className="p-4 border-t border-border">
        <div className="flex items-center justify-between gap-2">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="w-7 h-7 rounded-full bg-elevated border border-border flex items-center justify-center text-xs font-bold text-white flex-shrink-0">
              A
            </div>
            <div className="min-w-0">
              <p className="text-xs text-white font-medium truncate">Admin</p>
              <p className="text-xs text-tertiary">medinova.ai</p>
            </div>
          </div>
          <button
            onClick={handleLogout}
            disabled={loggingOut}
            title="Sign out"
            className="p-1.5 text-secondary hover:text-red-400 hover:bg-red-400/10 rounded-lg transition-colors disabled:opacity-50 flex-shrink-0"
          >
            <LogOut size={14} className={loggingOut ? 'animate-pulse' : ''} />
          </button>
        </div>
      </div>
    </aside>
  )
}
