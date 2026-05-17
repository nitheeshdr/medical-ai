'use client'
import { useState, useEffect, useCallback, useRef } from 'react'
import {
  Search, Star, Stethoscope, CheckCircle, Clock, ChevronLeft,
  ChevronRight, Loader2, RefreshCw, X, Plus, Shield, ShieldOff
} from 'lucide-react'

interface Doctor {
  _id: string
  name: string
  email: string
  specialization: string
  license: string
  qualifications: string[]
  experience: number
  consultationFee: number
  averageRating: number
  bio: string
  location: string
  languages: string[]
  isVerified: boolean
  appointmentCount: number
  createdAt: string
}

interface Pagination { page: number; pages: number; total: number }

function fmtDate(iso: string) {
  return new Date(iso).toLocaleDateString('en-US', { month: 'short', year: 'numeric' })
}

const SPECIALIZATIONS = [
  'General Physician', 'Cardiologist', 'Dermatologist', 'Neurologist',
  'Pediatrician', 'Psychiatrist', 'Orthopedic', 'Gynecologist',
  'Ophthalmologist', 'ENT Specialist', 'Endocrinologist', 'Oncologist',
]

export default function DoctorsPage() {
  const [doctors, setDoctors] = useState<Doctor[]>([])
  const [pagination, setPagination] = useState<Pagination>({ page: 1, pages: 1, total: 0 })
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [page, setPage] = useState(1)
  const [selectedDoc, setSelectedDoc] = useState<Doctor | null>(null)
  const [showAdd, setShowAdd] = useState(false)
  const [acting, setActing] = useState<string | null>(null)
  const [toast, setToast] = useState<{ msg: string; ok: boolean } | null>(null)
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  // Add doctor form
  const [form, setForm] = useState({
    name: '', email: '', specialization: 'General Physician',
    license: '', experience: 5, consultationFee: 50, bio: '', location: '',
  })
  const [adding, setAdding] = useState(false)

  const showToast = (msg: string, ok: boolean) => {
    setToast({ msg, ok })
    setTimeout(() => setToast(null), 3000)
  }

  const load = useCallback(async (p: number, q: string) => {
    setLoading(true)
    try {
      const params = new URLSearchParams({ page: String(p), limit: '20' })
      if (q) params.set('search', q)
      const res = await fetch(`/api/admin-doctors?${params}`)
      if (res.ok) {
        const d = await res.json()
        setDoctors(d.doctors ?? [])
        setPagination({ page: d.page ?? p, pages: d.pages ?? 1, total: d.total ?? 0 })
      }
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current)
    debounceRef.current = setTimeout(() => setDebouncedSearch(search), 400)
  }, [search])

  useEffect(() => { setPage(1); load(1, debouncedSearch) }, [debouncedSearch, load])
  useEffect(() => { load(page, debouncedSearch) }, [page, load, debouncedSearch])

  const handleVerify = async (doctorId: string, currentState: boolean) => {
    setActing(doctorId)
    try {
      const res = await fetch('/api/admin-doctors', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: doctorId, isVerified: !currentState }),
      })
      if (res.ok) {
        showToast(`Doctor ${!currentState ? 'verified' : 'unverified'}`, true)
        setDoctors(prev => prev.map(d => d._id === doctorId ? { ...d, isVerified: !currentState } : d))
        if (selectedDoc?._id === doctorId) setSelectedDoc(prev => prev ? { ...prev, isVerified: !currentState } : null)
      } else {
        showToast('Failed to update verification', false)
      }
    } finally {
      setActing(null)
    }
  }

  const handleAdd = async () => {
    if (!form.name || !form.email || !form.license) return showToast('Name, email and license are required', false)
    setAdding(true)
    try {
      const res = await fetch('/api/admin-doctors', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      })
      if (res.ok) {
        showToast('Doctor added successfully', true)
        setShowAdd(false)
        setForm({ name: '', email: '', specialization: 'General Physician', license: '', experience: 5, consultationFee: 50, bio: '', location: '' })
        load(1, debouncedSearch)
      } else {
        const d = await res.json()
        showToast(d.error || 'Failed to add doctor', false)
      }
    } finally {
      setAdding(false)
    }
  }

  const verified = doctors.filter(d => d.isVerified).length
  const avgRating = doctors.length > 0 ? (doctors.reduce((a, d) => a + d.averageRating, 0) / doctors.length).toFixed(1) : '—'
  const totalAppts = doctors.reduce((a, d) => a + d.appointmentCount, 0)

  return (
    <div className="space-y-5">
      {/* Toast */}
      {toast && (
        <div className={`fixed top-4 right-4 z-50 flex items-center gap-2 px-4 py-2.5 rounded-lg border text-sm font-medium shadow-xl ${
          toast.ok ? 'bg-surface border-success/40 text-success' : 'bg-surface border-red-500/40 text-red-400'
        }`}>
          {toast.msg}
        </div>
      )}

      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-white">Doctors</h1>
          <p className="text-secondary text-sm mt-0.5">{pagination.total.toLocaleString()} registered doctors</p>
        </div>
        <div className="flex items-center gap-2">
          <button onClick={() => load(page, debouncedSearch)} className="p-2 border border-border text-secondary rounded-lg hover:text-white transition-colors">
            <RefreshCw size={14} className={loading ? 'animate-spin' : ''} />
          </button>
          <button
            onClick={() => setShowAdd(true)}
            className="flex items-center gap-2 text-sm bg-white text-black rounded-lg px-4 py-2 font-medium hover:bg-white/90 transition-colors"
          >
            <Plus size={14} /> Add Doctor
          </button>
        </div>
      </div>

      {/* Mini stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {[
          { label: 'Total Doctors', value: pagination.total.toLocaleString(), icon: Stethoscope },
          { label: 'Verified', value: `${verified} / ${doctors.length}`, icon: CheckCircle },
          { label: 'Avg Rating', value: avgRating, icon: Star },
          { label: 'Total Appts', value: totalAppts.toLocaleString(), icon: Clock },
        ].map(s => (
          <div key={s.label} className="bg-surface border border-border rounded-xl p-4">
            <div className="flex items-center justify-between mb-1">
              <p className="text-secondary text-xs">{s.label}</p>
              <s.icon size={13} className="text-secondary" />
            </div>
            <p className="text-white text-xl font-bold">{s.value}</p>
          </div>
        ))}
      </div>

      {/* Search */}
      <div className="flex items-center gap-2 bg-surface border border-border rounded-xl px-4 py-2.5">
        <Search size={15} className="text-secondary flex-shrink-0" />
        <input
          value={search}
          onChange={e => setSearch(e.target.value)}
          placeholder="Search by name or specialization…"
          className="bg-transparent text-sm text-white placeholder:text-secondary outline-none flex-1"
        />
        {search && <button onClick={() => setSearch('')} className="text-secondary hover:text-white"><X size={14} /></button>}
      </div>

      {/* Table */}
      <div className="bg-surface border border-border rounded-xl overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center py-16 gap-2">
            <Loader2 size={16} className="text-secondary animate-spin" />
            <span className="text-secondary text-sm">Loading doctors…</span>
          </div>
        ) : doctors.length === 0 ? (
          <div className="flex flex-col items-center py-16">
            <Stethoscope size={28} className="text-secondary mb-3" />
            <p className="text-secondary text-sm">{debouncedSearch ? `No doctors matching "${debouncedSearch}"` : 'No doctors found'}</p>
            <button onClick={() => setShowAdd(true)} className="mt-3 text-xs text-white border border-border rounded-lg px-3 py-1.5 hover:bg-elevated transition-colors">
              Add first doctor
            </button>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border">
                  {['Doctor', 'Specialty', 'Verified', 'Rating', 'Appts', 'Fee', 'Joined', 'Action'].map(h => (
                    <th key={h} className={`px-5 py-3.5 text-secondary font-medium text-xs uppercase tracking-wide ${
                      ['Rating', 'Appts', 'Fee'].includes(h) ? 'text-right' : 'text-left'
                    }`}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {doctors.map(d => (
                  <tr
                    key={d._id}
                    className="hover:bg-elevated transition-colors cursor-pointer"
                    onClick={() => setSelectedDoc(d)}
                  >
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-elevated border border-border flex items-center justify-center text-xs font-bold text-white flex-shrink-0">
                          {d.name[0]}
                        </div>
                        <div className="min-w-0">
                          <p className="text-white font-medium truncate">{d.name}</p>
                          <p className="text-secondary text-xs truncate">{d.email}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-5 py-4 text-secondary text-sm">{d.specialization}</td>
                    <td className="px-5 py-4">
                      <span className={`text-xs px-2 py-0.5 rounded ${d.isVerified ? 'bg-success/10 text-success' : 'bg-yellow-500/10 text-yellow-400'}`}>
                        {d.isVerified ? 'Verified' : 'Pending'}
                      </span>
                    </td>
                    <td className="px-5 py-4 text-right">
                      <div className="flex items-center justify-end gap-1">
                        <Star size={11} className="text-yellow-400 fill-yellow-400" />
                        <span className="text-white text-xs">{d.averageRating.toFixed(1)}</span>
                      </div>
                    </td>
                    <td className="px-5 py-4 text-right text-white text-xs font-medium">{d.appointmentCount.toLocaleString()}</td>
                    <td className="px-5 py-4 text-right text-white text-xs font-medium">${d.consultationFee}</td>
                    <td className="px-5 py-4 text-secondary text-xs whitespace-nowrap">{fmtDate(d.createdAt)}</td>
                    <td className="px-5 py-4" onClick={e => e.stopPropagation()}>
                      <button
                        onClick={() => handleVerify(d._id, d.isVerified)}
                        disabled={acting === d._id}
                        className={`flex items-center gap-1 text-xs px-2 py-1 rounded border transition-colors disabled:opacity-50 ${
                          d.isVerified
                            ? 'border-border text-secondary hover:text-red-400 hover:border-red-400/30'
                            : 'border-success/30 text-success hover:bg-success/5'
                        }`}
                      >
                        {acting === d._id ? (
                          <Loader2 size={11} className="animate-spin" />
                        ) : d.isVerified ? (
                          <><ShieldOff size={11} /> Unverify</>
                        ) : (
                          <><Shield size={11} /> Verify</>
                        )}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {pagination.pages > 1 && (
          <div className="flex items-center justify-between px-5 py-3 border-t border-border">
            <p className="text-secondary text-xs">Page {pagination.page} of {pagination.pages} · {pagination.total.toLocaleString()} doctors</p>
            <div className="flex items-center gap-2">
              <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page <= 1} className="p-1.5 border border-border rounded text-secondary hover:text-white disabled:opacity-30 transition-colors">
                <ChevronLeft size={14} />
              </button>
              <span className="text-white text-xs font-medium px-2">{page}</span>
              <button onClick={() => setPage(p => Math.min(pagination.pages, p + 1))} disabled={page >= pagination.pages} className="p-1.5 border border-border rounded text-secondary hover:text-white disabled:opacity-30 transition-colors">
                <ChevronRight size={14} />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Doctor detail drawer */}
      {selectedDoc && (
        <div className="fixed inset-0 bg-black/70 flex items-center justify-end z-50" onClick={() => setSelectedDoc(null)}>
          <div className="h-full w-full max-w-sm bg-surface border-l border-border p-6 overflow-y-auto" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-white font-semibold">Doctor Details</h3>
              <button onClick={() => setSelectedDoc(null)} className="text-secondary hover:text-white"><X size={18} /></button>
            </div>
            <div className="flex items-center gap-4 mb-6">
              <div className="w-14 h-14 rounded-full bg-elevated border border-border flex items-center justify-center text-xl font-bold text-white">
                {selectedDoc.name[0]}
              </div>
              <div>
                <p className="text-white font-semibold">{selectedDoc.name}</p>
                <p className="text-secondary text-sm">{selectedDoc.specialization}</p>
                <p className="text-tertiary text-xs">{selectedDoc.email}</p>
              </div>
            </div>
            <div className="space-y-3 mb-6">
              {[
                { label: 'License', value: selectedDoc.license || '—' },
                { label: 'Experience', value: `${selectedDoc.experience} years` },
                { label: 'Fee', value: `$${selectedDoc.consultationFee}` },
                { label: 'Rating', value: `${selectedDoc.averageRating.toFixed(1)} / 5.0` },
                { label: 'Appointments', value: selectedDoc.appointmentCount.toLocaleString() },
                { label: 'Location', value: selectedDoc.location || '—' },
                { label: 'Languages', value: selectedDoc.languages?.join(', ') || '—' },
                { label: 'Qualifications', value: selectedDoc.qualifications?.join(', ') || '—' },
                { label: 'Joined', value: fmtDate(selectedDoc.createdAt) },
              ].map(row => (
                <div key={row.label} className="flex items-start justify-between py-2 border-b border-border gap-4">
                  <span className="text-secondary text-xs flex-shrink-0">{row.label}</span>
                  <span className="text-white text-sm text-right">{row.value}</span>
                </div>
              ))}
            </div>
            {selectedDoc.bio && (
              <div className="mb-6">
                <p className="text-secondary text-xs mb-1">Bio</p>
                <p className="text-white text-sm leading-relaxed">{selectedDoc.bio}</p>
              </div>
            )}
            <button
              onClick={() => handleVerify(selectedDoc._id, selectedDoc.isVerified)}
              disabled={acting === selectedDoc._id}
              className={`w-full flex items-center justify-center gap-2 border rounded-lg py-2.5 text-sm transition-colors disabled:opacity-50 ${
                selectedDoc.isVerified
                  ? 'border-red-500/30 text-red-400 hover:bg-red-500/5'
                  : 'border-success/30 text-success hover:bg-success/5'
              }`}
            >
              {acting === selectedDoc._id ? <Loader2 size={14} className="animate-spin" /> : selectedDoc.isVerified ? <ShieldOff size={14} /> : <Shield size={14} />}
              {selectedDoc.isVerified ? 'Remove Verification' : 'Verify Doctor'}
            </button>
          </div>
        </div>
      )}

      {/* Add Doctor Modal */}
      {showAdd && (
        <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4">
          <div className="bg-surface border border-border rounded-xl w-full max-w-lg p-6 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-5">
              <h3 className="text-white font-semibold text-lg">Add Doctor</h3>
              <button onClick={() => setShowAdd(false)} className="text-secondary hover:text-white"><X size={18} /></button>
            </div>
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                {[
                  { label: 'Full Name', key: 'name', placeholder: 'Dr. John Smith' },
                  { label: 'Email', key: 'email', placeholder: 'doctor@example.com' },
                  { label: 'License No.', key: 'license', placeholder: 'LIC-XXXXX' },
                  { label: 'Location', key: 'location', placeholder: 'New York, USA' },
                ].map(f => (
                  <div key={f.key}>
                    <label className="text-secondary text-xs mb-1.5 block">{f.label}</label>
                    <input
                      value={form[f.key as keyof typeof form] as string}
                      onChange={e => setForm(prev => ({ ...prev, [f.key]: e.target.value }))}
                      placeholder={f.placeholder}
                      className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white placeholder:text-secondary focus:outline-none focus:border-white/30"
                    />
                  </div>
                ))}
              </div>
              <div>
                <label className="text-secondary text-xs mb-1.5 block">Specialization</label>
                <select
                  value={form.specialization}
                  onChange={e => setForm(prev => ({ ...prev, specialization: e.target.value }))}
                  className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30"
                >
                  {SPECIALIZATIONS.map(s => <option key={s}>{s}</option>)}
                </select>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-secondary text-xs mb-1.5 block">Experience (years)</label>
                  <input
                    type="number"
                    value={form.experience}
                    onChange={e => setForm(prev => ({ ...prev, experience: Number(e.target.value) }))}
                    className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30"
                  />
                </div>
                <div>
                  <label className="text-secondary text-xs mb-1.5 block">Consultation Fee ($)</label>
                  <input
                    type="number"
                    value={form.consultationFee}
                    onChange={e => setForm(prev => ({ ...prev, consultationFee: Number(e.target.value) }))}
                    className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-white/30"
                  />
                </div>
              </div>
              <div>
                <label className="text-secondary text-xs mb-1.5 block">Bio</label>
                <textarea
                  value={form.bio}
                  onChange={e => setForm(prev => ({ ...prev, bio: e.target.value }))}
                  rows={3}
                  placeholder="Brief professional bio…"
                  className="w-full bg-elevated border border-border rounded-lg px-3 py-2 text-sm text-white placeholder:text-secondary focus:outline-none focus:border-white/30 resize-none"
                />
              </div>
            </div>
            <div className="flex gap-3 mt-5">
              <button onClick={() => setShowAdd(false)} className="flex-1 border border-border text-secondary rounded-lg py-2 text-sm hover:text-white transition-colors">
                Cancel
              </button>
              <button
                onClick={handleAdd}
                disabled={adding}
                className="flex-1 bg-white text-black rounded-lg py-2 text-sm font-medium hover:bg-white/90 transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
              >
                {adding ? <Loader2 size={14} className="animate-spin" /> : <Plus size={14} />}
                {adding ? 'Adding…' : 'Add Doctor'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
