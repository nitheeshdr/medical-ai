import type { Config } from 'tailwindcss'

const config: Config = {
  content: ['./src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        black: '#000000',
        surface: '#111111',
        elevated: '#1A1A1A',
        border: '#2A2A2A',
        primary: '#FFFFFF',
        secondary: '#B5B5B5',
        tertiary: '#6B6B6B',
        success: '#22C55E',
        warning: '#F97316',
        danger: '#EF4444',
      },
      fontFamily: {
        mono: ['var(--font-mono)', 'monospace'],
      },
    },
  },
  plugins: [],
}

export default config
