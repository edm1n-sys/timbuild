# 02_HARDEN_PROJECT � Launch-Day Hardening (Consolidated)

> **Pre-scan:** Before running this checklist, read the Layer 2 reference files:
> 1. \gent_terminology.md\ — confirms IS_HARDENED/OAUTH_PROD_READY flag semantics and evaluationDate rules.
> 2. \gent_schema.md\ — enforces tenant-scoped query isolation on every model.
> 3. \uild-terms.md\ — enforces Zod schema ↔ handler signature parity across all server functions.
> The agent must verify these are satisfied before staging any hardening fix.

> AI runs this checklist against the codebase before production deploy.
> Every item that can be a code guardrail is already wired in `starter-kit/`.
> Fix what fails. Escalate secrets rotation to the human.

---

## 1. Secrets & Environment

- [ ] `.env` is in `.gitignore` � confirm no `.env` committed.
- [ ] `BETTER_AUTH_SECRET` is a random 32+ char string.
- [ ] Stripe keys are live/test-appropriate for the environment.
- [ ] OAuth redirect URIs point to the correct environment.
- [ ] **Env validation is active** � `lib/env.ts` crashes on startup if
      `DATABASE_URL`, `BETTER_AUTH_SECRET`, or `BETTER_AUTH_URL` are missing.
- [ ] **Kill switch env var is documented** � set `KILL_SWITCH_ENABLED=true`
      to return 503 on all routes. File: `lib/kill-switch.ts`.
- [ ] No hardcoded API keys, tokens, or passwords in source files
      (grep for `sk_live`, `api_key`, `secret`, `token`, `password`).

---

## 2. Auth & Tenant Isolation

- [ ] Better Auth org plugin is enabled � `lib/auth.ts` includes `organization()`.
- [ ] Prisma has `Organization`, `Member`, `Invitation` models.
- [ ] **Prisma tenant scoping is wired** � `lib/tenant.ts` auto-filters queries
      by `organizationId` on scoped models.
- [ ] **Subscription guard middleware exists** � use `requireSubscription` from
      the middleware folder on all paid-tier routes.
- [ ] Role checks (owner/admin/member) are enforced server-side, not just in UI.
- [ ] Auth routes have rate limiting � use `lib/rate-limiter.ts` with `strict` preset.
- [ ] Sessions expire after a reasonable TTL.
- [ ] CSRF protection is active on mutation endpoints.

---

## 3. Input Validation

- [ ] **Zod validation pattern exists** � `lib/validation.ts` wraps schemas and
      returns structured 400 errors. Use it in every `createServerFn`.
- [ ] No string concatenation in database queries (Prisma is parameterized by default).
- [ ] User-supplied IDs are validated as UUIDs where applicable.

---

## 4. Rate Limiting

- [ ] **In-memory rate limiter is wired** � `lib/rate-limiter.ts` provides
      `strict`, `moderate`, and `relaxed` presets.
- [ ] Auth endpoints use `strict` (10 req/min per IP).
- [ ] API routes use `moderate` (60 req/min per user).
- [ ] Stripe webhook route uses `relaxed` or is excluded.

---

## 5. HTTP Security

- [ ] CORS is configured (not `*` in production).
- [ ] Helmet or equivalent security middleware is present.
- [ ] CSP headers restrict script sources.
- [ ] HSTS is set for production domains.
- [ ] Stack traces are not leaked to client responses.

---

## 6. Stripe & Payments

- [ ] Server-side payment processing � `sk_live` never appears in client bundle.
- [ ] **Webhook handler exists** � route that verifies signatures with
      `stripe.webhooks.constructEvent()`.
- [ ] **Webhook events handled:**
      - `checkout.session.completed` ? upsert Subscription
      - `customer.subscription.updated` ? sync status/period
      - `customer.subscription.deleted` ? mark canceled
- [ ] Billing fraud mitigation � rate-limit any action that triggers paid API calls.

---

## 7. Observability

- [ ] Sentry (or equivalent) is initialized on server + client.
- [ ] **Health endpoint exists** � `GET /api/health` returns `{ db: bool, queue: bool }`.
- [ ] Auth failures, DB mutations, and admin actions are logged externally.
- [ ] Hard spending alerts set with cloud providers (LLM API, Stripe, hosting).

---

## 8. Database & Backups

- [ ] Prisma migrations are checked into version control.
- [ ] Connection pooling is configured for production load.
- [ ] `DATABASE_URL` uses a non-superuser role in production.
- [ ] **Backup script exists** � `scripts/backup.sh` runs `pg_dump` and keeps
      7 days of snapshots. Schedule via cron / GitHub Actions.
- [ ] Point-in-time recovery is configured at the DB provider level.

---

## 9. Build & Deploy

- [ ] `npm run build` exits with 0.
- [ ] `tsc --noEmit` passes with zero errors.
- [ ] Production build tree-shakes correctly � no dev imports leaking.
- [ ] Dockerfile exists for production deployment.

---

## 10. Supply Chain & Process

- [ ] MFA is enforced on GitHub, cloud provider, domain registrar, and Stripe.
- [ ] Branch protection prevents direct pushes to main/production.
- [ ] No AI agent has credentials to spin up infrastructure.
- [ ] Dependency scan passes (npm audit, no hallucinated packages).

---

## Output

Print a summary table:

| Category             | Status | Issues |
|----------------------|--------|--------|
| Secrets & Env        | ?/?  | ...    |
| Auth & Tenancy       | ?/?  | ...    |
| Input Validation     | ?/?  | ...    |
| Rate Limiting        | ?/?  | ...    |
| HTTP Security        | ?/?  | ...    |
| Stripe & Payments    | ?/?  | ...    |
| Observability        | ?/?  | ...    |
| Database & Backups   | ?/?  | ...    |
| Build & Deploy       | ?/?  | ...    |
| Supply Chain         | ?/?  | ...    |

All pass ? project is hardened and ready for production.
