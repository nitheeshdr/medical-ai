/**
 * Seed script — populates MongoDB with realistic development data.
 * Run with: npx ts-node --project tsconfig.json scripts/seed.ts
 */
import mongoose from 'mongoose'
import bcrypt from 'bcryptjs'

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/medinova'

// ── Inline schemas (avoids Next.js module resolution at seed time) ─────────────

const UserSchema = new mongoose.Schema({
  name: String, email: { type: String, unique: true }, passwordHash: String,
  role: { type: String, default: 'user' }, profileComplete: Boolean,
  subscriptionTier: { type: String, default: 'free' },
}, { timestamps: true })

const DoctorSchema = new mongoose.Schema({
  name: String, email: { type: String, unique: true }, specialization: String,
  license: String, qualifications: [String], experience: Number,
  consultationFee: Number, averageRating: Number, bio: String,
  location: String, languages: [String], isVerified: Boolean,
  availability: [{ day: String, slots: [String] }],
}, { timestamps: true })

const MedicineSchema = new mongoose.Schema({
  name: String, genericName: String, dosage: String, manufacturer: String,
  price: Number, stock: Number, category: String, requiresPrescription: Boolean,
  description: String,
}, { timestamps: true })

const User   = mongoose.models.User   || mongoose.model('User',   UserSchema)
const Doctor = mongoose.models.Doctor || mongoose.model('Doctor', DoctorSchema)
const Medicine = mongoose.models.Medicine || mongoose.model('Medicine', MedicineSchema)

async function seed() {
  await mongoose.connect(MONGODB_URI)
  console.log('✓ Connected to MongoDB')

  // Clear existing seed data
  await Promise.all([User.deleteMany({}), Doctor.deleteMany({}), Medicine.deleteMany({})])
  console.log('✓ Cleared existing data')

  // ── Users ──────────────────────────────────────────────────────────────────
  const passwordHash = await bcrypt.hash('password123', 10)
  await User.insertMany([
    { name: 'John Johnson', email: 'john@example.com', passwordHash, role: 'user', profileComplete: true, subscriptionTier: 'pro' },
    { name: 'Admin User',   email: 'admin@medinova.ai', passwordHash, role: 'admin', profileComplete: true, subscriptionTier: 'enterprise' },
  ])
  console.log('✓ Users seeded')

  // ── Doctors ────────────────────────────────────────────────────────────────
  const slots = ['09:00', '09:30', '10:00', '10:30', '11:00', '14:00', '14:30', '15:00', '15:30']
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
  const availability = days.map(day => ({ day, slots }))

  await Doctor.insertMany([
    {
      name: 'Dr. Sarah Johnson', email: 'sarah.johnson@medinova.ai',
      specialization: 'Cardiology', license: 'MED-001-2010',
      qualifications: ['MD Cardiology', 'FACC'], experience: 12,
      consultationFee: 120, averageRating: 4.9,
      bio: 'Board-certified cardiologist specializing in heart disease prevention and management.',
      location: 'New York, NY', languages: ['English', 'Spanish'],
      isVerified: true, availability,
    },
    {
      name: 'Dr. Michael Chen', email: 'michael.chen@medinova.ai',
      specialization: 'Neurology', license: 'MED-002-2012',
      qualifications: ['MD Neurology', 'PhD Neuroscience'], experience: 9,
      consultationFee: 150, averageRating: 4.8,
      bio: 'Expert in neurological disorders including migraine, epilepsy, and stroke recovery.',
      location: 'San Francisco, CA', languages: ['English', 'Mandarin'],
      isVerified: true, availability,
    },
    {
      name: 'Dr. Priya Sharma', email: 'priya.sharma@medinova.ai',
      specialization: 'General Physician', license: 'MED-003-2015',
      qualifications: ['MBBS', 'MD General Medicine'], experience: 7,
      consultationFee: 80, averageRating: 4.7,
      bio: 'Compassionate general physician with expertise in preventive care and chronic disease management.',
      location: 'Chicago, IL', languages: ['English', 'Hindi'],
      isVerified: true, availability,
    },
    {
      name: 'Dr. James Wilson', email: 'james.wilson@medinova.ai',
      specialization: 'Dermatology', license: 'MED-004-2008',
      qualifications: ['MD Dermatology', 'FAAD'], experience: 15,
      consultationFee: 100, averageRating: 4.6,
      bio: 'Specializes in skin conditions, cosmetic dermatology, and skin cancer screening.',
      location: 'Houston, TX', languages: ['English'],
      isVerified: true, availability,
    },
    {
      name: 'Dr. Aisha Rahman', email: 'aisha.rahman@medinova.ai',
      specialization: 'Pediatrics', license: 'MED-005-2013',
      qualifications: ['MD Pediatrics', 'FAAP'], experience: 10,
      consultationFee: 90, averageRating: 4.9,
      bio: 'Dedicated pediatrician providing comprehensive care for children from birth through adolescence.',
      location: 'Boston, MA', languages: ['English', 'Arabic'],
      isVerified: true, availability,
    },
    {
      name: 'Dr. Robert Park', email: 'robert.park@medinova.ai',
      specialization: 'Orthopedic', license: 'MED-006-2006',
      qualifications: ['MD Orthopedics', 'FAAOS'], experience: 18,
      consultationFee: 130, averageRating: 4.5,
      bio: 'Sports medicine and joint replacement specialist with 18 years of clinical experience.',
      location: 'Los Angeles, CA', languages: ['English', 'Korean'],
      isVerified: true, availability,
    },
  ])
  console.log('✓ Doctors seeded')

  // ── Medicines ──────────────────────────────────────────────────────────────
  await Medicine.insertMany([
    { name: 'Metformin 500mg', genericName: 'Metformin HCl', dosage: '500mg', manufacturer: 'Sun Pharma', price: 12.99, stock: 200, category: 'Diabetes', requiresPrescription: true, description: 'First-line treatment for type 2 diabetes.' },
    { name: 'Lisinopril 10mg', genericName: 'Lisinopril', dosage: '10mg', manufacturer: 'Cipla', price: 8.49, stock: 150, category: 'Cardiovascular', requiresPrescription: true, description: 'ACE inhibitor for hypertension and heart failure.' },
    { name: 'Atorvastatin 20mg', genericName: 'Atorvastatin', dosage: '20mg', manufacturer: 'Pfizer', price: 24.99, stock: 120, category: 'Cardiovascular', requiresPrescription: true, description: 'Cholesterol-lowering statin medication.' },
    { name: 'Omeprazole 20mg', genericName: 'Omeprazole', dosage: '20mg', manufacturer: 'AstraZeneca', price: 15.00, stock: 300, category: 'Gastrointestinal', requiresPrescription: false, description: 'Proton pump inhibitor for acid reflux and GERD.' },
    { name: 'Paracetamol 500mg', genericName: 'Acetaminophen', dosage: '500mg', manufacturer: 'GSK', price: 4.99, stock: 500, category: 'Pain Relief', requiresPrescription: false, description: 'Common pain reliever and fever reducer.' },
    { name: 'Amoxicillin 500mg', genericName: 'Amoxicillin', dosage: '500mg', manufacturer: 'Sandoz', price: 18.75, stock: 80, category: 'Antibiotics', requiresPrescription: true, description: 'Broad-spectrum penicillin antibiotic.' },
  ])
  console.log('✓ Medicines seeded')

  await mongoose.disconnect()
  console.log('\n🎉 Database seeded successfully!')
  console.log('   Login: john@example.com / password123')
}

seed().catch(e => { console.error(e); process.exit(1) })
