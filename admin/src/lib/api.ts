const BACKEND = process.env.BACKEND_URL || 'http://localhost:3001/api'
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || ''

export async function fetchStats(days = 30) {
  try {
    const res = await fetch(`${BACKEND}/admin/stats?days=${days}`, {
      headers: { Authorization: `Bearer ${ADMIN_TOKEN}` },
      next: { revalidate: 60 }, // Cache 60s
    })
    if (!res.ok) return null
    const json = await res.json()
    return json.data ?? json
  } catch {
    return null
  }
}

export async function fetchUsers(page = 1, limit = 20) {
  try {
    const res = await fetch(`${BACKEND}/admin/users?page=${page}&limit=${limit}`, {
      headers: { Authorization: `Bearer ${ADMIN_TOKEN}` },
      next: { revalidate: 30 },
    })
    if (!res.ok) return null
    const json = await res.json()
    return json.data ?? json
  } catch {
    return null
  }
}

export async function fetchDoctors(page = 1, limit = 20) {
  try {
    const res = await fetch(`${BACKEND}/admin/doctors?page=${page}&limit=${limit}`, {
      headers: { Authorization: `Bearer ${ADMIN_TOKEN}` },
      next: { revalidate: 30 },
    })
    if (!res.ok) return null
    const json = await res.json()
    return json.data ?? json
  } catch {
    return null
  }
}
