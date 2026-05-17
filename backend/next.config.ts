import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  serverExternalPackages: ['mongoose', 'bcryptjs'],
  env: {
    MONGODB_URI: process.env.MONGODB_URI || 'mongodb://localhost:27017/medinova',
    JWT_SECRET: process.env.JWT_SECRET || 'medinova_dev_secret_change_in_prod',
    OPENAI_API_KEY: process.env.OPENAI_API_KEY || '',
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001',
  },
}

export default nextConfig
