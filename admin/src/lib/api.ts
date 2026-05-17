const BACKEND = process.env.BACKEND_URL || 'http://localhost:3001/api'
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || ''

const headers = () => ({
  Authorization: `Bearer ${ADMIN_TOKEN}`,
  'Content-Type': 'application/json',
})

async function apiFetch<T>(url: string, opts?: RequestInit): Promise<T | null> {
  try {
    const res = await fetch(url, { headers: headers(), ...opts })
    if (!res.ok) return null
    const json = await res.json()
    return (json.data ?? json) as T
  } catch {
    return null
  }
}

// ── Dashboard ──────────────────────────────────────────────
export async function fetchStats(days = 30) {
  return apiFetch(`${BACKEND}/admin/stats?days=${days}`, { next: { revalidate: 60 } })
}

// ── Users / Doctors ────────────────────────────────────────
export async function fetchUsers(page = 1, limit = 20) {
  return apiFetch(`${BACKEND}/admin/users?page=${page}&limit=${limit}`, { next: { revalidate: 30 } })
}

export async function fetchDoctors(page = 1, limit = 20) {
  return apiFetch(`${BACKEND}/admin/doctors?page=${page}&limit=${limit}`, { next: { revalidate: 30 } })
}

// ── AI Usage ───────────────────────────────────────────────
export async function fetchAiUsage(days = 14) {
  return apiFetch(`${BACKEND}/admin/ai-usage?days=${days}`, { next: { revalidate: 120 } })
}

// ── Subscriptions ──────────────────────────────────────────
export async function fetchSubscriptions() {
  return apiFetch(`${BACKEND}/admin/subscriptions`, { next: { revalidate: 120 } })
}

export async function fetchSubscriptionPlans() {
  return apiFetch(`${BACKEND}/subscriptions/plans`, { next: { revalidate: 3600 } })
}

// ── Notifications ──────────────────────────────────────────
export async function fetchAdminNotifications(page = 1) {
  return apiFetch(`${BACKEND}/admin/notifications?page=${page}&limit=20`, { next: { revalidate: 30 } })
}

export async function sendAdminNotification(payload: {
  title: string
  body: string
  type: string
  audience: string
  scheduledAt?: string
}) {
  try {
    const res = await fetch(`${BACKEND}/admin/notifications`, {
      method: 'POST',
      headers: headers(),
      body: JSON.stringify(payload),
    })
    if (!res.ok) return null
    const json = await res.json()
    return json.data ?? json
  } catch {
    return null
  }
}

// ── Settings ───────────────────────────────────────────────
export async function fetchSettings() {
  return apiFetch(`${BACKEND}/admin/settings`, { next: { revalidate: 60 } })
}

export async function patchSettings(body: Record<string, unknown>) {
  try {
    const res = await fetch(`${BACKEND}/admin/settings`, {
      method: 'PATCH',
      headers: headers(),
      body: JSON.stringify(body),
    })
    if (!res.ok) return null
    const json = await res.json()
    return json.data ?? json
  } catch {
    return null
  }
}
