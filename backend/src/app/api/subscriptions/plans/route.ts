import { ok } from '@/lib/middleware'

const PLANS = [
  {
    id: 'free',
    name: 'Free',
    monthlyPrice: 0,
    annualPrice: 0,
    features: ['AI Chatbot (10/day)', 'Prescription Scanner', 'Basic Health Tracking', '1 Family Member'],
    limits: { aiChats: 10, familyMembers: 1, telemedicine: 0 },
  },
  {
    id: 'pro',
    name: 'Pro',
    monthlyPrice: 9.99,
    annualPrice: 99.99,
    popular: true,
    features: ['Unlimited AI Chatbot', 'Advanced Scanner', 'Full Health Tracking', '5 Family Members', 'Telemedicine 2/mo', 'Priority Support'],
    limits: { aiChats: -1, familyMembers: 5, telemedicine: 2 },
  },
  {
    id: 'family',
    name: 'Family',
    monthlyPrice: 19.99,
    annualPrice: 199.99,
    features: ['Everything in Pro', 'Unlimited Family Members', 'Unlimited Telemedicine', 'Wearable Sync', 'Emergency SOS', 'Dedicated Support'],
    limits: { aiChats: -1, familyMembers: -1, telemedicine: -1 },
  },
  {
    id: 'enterprise',
    name: 'Enterprise',
    monthlyPrice: 49.99,
    annualPrice: 499.99,
    features: ['Everything in Family', 'Custom AI Models', 'EHR Integration', 'HIPAA Compliance', 'Admin Dashboard', 'SLA Guarantee'],
    limits: { aiChats: -1, familyMembers: -1, telemedicine: -1 },
  },
]

export async function GET() {
  return ok(PLANS)
}
