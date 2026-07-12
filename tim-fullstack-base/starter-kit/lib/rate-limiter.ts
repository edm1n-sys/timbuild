// Simple in-memory token-bucket rate limiter.
// Resets on server restart — fine for dev. Swap with Redis/Upstash for production.

const buckets = new Map<string, { tokens: number; refillsAt: number }>()

interface RateLimitConfig {
  maxTokens: number    // e.g. 10 requests
  refillSeconds: number // per window
}

export function checkRateLimit(key: string, config: RateLimitConfig): {
  allowed: boolean
  remaining: number
  retryAfter: number
} {
  const now = Date.now()
  let bucket = buckets.get(key)

  if (!bucket || now >= bucket.refillsAt) {
    bucket = { tokens: config.maxTokens, refillsAt: now + config.refillSeconds * 1000 }
    buckets.set(key, bucket)
  }

  if (bucket.tokens > 0) {
    bucket.tokens--
    return { allowed: true, remaining: bucket.tokens, retryAfter: 0 }
  }

  return {
    allowed: false,
    remaining: 0,
    retryAfter: Math.ceil((bucket.refillsAt - now) / 1000),
  }
}

// Clean up expired entries every 5 minutes
if (typeof setInterval !== 'undefined') {
  setInterval(() => {
    const now = Date.now()
    for (const [key, bucket] of buckets) {
      if (now >= bucket.refillsAt) buckets.delete(key)
    }
  }, 300_000)
}

// Convenience presets
export const strict = { maxTokens: 10, refillSeconds: 60 } as const    // auth endpoints
export const moderate = { maxTokens: 60, refillSeconds: 60 } as const   // API routes
export const relaxed = { maxTokens: 300, refillSeconds: 60 } as const   // webhooks
