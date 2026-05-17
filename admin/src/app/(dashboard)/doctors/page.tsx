import { Star } from 'lucide-react'
import { fetchDoctors } from '@/lib/api'

function fmtDate(iso: string) {
  return new Date(iso).toLocaleDateString('en-US', { month: 'short', year: 'numeric' })
}

export default async function DoctorsPage() {
  const data = await fetchDoctors(1, 50)
  const doctors: {
    _id: string
    name: string
    specialization: string
    licenseNumber?: string
    averageRating?: number
    consultationFee?: number
    isVerified?: boolean
    isAvailable?: boolean
    appointmentCount?: number
    createdAt: string
    bio?: string
  }[] = data?.doctors ?? []
  const total: number = data?.total ?? 0

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-white">Doctors</h1>
          <p className="text-secondary text-sm mt-0.5">{total.toLocaleString()} registered doctors</p>
        </div>
      </div>

      <div className="bg-surface border border-border rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border">
                <th className="text-left px-5 py-4 text-secondary font-medium text-xs uppercase tracking-wide">Doctor</th>
                <th className="text-left px-5 py-4 text-secondary font-medium text-xs uppercase tracking-wide">Specialty</th>
                <th className="text-left px-5 py-4 text-secondary font-medium text-xs uppercase tracking-wide">Status</th>
                <th className="text-right px-5 py-4 text-secondary font-medium text-xs uppercase tracking-wide">Rating</th>
                <th className="text-right px-5 py-4 text-secondary font-medium text-xs uppercase tracking-wide">Appts</th>
                <th className="text-right px-5 py-4 text-secondary font-medium text-xs uppercase tracking-wide">Fee</th>
                <th className="text-left px-5 py-4 text-secondary font-medium text-xs uppercase tracking-wide">Joined</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {doctors.length === 0 ? (
                <tr>
                  <td colSpan={7} className="text-center py-12 text-secondary">
                    {data ? 'No doctors found. Run the seed script to add sample doctors.' : 'Backend offline'}
                  </td>
                </tr>
              ) : (
                doctors.map((d) => (
                  <tr key={d._id} className="hover:bg-elevated transition-colors">
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-elevated border border-border flex items-center justify-center text-xs font-bold text-white flex-shrink-0">
                          {d.name[0]}
                        </div>
                        <div>
                          <p className="text-white font-medium">{d.name}</p>
                          <p className="text-secondary text-xs">{d.licenseNumber ?? '—'}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-5 py-4 text-secondary text-sm">{d.specialization}</td>
                    <td className="px-5 py-4">
                      <span className={`text-xs px-2 py-1 rounded ${
                        d.isVerified ? 'bg-green-500/10 text-green-400' : 'bg-yellow-500/10 text-yellow-400'
                      }`}>
                        {d.isVerified ? 'Verified' : 'Pending'}
                      </span>
                    </td>
                    <td className="px-5 py-4 text-right">
                      <div className="flex items-center justify-end gap-1">
                        <Star size={11} className="text-yellow-400 fill-yellow-400" />
                        <span className="text-white text-xs">{(d.averageRating ?? 0).toFixed(1)}</span>
                      </div>
                    </td>
                    <td className="px-5 py-4 text-right text-white text-xs">{(d.appointmentCount ?? 0).toLocaleString()}</td>
                    <td className="px-5 py-4 text-right text-white text-xs">${d.consultationFee ?? 0}</td>
                    <td className="px-5 py-4 text-secondary text-xs">{fmtDate(d.createdAt)}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
