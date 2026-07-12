import { Prisma } from '@prisma/client'
import { db } from './db'

// Models that have organizationId — add to this set as you grow
const ORG_SCOPED_MODELS = new Set([
  'subscription',
  'member',
  'invitation',
] as const)

export function scopedDb(organizationId: string) {
  return db.$extends({
    query: {
      $allModels: {
        async $allOperations({ model, args, query }) {
          const modelName = model as unknown as string
          if (ORG_SCOPED_MODELS.has(modelName as any)) {
            if (args.where) {
              args.where.organizationId = organizationId
            } else {
              args.where = { organizationId }
            }
          }
          return query(args)
        },
      },
    },
  })
}
