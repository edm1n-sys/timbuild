// Crash on startup if critical env vars are missing.
// Import this first in your app entry.

const REQUIRED = [
  'DATABASE_URL',
  'BETTER_AUTH_SECRET',
  'BETTER_AUTH_URL',
] as const

const STRIPE_REQUIRED = [
  'STRIPE_SECRET_KEY',
  'STRIPE_PUBLISHABLE_KEY',
  'STRIPE_WEBHOOK_SECRET',
] as const

function validateEnv() {
  const missing: string[] = []

  for (const key of REQUIRED) {
    if (!process.env[key]) missing.push(key)
  }

  // Only validate Stripe vars if at least one is set (opt-in)
  const hasAnyStripe = STRIPE_REQUIRED.some(k => process.env[k])
  if (hasAnyStripe) {
    for (const key of STRIPE_REQUIRED) {
      if (!process.env[key]) missing.push(key)
    }
  }

  if (missing.length > 0) {
    console.error('Missing required environment variables:')
    missing.forEach(k => console.error(`  ? ${k}`))
    process.exit(1)
  }

  console.log('? Environment validated')
}

validateEnv()
