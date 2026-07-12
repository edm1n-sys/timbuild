import { betterAuth } from 'better-auth'
import { prismaAdapter } from 'better-auth/adapters/prisma'
import { db } from '@/lib/db'
import { tanstackStartCookies } from 'better-auth/plugins/tanstack-start-cookies'

export const auth = betterAuth({
  database: prismaAdapter(db, {
    provider: 'postgresql',
  }),
  plugins: [
    tanstackStartCookies(),
  ],
  emailAndPassword: {
    enabled: true,
  },
  socialProviders: {},
})
