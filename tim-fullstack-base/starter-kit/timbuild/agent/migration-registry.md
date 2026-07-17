# Migration Registry — Flyway Version Ladder

> **Purpose:** Single source of truth for `conf/sql/` version numbers. Agents must READ before creating or editing migrations.
> **Parent gate:** [`agent_schema.md`](../rules/agent_schema.md) relational-integrity block · [`scala-stack.mdc`](../rules/scala-stack.mdc)
> **Updated:** (set date on first migration)

---

## Version ladder

| Field | Value |
|-------|-------|
| **Highest version on disk** | V23 |
| **Next free version** | **V24** |
| **Migration directory** | `conf/sql/` |
| **Naming** | `V{N}__Snake_Case_Description.sql` |

---

## Known conflicts (do not worsen)

| Version | Files | Status |
|---------|-------|--------|
| (add rows when duplicates found) | — | — |

---

## All migrations

| Ver | File |
|-----|------|
| (add rows as migrations are created) | `V1__init.sql` |

---

## New migration checklist

Before committing `V{N}__*.sql`:

1. **READ** this file — `N` must equal **Next free version**.
2. **Glob** `conf/sql/V{N}__*` — must be **exactly one** file for that prefix.
3. **Tenant tables:** add RLS policies — see existing `V*__Enforce_RLS.sql` / `V*__RLS_Policies.sql` for patterns.
4. **Queries** in app code: use `SecureDbContext` / workspace context — see `agent_schema.md` gate.
5. **Forbidden** without explicit user approval: column renames, dropping columns, changing `vector` dimensions without coordinated app deploy.
6. **Update this registry** in the same commit: add row to table above; bump **Next free version** to V{N+1}.

---

## VERIFY (plan step or pre-commit)

| # | Claim | Command / Read | Pass when |
|---|-------|----------------|-----------|
| 1 | Next version used | `Read` this file — Next row | new file matches Next |
| 2 | No duplicate prefix | `Glob conf/sql/V{N}__*` | exactly **1** file for chosen N |
| 3 | Registry updated | `Read migration-registry.md` | new row present; Next bumped |

---

## Gate discipline

After adding a migration, update **only** the version table and Next row in this file — not a new session appendix. Cross-link route/controller changes in `agent_schema.md` gate if new tables affect API surface.
