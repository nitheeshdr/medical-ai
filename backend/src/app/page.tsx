export default function Home() {
  return (
    <main style={{ fontFamily: 'monospace', padding: '2rem', background: '#000', color: '#fff', minHeight: '100vh' }}>
      <h1>MediNova AI API</h1>
      <p style={{ color: '#b5b5b5' }}>v1.0.1 — Healthcare SaaS Backend · Firebase + FCM enabled</p>
      <div style={{ marginTop: '2rem', display: 'grid', gap: '1rem' }}>
        {[
          ['POST', '/api/auth/register', 'Create account'],
          ['POST', '/api/auth/login', 'Sign in'],
          ['GET', '/api/users/profile', 'Get profile'],
          ['GET', '/api/doctors', 'List doctors'],
          ['GET/POST', '/api/appointments', 'Appointments'],
          ['GET/POST', '/api/prescriptions', 'Prescriptions'],
          ['POST', '/api/prescriptions/analyze', 'AI scan analysis'],
          ['GET/POST', '/api/reports', 'Medical reports'],
          ['POST', '/api/reports/analyze', 'AI report analysis'],
          ['POST', '/api/ai/chat', 'Streaming AI chat (SSE)'],
          ['GET', '/api/ai/wellness', 'AI wellness insights'],
          ['GET/POST', '/api/health-metrics', 'Health metrics'],
          ['GET/POST', '/api/family/members', 'Family members'],
          ['GET/PUT', '/api/notifications', 'Notifications'],
          ['GET', '/api/subscriptions/plans', 'Subscription plans'],
          ['GET', '/api/admin/stats', 'Admin analytics'],
        ].map(([method, path, desc]) => (
          <div key={path} style={{ display: 'flex', gap: '1rem', alignItems: 'center', padding: '0.75rem', background: '#111', borderRadius: '8px', border: '1px solid #2a2a2a' }}>
            <code style={{ color: '#22c55e', minWidth: '80px', fontSize: '12px' }}>{method}</code>
            <code style={{ color: '#fff', flex: 1, fontSize: '13px' }}>{path}</code>
            <span style={{ color: '#6b6b6b', fontSize: '12px' }}>{desc}</span>
          </div>
        ))}
      </div>
    </main>
  )
}
