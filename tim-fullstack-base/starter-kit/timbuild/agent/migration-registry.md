# Flyway Migration Registry — SG/UK Pillar Two SaaS

> **Purpose:** Single source of truth for `conf/sql/` version numbers. Agents must READ before creating or editing migrations.
> **Updated:** 2026-07-12
> **Parent gate:** [`schema.md`](schema.md) relational-integrity block · [`scala-stack.mdc`](../rules/scala-stack.mdc)

---

## Version ladder

| Field | Value |
|-------|-------|
| **Highest version on disk** | V23 |
| **Next free version** | **V24** |
| **Migration directory** | `conf/sql/` |
| **Naming** | `V{N}__Snake_Case_Description.sql` |

---

## Known conflict (do not worsen)

| Version | Files | Status |
|---------|-------|--------|
| **V19** | `V19__Pillar2_External_Registration.sql` **and** `V19__HK_Filing_Hash.sql` | **DUPLICATE PREFIX** — Flyway may apply unpredictably. Do **not** add another `V19__`. Human renumber/reconcile required before production deploy. |

---

## All migrations (V1–V23)

| Ver | File |
|-----|------|
| V1 | `V1__init.sql` |
| V2 | `V2__Enforce_RLS.sql` |
| V3 | `V3__Filing_Outbox.sql` |
| V4 | `V4__RAG_Pipeline.sql` |
| V5 | `V5__Country_Code_Uniqueness.sql` |
| V6 | `V6__Waitlist.sql` |
| V7 | `V7__Review_State.sql` |
| V8 | `V8__AI_Audit_Log.sql` |
| V9 | `V9__Filing_Integrity_Hash.sql` |
| V10 | `V10__Rag_Evaluations.sql` |
| V11 | `V11__RAG_Embedding_Dimension.sql` |
| V12 | `V12__Waitlist_Grants.sql` |
| V13 | `V13__Cpa_Client_Assignments.sql` |
| V14 | `V14__Tenant_Billing.sql` |
| V15 | `V15__Stripe_Customer_Index.sql` |
| V16 | `V16__Deletion_Certificates.sql` |
| V17 | `V17__Dev_Mock_Tenant_Professional.sql` |
| V18 | `V18__HK_IRD_Filing.sql` |
| V19 | `V19__Pillar2_External_Registration.sql` ⚠ |
| V19 | `V19__HK_Filing_Hash.sql` ⚠ duplicate |
| V20 | `V20__HK_RLS_Policies.sql` |
| V21 | `V21__HK_IRD_Audit_Log.sql` |
| V22 | `V22__HK_Notification_Persistence.sql` |
| V23 | `V23__Filing_Approval_Snapshot.sql` |

---

## New migration checklist

Before committing `V{N}__*.sql`:

1. **READ** this file — `N` must equal **Next free version** (currently V24).
2. **Glob** `conf/sql/V{N}__*` — must be **exactly one** file for that prefix.
3. **Tenant tables** (`hk_*`, workspace-scoped data): add RLS policies — see `V2__Enforce_RLS.sql`, `V20__HK_RLS_Policies.sql`.
4. **Queries** in app code: use `SecureDbContext` / workspace context — see `schema.md` gate.
5. **Forbidden** without explicit user approval: column renames, dropping columns, changing `vector` dimensions without coordinated app deploy.
6. **Update this registry** in the same commit: add row to table above; bump **Next free version** to V{N+1}.

---

## VERIFY (plan step or pre-commit)

| # | Claim | Command / Read | Pass when |
|---|-------|----------------|-----------|
| 1 | Next version used | `Read` this file — Next row | new file matches Next |
| 2 | No duplicate prefix | `Glob conf/sql/V{N}__*` | exactly **1** file for chosen N |
| 3 | Registry updated | `Read` migration-registry.md | new row present; Next bumped |
| 4 | No new duplicate V19 | `Glob conf/sql/V19__*` | still 2 files max — never add 3rd |

---

## Gate discipline

After adding a migration, update **only** the version table and Next row in this file — not a new session appendix. Cross-link route/controller changes in `schema.md` gate if new tables affect API surface.
