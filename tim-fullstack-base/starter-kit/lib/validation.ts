import { z } from 'zod'

// Wrap a Zod schema around any server function input.
// Throws a structured 400 response on mismatch.
export function validate<T>(schema: z.ZodSchema<T>, input: unknown): T {
  const result = schema.safeParse(input)
  if (!result.success) {
    throw new Response(JSON.stringify({
      error: 'Validation failed',
      details: result.error.flatten().fieldErrors,
    }), { status: 400, headers: { 'Content-Type': 'application/json' } })
  }
  return result.data
}

// Common reusable schemas
export const uuidSchema = z.string().uuid()
export const emailSchema = z.string().email()
export const organizationIdSchema = z.string().min(1, 'Organization ID required')
export const paginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
})
