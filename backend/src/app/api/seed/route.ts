import { NextRequest, NextResponse } from 'next/server'
import { connectDB } from '@/lib/mongodb'
import { User } from '@/models/User'
import { Doctor } from '@/models/Doctor'
import { Medicine } from '@/models/Medicine'
import bcrypt from 'bcryptjs'

// One-time seed endpoint — protected by SEED_SECRET env var
// Remove this file after seeding is complete
export async function POST(req: NextRequest) {
  const secret = req.headers.get('x-seed-secret')
  if (!secret || secret !== process.env.SEED_SECRET) {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
  }

  await connectDB()
  const results: Record<string, unknown> = {}

  // ── Primary admin — nitheeraj1@gmail.com ─────────────────────────────────
  const primaryAdminEmail = 'nitheeraj1@gmail.com'
  const existingPrimary = await User.findOne({ email: primaryAdminEmail })
  if (existingPrimary) {
    await User.updateOne({ email: primaryAdminEmail }, { role: 'admin', profileComplete: true })
    results.primaryAdmin = 'promoted to admin'
  } else {
    const passwordHash = await bcrypt.hash('Thilak_dr1', 10)
    await User.create({
      name: 'Nitheesh',
      email: primaryAdminEmail,
      passwordHash,
      role: 'admin',
      profileComplete: true,
      subscriptionTier: 'enterprise',
      allergies: [],
      conditions: [],
      medications: [],
    })
    results.primaryAdmin = 'created'
  }

  // ── Secondary admin — admin@medinova.ai ───────────────────────────────────
  const adminEmail = 'admin@medinova.ai'
  const existingAdmin = await User.findOne({ email: adminEmail })
  if (existingAdmin) {
    await User.updateOne({ email: adminEmail }, { role: 'admin', profileComplete: true })
    results.admin = 'promoted to admin'
  } else {
    const passwordHash = await bcrypt.hash('password123', 10)
    await User.create({
      name: 'Admin',
      email: adminEmail,
      passwordHash,
      role: 'admin',
      profileComplete: true,
      subscriptionTier: 'enterprise',
      allergies: [],
      conditions: [],
      medications: [],
    })
    results.admin = 'created'
  }

  // ── Test user ─────────────────────────────────────────────────────────────
  const userEmail = 'john@example.com'
  if (!(await User.findOne({ email: userEmail }))) {
    const passwordHash = await bcrypt.hash('password123', 10)
    await User.create({
      name: 'John Doe',
      email: userEmail,
      passwordHash,
      role: 'user',
      profileComplete: true,
      subscriptionTier: 'pro',
      bloodType: 'O+',
      allergies: ['Penicillin'],
      conditions: ['Hypertension'],
      medications: ['Lisinopril 10mg'],
    })
    results.testUser = 'created'
  } else {
    results.testUser = 'already exists'
  }

  // ── Doctors ───────────────────────────────────────────────────────────────
  const doctorCount = await Doctor.countDocuments()
  if (doctorCount === 0) {
    await Doctor.insertMany([
      { name: 'Dr. Sarah Johnson', specialization: 'Cardiology', license: 'MED-001', experience: 15, consultationFee: 150, availability: true, rating: 4.9, totalReviews: 312, location: 'New York, NY', bio: 'Board-certified cardiologist with 15 years of experience.' },
      { name: 'Dr. Michael Chen', specialization: 'Neurology', license: 'MED-002', experience: 12, consultationFee: 175, availability: true, rating: 4.8, totalReviews: 245, location: 'San Francisco, CA', bio: 'Neurologist specialising in stroke prevention and brain health.' },
      { name: 'Dr. Emily Rodriguez', specialization: 'Endocrinology', license: 'MED-003', experience: 10, consultationFee: 140, availability: false, rating: 4.7, totalReviews: 198, location: 'Chicago, IL', bio: 'Expert in diabetes management and thyroid disorders.' },
      { name: 'Dr. James Wilson', specialization: 'Orthopedics', license: 'MED-004', experience: 18, consultationFee: 160, availability: true, rating: 4.9, totalReviews: 421, location: 'Houston, TX', bio: 'Orthopaedic surgeon specialising in sports medicine and joint replacement.' },
      { name: 'Dr. Priya Patel', specialization: 'Dermatology', license: 'MED-005', experience: 8, consultationFee: 120, availability: true, rating: 4.6, totalReviews: 167, location: 'Los Angeles, CA', bio: 'Dermatologist focused on skin cancer prevention and cosmetic dermatology.' },
      { name: 'Dr. Robert Kim', specialization: 'Psychiatry', license: 'MED-006', experience: 14, consultationFee: 190, availability: true, rating: 4.8, totalReviews: 289, location: 'Seattle, WA', bio: 'Psychiatrist with expertise in anxiety, depression, and ADHD management.' },
    ])
    results.doctors = '6 created'
  } else {
    results.doctors = `${doctorCount} already exist`
  }

  // ── Medicines ─────────────────────────────────────────────────────────────
  const medicineCount = await Medicine.countDocuments()
  if (medicineCount === 0) {
    await Medicine.insertMany([
      { name: 'Amoxicillin 500mg', category: 'Antibiotics', manufacturer: 'PharmaCorp', price: 12.99, stock: 500, dosage: '500mg', description: 'Broad-spectrum antibiotic for bacterial infections.' },
      { name: 'Lisinopril 10mg', category: 'Cardiovascular', manufacturer: 'CardioMed', price: 8.49, stock: 300, dosage: '10mg', description: 'ACE inhibitor for hypertension and heart failure.' },
      { name: 'Metformin 850mg', category: 'Diabetes', manufacturer: 'DiabCare', price: 6.99, stock: 450, dosage: '850mg', description: 'First-line medication for type 2 diabetes.' },
      { name: 'Omeprazole 20mg', category: 'Gastrointestinal', manufacturer: 'GastroHealth', price: 11.29, stock: 350, dosage: '20mg', description: 'Proton pump inhibitor for acid reflux and GERD.' },
      { name: 'Ibuprofen 400mg', category: 'Pain Relief', manufacturer: 'PainEase', price: 4.99, stock: 600, dosage: '400mg', description: 'NSAID for pain, inflammation, and fever.' },
      { name: 'Atorvastatin 20mg', category: 'Cardiovascular', manufacturer: 'CardioMed', price: 14.49, stock: 280, dosage: '20mg', description: 'Statin for lowering cholesterol and preventing heart disease.' },
    ])
    results.medicines = '6 created'
  } else {
    results.medicines = `${medicineCount} already exist`
  }

  return NextResponse.json({ success: true, results })
}
