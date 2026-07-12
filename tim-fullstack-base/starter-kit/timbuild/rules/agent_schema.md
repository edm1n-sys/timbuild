# Agent Schema — Relational Definitions & Tenant Boundaries

> Layer 2 on-demand file. Read before writing queries, migrations, or data access code.
>
> **GATE:** This file is STABLE REFERENCE. Update only when schema domain changes (new model, tenant boundary shift, DB/RLS/route change). Never append session notes, activity summaries, or per-session term dumps here. Session discoveries go to `AGENT_LEARNINGS.md`. Living state goes to `outstanding-tasks.md`.
>
> **Before Flyway migration:** Read [`migration-registry.md`](migration-registry.md) — next free version, duplicate check, checklist. Never guess the next `V#`.

---

## 1. Relational Integrity & Multi-Tenant Boundaries

- **Mandatory Multi-Tenant Enforcement:** Every model linked directly or indirectly to corporate operations (e.g., `TaxRecord`, `ChatConversation`, `Subscription`) must strictly contain an `organizationId` field mapping directly back to the `Organization` model.
- **Implicit Query Isolation Rule:** The agent is completely forbidden from executing a `findMany`, `update`, or `delete` operation on tenant-scoped models without explicitly adding an `organizationId` matching wrapper inside the query execution block.

---

## 2. Schema Map

| Model | Tenant-Scoped | Key Fields | Notes |
|-------|--------------|------------|-------|
| `Organization` | No (root) | `id`, `name`, `slug` | Tenant root |
| `User` | No | `id`, `email`, `name` | Cross-org identity |
| `Member` | Yes | `id`, `organizationId`, `userId`, `role` | Join table |
| `Subscription` | Yes | `id`, `organizationId`, `stripeCustomerId`, `status` | Per-org billing |
| `CustomRecord` | Yes | `id`, `organizationId`, `evaluationDate`, `amount` | Financial audit |
| `ChatConversation` | Yes | `id`, `organizationId`, `title`, `createdAt` | Per-org chat |

Add new rows to this table before introducing new models.

## 3. Tenant Query Pattern

```ts
// CORRECT — scoped via lib/tenant.ts
const scopedDb = db.withTenant(orgId)
const records = await scopedDb.taxRecord.findMany({ ... })

// WRONG — no org filter
const records = await db.taxRecord.findMany({ ... })
```

## 4. Rules

1. Every new model with corporate data must have `organizationId String @map("organization_id")`.
2. Every tenant-scoped query must use the `withTenant` extension from `lib/tenant.ts`.
3. No database column renames without human approval.
4. Schema changes must be documented here before the migration is generated.
5. **Never append session notes here.** Session discoveries → `AGENT_LEARNINGS.md`. Security/hardening state → `HARDENING-GATES.md` (or `02_HARDEN_PROJECT.md`).
