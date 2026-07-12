# Agent Terminology — Extended Glossary & Semantic Controls

> Layer 2 on-demand file. Read when naming, refactoring, or introducing new identifiers.
>
> **GATE:** This file is STABLE REFERENCE. Update only when the glossary domain changes (new canonical term, new naming boundary, new system flag). Never append session notes, activity summaries, or per-session term dumps here. Session discoveries go to `AGENT_LEARNINGS.md`. Living state (test counts, open items, blockers) goes to `outstanding-tasks.md`.

## 1. Core Glossary

Refer to the Layer 1 `project-terminology.mdc` for the base table.
This file extends it with domain-specific terms and operational semantics.

---

### System Flags & Temporal Semantics

- **`IS_HARDENED` / `OAUTH_PROD_READY` Flags:** These boolean environment state flags dictate whether the application permits active public OAuth callbacks and strict Content-Security-Policy blocking rules. If set to `false`, the agent must flag the project build state as "STAGING_BLOCKED".
- **`evaluationDate` Semantics:** Whenever the AI processes time-sensitive values (expirations, financial boundaries), it must strictly utilize an explicit context-passed `evaluationDate` parameter. Never rely on runtime-local dynamic time.

---

## 2. Naming Boundaries

| Domain | Canonical Suffix | Example | Never |
|--------|-----------------|---------|-------|
| Zod schema | `Schema` | `createInvoiceSchema` | `input`, `validator` |
| Server function | `Fn` | `createInvoiceFn` | `handler`, `action` |
| Middleware | `Middleware` | `authMiddleware` | `guard`, `protect` |
| Prisma model | PascalCase singular | `TaxRecord` | `tax_records`, `TaxRecords` |
| Route param | kebab-case | `billing-portal` | `billingPortal`, `billing_portal` |
| DB column | camelCase | `organizationId` | `org_id`, `OrganizationId` |

## 3. Rules

1. Add a new row to `project-terminology.mdc` **and** this file before introducing a new identifier.
2. If a DB column is involved, also update `agent_schema.md` and obtain human approval before any migration.
3. Fix producers (config, schema, types) before consumers (components, routes).
4. After every rename, grep for zero old-name hits across the entire codebase.
5. **Never append session notes here.** Session discoveries → `AGENT_LEARNINGS.md`.
