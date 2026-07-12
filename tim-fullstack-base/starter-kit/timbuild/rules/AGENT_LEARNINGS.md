---
description: Long-term memory ledger for anti-patterns and session discoveries. Read before coding. Append after finding mistakes.
globs: 
alwaysApply: true
---
# Agent Learnings — Anti-Pattern & Discovery Ledger

> **Purpose:** Permanent record of mistakes, edge cases, and syntax nuances discovered during compilation loops.
> **Designated sink:** This is the ONLY file for session discoveries. Do NOT log discoveries to `agent_terminology.md`, `agent_schema.md`, or `build-terms.md` — those are stable reference files.
>
> **Agent Prompt:** Read this entire document before writing code to avoid repeating systemic architectural blunders.

---

## Critical Project Anti-Patterns

### 1. Tailwind CSS v4 — No Legacy Config

- **Discovery:** Do not attempt to add adjustments inside a root `tailwind.config.js`. It does not exist in this stack.
- **Fix Pattern:** All configurations, custom theme layouts, and variables must be written directly inside `app/global.css` using `@theme { ... }`.

### 2. TanStack Start — Server Function Auth

- **Discovery:** Route loaders (`beforeLoad`) do not prevent manual raw POST requests to server functions (`createServerFn`).
- **Fix Pattern:** Always wire auth middleware inside the server function itself via `createMiddleware()`. Never rely exclusively on the client router layer for data isolation.

### 3. Prisma — Tenant Scoping

- **Discovery:** Direct multi-tenant query filter mutation can collide with native ID fields.
- **Fix Pattern:** Safely check for existing `where` clauses before mapping structural `organizationId` locks. Use the `scopedDb()` helper from `lib/tenant.ts`.

### 4. Better Auth — SSR Cookie Boundary

- **Discovery:** Auth states can be intermittently lost during server-side rendering hydration.
- **Fix Pattern:** Ensure the `tanstackStartCookies()` plugin is active inside `lib/auth.ts`.

### 5. Environment Validation

- **Discovery:** The app will crash silently at runtime if env vars are missing.
- **Fix Pattern:** Import `lib/env.ts` at the app entry point so it crashes on startup with a clear message, not halfway through a request.

### 6. Architecture Pivot & Layout Duplication

- **Discovery:** Wrapper pivot without plan VERIFY amend → stale `variant=` in tracking and placeholder tests. **Layout:** column swap duplicated `FxReconciliationCard` — mount counts caught what tsc missed.
- **Fix Pattern:** Pivot must follow `plan-standards.mdc` §3c (record before SHIPPED) + `loop-engineering.mdc` Architecture Pivot Gate. Layout steps must use mount-count VERIFY per §3d and loop-engineering JSX Relocate Protocol. Delete before insert — never the reverse.

---

## Session Discoveries

*Agent: Append your discovery here if you hit an execution error, type mismatch, or edge case during your self-correction loop. Do NOT log to terminology/schema/build-terms.*

| Date | Target | Error | Resolution |
|------|--------|-------|------------|
|      |        |       |            |
|      |        |       |            |
