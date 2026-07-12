// Minimal kill switch — disable all non-auth routes with one env var.
// Set KILL_SWITCH_ENABLED=true and the app redirects all traffic to a maintenance page.

export function isKillSwitchActive(): boolean {
  return process.env.KILL_SWITCH_ENABLED === 'true'
}

// Use in root layout or middleware to return a 503 before any route handler runs.
export function maintenanceResponse(): Response {
  return new Response(
    JSON.stringify({
      error: 'Service temporarily disabled',
      code: 'MAINTENANCE_MODE',
      retryAfter: '5 minutes',
    }),
    { status: 503, headers: { 'Content-Type': 'application/json', 'Retry-After': '300' } },
  )
}
