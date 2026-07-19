# Agent — Project Overview

> Read this at the start of every session. It routes you to the right files for your task.

## ⚠️ CRITICAL: .mdc files are NOT optional

This project uses `.mdc` files (`timbuild/rules/*.mdc`) for project-critical instructions.
There are 13 Layer 1 rule files — every agent must read them all.

**Do NOT skip `.mdc` files.** They are NOT editor-specific metadata. They contain mandatory
project rules that apply to ALL AI agents (opencode, Cursor, Codex, Claude, etc.).

If you are NOT running inside an editor that auto-injects `.mdc` files, you MUST
read them manually. Start with `agent-index.mdc` to identify your task type,
then read the other `.mdc` files listed in Layer 1 below.

## Two-agent workflow (Plan Author + Executor + Auditor)

This project uses **three separate agents** with different prompts. Never give two roles to one agent.

| Role | Prompt file | Job | Forbidden |
|------|-------------|-----|-----------|
| **Plan Author** | [`plan-author-protocol.mdc`](plan-author-protocol.mdc) | Write plans with runnable VERIFY tables. Mark EXECUTABLE. | Editing code, implementing steps |
| **Executor** | [`executor-protocol.mdc`](executor-protocol.mdc) | Run ONE step per session. Follow [`loop-engineering.mdc`](loop-engineering.mdc). CONTRACT → VERIFY → checkpoint. Deliverable: DELIVERED FOR AUDIT. | Writing plans, expanding scope, self-advancing steps, saying SHIPPED |
| **Auditor** | [`auditor-adversarial.mdc`](auditor-adversarial.mdc) | **Break the implementation.** Run VERIFY + 8 attack vectors + scoped tests. Deliver audit finding table. | Marking SHIPPED; trusting executor summary; Glob-only file existence; skipping Phase 2 attacks |

**Flow:** Executor → DELIVERED FOR AUDIT → **Auditor (new session)** → PASS/PARTIAL/FAIL report → Human marks SHIPPED.

**Handoff:** Plan Author produces a [`handoff-packet.md`](../templates/handoff-packet.md) for each step. Executor pastes the CONTRACT table before editing. **No CONTRACT paste → STOP.**

**Full workflow guide:** [`TWO-AGENT-WORKFLOW.md`](../templates/TWO-AGENT-WORKFLOW.md) — one-page printable reference with cheat sheet commands and handoff packet template.

**Human is the only one who advances step N → N+1.**

```
Plan Author (P)                Executor (X)                  Human
┌──────────────────┐          ┌──────────────────┐          ┌─────┐
│ Write plan       │          │ READ pre-state    │          │     │
│ VERIFY tables    │──┐       │ CONTRACT paste    │          │     │
│ Pre-state check  │  │       │ PROPOSE scope     │          │     │
│ EXECUTABLE: yes  │  │       │ TEST implement    │          │     │
└──────────────────┘  │       │ VERIFY re-paste   │          │     │
                      │       │ Checkpoint SHIPPED│          │     │
                      │       └──────────────────┘          │     │
                      │                │                     │     │
                      ▼                ▼                     │     │
              ┌──────────────────┐                          │     │
              │ handoff-packet.md│◄─────────────────────────┘     │
              │ (CONTRACT table) │────────► approve → next step  │
              └──────────────────┘                               │
                                                                 │
  1. Plan Author → EXECUTABLE plan                               │
  2. Human copies VERIFY table into handoff-packet.md            │
  3. Executor → one step → checkpoint SHIPPED/BLOCKED            │
  4. Human pastes checkpoint into outstanding-tasks.md           │
  5. Human creates next handoff packet → repeat                  │
```

## Authority stack (3 layers)

| Layer | Files | When to read |
|-------|-------|-------------|
| **Layer 1 — Project rules** | `timbuild/rules/*.mdc` (13 files) | **Every session.** `project-terminology.mdc`, `execution-principles.mdc`, `encoding-standards.mdc`, `loop-engineering.mdc`, `plan-standards.mdc`, `plan-author-protocol.mdc`, `executor-protocol.mdc`, `executor-exit.mdc`, `auditor-adversarial.mdc`, `memory.mdc`, `preserve-features.mdc`, `scala-stack.mdc`, `agent-index.mdc` |
| **Layer 2 — Session routing** | `agent.md` + `outstanding-tasks.md` + task-type files via `agent-index.mdc` | Every session. `agent-index.mdc` routes **P** (Plan Author) / **X** (Executor) / **A-I** (domain types under X). |
| **Layer 3 — On demand** | `coding-skills.md`, `AGENT_LEARNINGS.md` | When writing code (skills by number) or avoiding past mistakes. |

Correct: read Layer 1 `.mdc` files first, then Layer 2 session routing, then Layer 3 on demand.
Wrong: skip `.mdc` files because "they're just metadata."

### Which file does what

| You need to... | Read |
|---------------|------|
| Write a plan (Plan Author) | `plan-author-protocol.mdc` + `plan-standards.mdc` |
| Execute one plan step (Executor) | `executor-protocol.mdc` + `loop-engineering.mdc` |
| Audit executor's work (Auditor) | `auditor-adversarial.mdc` — break the implementation, 8 attack vectors, do not trust summary |
| Run a plan step with proof | `loop-engineering.mdc` (execution protocol) |
| Run a plan step with proof | `loop-engineering.mdc` (execution protocol) |
| Write a plan that ships with VERIFY tables | `plan-standards.mdc` (authoring contract) |
| Look up a skill by number | `coding-skills.md` (numbered index → points to canonical files) |
| Know what .scala/.sql rules apply | `scala-stack.mdc` + `migration-registry.md` |
| Know your task type routing | `agent-index.mdc` |
| Understand the project | `agent.md` (this file) |

## Loop Engineering — Self-Contained Instructions

> Copy this section into any agent prompt. No external file reads needed.
> **Protocol = mandatory bootstrap.** For unfamiliar or multi-step work, still read the full 13 `.mdc` files and Layer 2 files for your task type.

### The loop (per plan step — do not batch across steps)

```
READ → CONTRACT → PROPOSE → TEST → VERIFY → REPEAT/CHECKPOINT → SELF-REVIEW → STOP or deliver
```

| Phase | Agent must | Forbidden |
|-------|------------|-----------|
| **READ** | Execute pre-state commands from the plan step (grep, Read, Glob). Record baseline. Never edit before READ. | Coding before READ block written |
| **CONTRACT** | **Open the step's VERIFY table. Read it aloud — cite every row's Claim and Pass-when. Do not edit until you can name every row.** | Internalizing intent without having the table open; treating VERIFY as closing checklist |
| **PROPOSE** | List exact files, symbols, before/after; cite verify command from plan | Vague "will implement X" |
| **TEST** | Implement **only this step**; run step verify command | Implementing N+1 while N unverified |
| **VERIFY** | **Paste the step's VERIFY table with every row annotated PASS or FAIL.** Include command exit codes or file:line citations. If any row is FAIL, return to TEST. | Citing conversationally without a structured record; ✅ from diff memory or prior turn |
| **REPEAT/CHECKPOINT** | All rows PASS → print §4 checkpoint with Status SHIPPED, PARTIAL, or BLOCKED. | Advance to next step with any FAIL row; skip checkpoint output |
| **SELF-REVIEW** | Before delivering: run §1b self-audit. **Do not** end with a passive "ready for next step?" — answer §1b questions in the deliverable. | Delivering without self-audit; no follow-up question |
| **STOP or deliver** | **STOP** if SELF-REVIEW finds gaps. **Deliver** checkpoint + SELF-REVIEW table when audit passes. | Ship-and-pray; passive handoff |

**Hard rule:** No step is ✅ until VERIFY evidence table is all ✅. No phase is complete while any step lacks VERIFY evidence.
**Hard rule:** The VERIFY table is the authorization to edit, not a closing checklist. If you cannot paste it before proposing, you are not ready to edit.
**Hard rule:** SHIPPED only when SELF-REVIEW #1 is Yes and every CONTRACT row PASS. PARTIAL @ hash for honest FAIL. BLOCKED for missing table or broken commands.

### Plan VERIFY Contract

The plan is a contract. Every step's VERIFY table defines what "done" means.

1. **Run the plan table verbatim.** Every command in the plan's VERIFY table must be executed, with output pasted as evidence.
2. **VERIFY output maps 1:1 to plan rows.** If the plan lists 4 claims, your VERIFY must have exactly those 4 rows — no more, no fewer.
3. **Stop if the plan has no VERIFY table.** If a step lacks a `| Claim | Command / Read | Pass when |` table, it is **BLOCKED**. Flag it — do not invent your own verification.
4. **Any single ❌ = NOT SHIPPED.** Revert to TEST → fix → re-VERIFY. Do not ship ❌ as "deferred" without user approval in Open Issues.
5. **Amendment gate — plan-drift forbidden.** If implementation diverges from the plan (new file not listed, symbol renamed, different approach, dropped step), **STOP** — do not adapt silently. Update the plan's §Implementation and VERIFY tables to match the new design, then resume. **Forbidden:** ship code implementing Option B while the plan still describes Option A.

### Required output per step

```markdown
### Step X.Y — READ
- Plan requires: …
- Pre-state: … (file:line or "symbol absent")
- Test file: … (path or MISSING)

### Step X.Y — PROPOSE
- Files: …
- Change: …
- Verify: `command`

### Step X.Y — TEST
- (commands run + exit codes)

### Step X.Y — VERIFY
| Claim | Evidence | Pass |
|-------|----------|:----:|
| … | rg / Read line | ✅/❌ |
```

### Checkpoint table (after every step)

**Print once per step. Includes SELF-REVIEW — see [`loop-engineering.mdc`](loop-engineering.mdc) §4 + §1b for full template.**

```markdown
### Checkpoint — Plan NNN Step X.Y
| Phase | Evidence |
|-------|----------|
| READ | [pre-state grep/Read outputs] |
| CONTRACT | [VERIFY table pasted verbatim — pre-edit] |
| PROPOSE | [files + symbols] |
| TEST | [files touched] |
| VERIFY | See annotated table below |
| SELF-REVIEW | [§1b table — mandatory; #1 Evidence must cite same commands as VERIFY PASS rows] |
| **Status** | BLOCKED | PARTIAL @ hash | SHIPPED |
```

SHIPPED only when every CONTRACT row PASS **and** SELF-REVIEW #1 = Yes.
- "Phase complete"
- "All tests green" (without per-step evidence)
- "Ready for next phase"
- Starting step N+1 while step N has any VERIFY ❌

### Definition of Done (step)

1. READ documented with pre-state grep/Read proof
2. Code matches plan — post-state grep proves symbols + wiring
3. Plan-listed tests **exist on disk** and pass (or logged in Open Issues as deferred)
4. VERIFY table all ✅
5. `outstanding-tasks.md` top entry updated with verify commands + counts

### Definition of Done (phase)

All steps SHIPPED **plus** phase verify block once:

```bash
npx tsc --noEmit
npx vitest run <scoped>
```

### Anti-patterns

| Anti-pattern | VERIFY catch |
|--------------|--------------|
| Status ✅ from conversation memory | `rg` / `Glob` in **this** session |
| "17 vitest + 6 sbt" but spec file missing | `Glob **/*Spec*` for named spec |
| Consolidation step without new module | `Glob **/module-name.ts` |
| Skip to next phase with open VERIFY ❌ | Checkpoint blocks advance |

### VERIFY: Right vs Wrong

Every VERIFY row must cite a **concrete command from this session** — not memory, not "looks correct":

| ❌ Wrong (rejected) | ✅ Right (accepted) |
|---------------------|---------------------|
| "Mobile sheet implemented" | `rg 'variant.*mobile-sheet' DataReviewAssistantPanel.tsx` → line 142 |
| "Schema updated" | `Read schema.md L42-47` → no duplicate tier rows |
| "Tests pass" | `npx vitest run auth.test.ts` → exit code 0 |
| "Component mounted" | `rg 'export function MobileFAB' src/components/` → found in MobileFAB.tsx |
| "Config synced" | `rg 'MyConfig' src/config/ --count` → 6 files match |

**If the plan step has no concrete VERIFY command, the step is BLOCKED.** Flag it to the user.
Do not implement a step that cannot be proved complete with grep/Read evidence.

**Full protocol:** [`loop-engineering.mdc`](loop-engineering.mdc) — Architecture Pivot Gate, JSX Relocate Protocol, worked examples, expanded anti-patterns.

---

## Layer 2 Agent Files (read on demand)

| File | Purpose | When to Read |
|------|---------|-------------|
| [`agent_schema.md`](agent_schema.md) | DB tables, RLS, routes, tenant boundaries | Schema/migration work |
| [`migration-registry.md`](migration-registry.md) | Flyway version ladder, Next V#, duplicate check | **Any `conf/sql/` touch** |
| [`agent_terminology.md`](agent_terminology.md) | Extended glossary, hardening flags | Terminology/naming changes |
| [`build-terms.md`](build-terms.md) | Route wiring terms, signature parity, drift checks | Server function work |
| [`AGENT_LEARNINGS.md`](AGENT_LEARNINGS.md) | Anti-patterns, session discoveries | Every session |

## Backend Stack Lock (2026-07-12)

> **Scala 3.3.7 · Play 3.x · Pekko · AppDependencies-only · Flyway registry**

| Edition | File | Rule |
|---------|------|------|
| Scala 3.3.7 | [`scala-stack.mdc`](scala-stack.mdc) | No Scala 2, no Akka, Pekko-only imports, `@Inject`/`given`/`using` |
| Play 3.x · Pekko | [`scala-stack.mdc`](scala-stack.mdc) | `org.playframework` / `org.apache.pekko` — never `com.typesafe.play` |
| Dependency surface | [`scala-stack.mdc`](scala-stack.mdc) | Only `project/AppDependencies.scala` — never inline in `build.sbt` |
| Flyway ladder | [`migration-registry.md`](migration-registry.md) | Next version = V24 — read before any `conf/sql/` touch |

**Default routing:** Any `.scala` edit → [`scala-stack.mdc`](scala-stack.mdc). Any `conf/sql/` touch → [`migration-registry.md`](migration-registry.md). Task types A, D, E → full `TimBuild/` paths per [`agent-index.mdc`](agent-index.mdc).

## Gate Docs (stable reference, update only on infrastructure change)

| Gate | Covers | Update when |
|------|--------|-------------|
| [`migration-registry.md`](migration-registry.md) | Flyway V# ladder, duplicate check, RLS checklist | Every SQL migration |
| [`agent_schema.md`](agent_schema.md) | Models, tenant boundaries, query patterns | New model, RLS change |
| [`scala-stack.mdc`](scala-stack.mdc) | Scala version, deps, DI, import surface | Play/Scala version bump |
| [`build-terms.md`](build-terms.md) | Compilation bounds, signature parity | Compilation domain change |

**Anti-contamination:** Never append session notes or per-session term dumps to gate docs. Session logs → `outstanding-tasks.md`. Discoveries → `AGENT_LEARNINGS.md`.

---

## Session start checklist

Before writing any code, read in this order:

1. **All `.mdc` files in `timbuild/rules/`** — project rules and task routing
2. **Pick role:** P (Plan Author), X (Executor), or A (Auditor) — see `agent-index.mdc` Role Routing + workflow below. If X: human must give plan path + single step ID. If A: human must give plan path + executor session reference. Never combine roles in one session.
3. **`loop-engineering.mdc`** — mandatory execution protocol: READ → CONTRACT → PROPOSE → TEST → VERIFY → REPEAT/CHECKPOINT → SELF-REVIEW → STOP or deliver
4. **`outstanding-tasks.md`** — living state: test baseline, open items, handoff
5. **`scala-stack.mdc`** — if any `.scala` file is touched (Scala version, deps, DI lock); **`migration-registry.md`** — if any `conf/sql/` file is touched
6. **`AGENT_LEARNINGS.md`** — anti-patterns from prior sessions
7. **This file** — project overview, architecture, key files
8. **Task-specific Layer 2 files** — based on your task type from `agent-index.mdc`

## When to read what

| Scenario | Read this first |
|----------|----------------|
| **Any `.scala` file** | `scala-stack.mdc` — Scala 3.3.7, Play 3.x, Pekko, AppDependencies-only. `sbt compile` mandatory after edit. |
| **Any `conf/sql/` file** | `migration-registry.md` — Flyway version ladder, Next V#, duplicate check |
| **Executing a plan step or task** | `loop-engineering.mdc` — mandatory per-step READ→CONTRACT→PROPOSE→TEST→VERIFY→REPEAT/CHECKPOINT→SELF-REVIEW loop |
| **Brand new project, empty folder** | `01_START_PROJECT.md` — bootstrap the full stack |
| **Coming back to an existing project** | `outstanding-tasks.md` (sole source of living state) — test baseline, open items, owner blockers, handoff |
| **Building a new feature** | `templates/SPEC.md` → (after approval) `templates/PLAN.md` |
| **Pre-launch hardening** | `02_HARDEN_PROJECT.md` + `agent_terminology.md` + `agent_schema.md` + `build-terms.md` |
| **Adding/changing terminology** | `agent_terminology.md` (after updating `project-terminology.mdc`) |
| **Writing queries or migrations** | `agent_schema.md` + `migration-registry.md` — tenant boundaries, model map, version ladder |
| **Writing Scala backend code** | `scala-stack.mdc` — stack lock (Scala 3.3.7, Play 3, Pekko, AppDependencies-only). Read before any `.scala` edit. |
| **Writing server functions** | `build-terms.md` — signature parity rules |
| **End of session** | `templates/SESSION_HANDOFF.md` — fill this out before stopping |

## Stack

- **Frontend:** TanStack Start (React 19, SSR, file-based routing)
- **Auth:** Better Auth (Prisma adapter, org plugin, TanStack Start cookies)
- **Database:** PostgreSQL via Prisma ORM
- **Backend (optional):** Scala 3.3.7, Play Framework 3.x, Pekko, Flyway — see `scala-stack.mdc`
- **Background jobs:** pg-boss
- **UI:** shadcn/ui with Tailwind CSS v4
- **Payments:** Stripe (optional, opt-in)

## Architecture

```
app/               TanStack Start routes, router, client/SSR entry, CSS
lib/               Auth, DB, validation, rate limiting, tenant, env, kill switch
prisma/            Schema and migrations
conf/sql/          (Flyway migrations — see migration-registry.md)
workers/           pg-boss background job handlers
```

## Key Files

| File | Purpose |
|------|---------|
| `lib/auth.ts` | Better Auth server config with org plugin |
| `lib/auth-client.ts` | Better Auth browser client |
| `lib/db.ts` | Prisma singleton |
| `lib/env.ts` | Env validation (crashes on startup if vars missing) |
| `lib/rate-limiter.ts` | Token-bucket rate limiter |
| `lib/validation.ts` | Zod schema validation wrapper |
| `lib/tenant.ts` | Prisma extension for org-scoped queries |
| `lib/kill-switch.ts` | 503 maintenance mode |
| `workers/pg-boss.ts` | Background job client |
| `prisma/schema.prisma` | User, Session, Account, Org, Member, Subscription |
| `scala-stack.mdc` | Scala 3.3.7 lock — version, deps, DI, forbidden imports |
| `migration-registry.md` | Flyway version ladder — Next V#, duplicate check, checklist |

## Critical Rules

1. **Read all `.mdc` files first.** They are project rules, not Cursor metadata.
2. **Loop engineering (mandatory):** Follow [`loop-engineering.mdc`](loop-engineering.mdc) for every task: **READ → CONTRACT → PROPOSE → TEST → VERIFY → REPEAT/CHECKPOINT → SELF-REVIEW → STOP or deliver**. No step is done until VERIFY evidence table is all ✅. Print a checkpoint table after every step. Never start step N+1 while step N has any VERIFY ❌.
3. **No tailwind.config.js:** All Tailwind v4 theme goes in `app/global.css` via `@theme`.
4. **Server-side auth:** Always use `createMiddleware()` for server function auth, not just route `beforeLoad` guards.
5. **Tenant isolation:** Use `scopedDb(orgId)` from `lib/tenant.ts` for org-scoped queries.
6. **Read AGENT_LEARNINGS.md** before starting any coding session.
7. **Scala stack lock (mandatory):** Before any `.scala` edit, read [`scala-stack.mdc`](scala-stack.mdc). Scala 3.3.7 only. Play 3.x / Pekko. Dependencies only in `AppDependencies.scala`. No Akka, no Scala 2, no inline `build.sbt` deps. `sbt compile` mandatory after edit. **Default routing: `.scala` → [`scala-stack.mdc`](scala-stack.mdc).**
8. **Migration lock (mandatory):** Before any `conf/sql/` touch, read [`migration-registry.md`](migration-registry.md). Never guess the next V#. Update the registry in the same commit as the migration. **Default routing: `conf/sql/` → [`migration-registry.md`](migration-registry.md).**
9. **CI cost policy:** Mock E2E every PR (~3-5 min, cheap). Fullstack health checks nightly + manual only (~10-15 min, expensive). Path filters skip CI on doc-only commits. See [`build-terms.md`](build-terms.md) §5 CI Cost Policy.
