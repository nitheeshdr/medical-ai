'use client'
import { Bell, Search } from 'lucide-react'

export function Header() {
  return (
    <header className="h-14 flex items-center gap-4 px-6 bg-surface border-b border-border flex-shrink-0">
      {/* Search */}
      <div className="flex items-center gap-2 bg-elevated border border-border rounded-lg px-3 py-1.5 flex-1 max-w-sm">
        <Search size={14} className="text-tertiary" />
        <input
          placeholder="Search users, doctors..."
          className="bg-transparent text-sm text-white placeholder-tertiary outline-none flex-1"
        />
      </div>

      <div className="flex-1" />

      {/* Actions */}
      <button className="relative w-8 h-8 flex items-center justify-center rounded-lg hover:bg-elevated transition-colors">
        <Bell size={16} className="text-secondary" />
        <span className="absolute top-1 right-1 w-2 h-2 bg-danger rounded-full" />
      </button>

      <div className="w-px h-5 bg-border" />

      <div className="flex items-center gap-2">
        <div className="w-7 h-7 rounded-full bg-elevated flex items-center justify-center text-xs text-white font-bold">
          A
        </div>
        <span className="text-sm text-secondary">Admin</span>
      </div>
    </header>
  )
}
