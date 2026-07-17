# Two-Agent Workflow — One-Page Reference

> **Print this.** Keep it open. Points to [`loop-engineering.mdc`](..\timbuild\rules\loop-engineering.mdc) for full protocol — this file is the cheat sheet.

---

## Roles

| Role | Prompt | Scope | Deliverable |
|------|--------|-------|-------------|
| **P** (Plan Author) | `plan-author-protocol.mdc` + `plan-standards.mdc` | Write plans with VERIFY tables; **never** implement | EXECUTABLE plan + step list |
| **X** (Executor) | `executor-protocol.mdc` + `loop-engineering.mdc` | **One plan step per session** | Checkpoint (§4) + **SELF-REVIEW** (§1b): annotated VERIFY, Status, 3-row self-audit |

> \* Executor uses `executor-protocol.mdc` + `loop-engineering.mdc` — these are the canonical protocol files. `agent.md` contains the self-contained bootstrap prompt.

---

## Flow

```
Plan Author → EXECUTABLE plan + VERIFY per step
       │
       ▼
You → set ACTIVE packet in outstanding-tasks.md (one step ID)
       │
       ▼
Executor → READ → CONTRACT → PROPOSE → TEST → VERIFY
            → CHECKPOINT → SELF-REVIEW → STOP or deliver
       │
       ▼
You → paste checkpoint + SELF-REVIEW into outstanding-tasks.md
       │
       ▼
Next session → Step N+1 only if prior Status SHIPPED (or programme allows PARTIAL)
```

---

## Cheat sheet

| You want... | Say |
|-------------|-----|
| **Run one step** | "Execute ACTIVE packet. Role X. Plan NNN Step X only." |
| **Record completion** | Paste full checkpoint + SELF-REVIEW into `outstanding-tasks.md` — not "done" or link-only |
| **Reject bad handoff** | "Missing SELF-REVIEW" / "VERIFY row without evidence" / "SHIPPED but self-audit #1 = No" |

---

## Executor packet (you fill — paste into `outstanding-tasks.md` top block `## Executor Packet`)

```markdown
## Executor Packet — Plan NNN Step X

**Plan:** {{PLANS_PATH}}/NNN-name.md
**Step:** X only (do not start next step)
**Prerequisite:** [N/A | prior checkpoint SHIPPED @ commit abc123]
**Forbidden:** [list out-of-scope steps, files, programmes — from plan]
**Role:** X

**CONTRACT (paste before any edit):**

| # | Claim | Command / Read | Pass when |
|---|-------|----------------|-----------|
| 1 | [copy from plan] | `[copy from plan]` | [copy from plan] |
| 2 | [copy from plan] | `[copy from plan]` | [copy from plan] |

**Deliverable (mandatory — [`loop-engineering.mdc`](..\timbuild\rules\loop-engineering.mdc) §4 + §1b):**
1. Checkpoint: READ | CONTRACT | PROPOSE | TEST | VERIFY (annotated table) | Status
2. SELF-REVIEW: 3-row table (CONTRACT verified? | Human question? | Unclear for next step?)
3. Deliver decision: STOP | DELIVER SHIPPED | DELIVER PARTIAL | DELIVER BLOCKED

**Forbidden closers:** "Ready for next step?" without §1b answers.
**Do not start step N+1 in this session.**
```

---

## Accepting an executor deliverable

| Check | Pass when |
|-------|-----------|
| CONTRACT table | Pasted pre-edit; VERIFY re-pasted with PASS/FAIL + exit codes / `path:line` |
| Status | SHIPPED only if every CONTRACT row PASS **and** SELF-REVIEW #1 = Yes |
| SELF-REVIEW #2–3 | Explicit **None** or concrete items — not omitted |
| Scope | Files match packet Forbidden line; no step N+1 work |
| Living state | You paste checkpoint into `outstanding-tasks.md`; executor does not mark programme SHIPPED alone |

**PARTIAL / BLOCKED** are valid — still require SELF-REVIEW and honest FAIL rows.

---

## Who asks what

| Actor | When |
|-------|------|
| **Executor (SELF-REVIEW)** | Before deliver: "CONTRACT fully verified?" "Human question?" "Unclear for next step?" — answers in deliverable |
| **Human (router)** | Between sessions: set next ACTIVE packet; answer executor #2 if not None; amend Forbidden if scope changes |

Executor does **not** wait for "go ahead" on the next step — it delivers §1b and **stops**. Human starts the next session with a new packet.

---

## Example tail

```
### SELF-REVIEW — Plan 063 Step 2

| # | Question | Answer |
|---|----------|--------|
| 1 | Every CONTRACT row verified with session evidence? | Yes — 5/5 mounts rg'd, tsc exit 0 |
| 2 | Human question before next step? | None |
| 3 | Unclear for next step? | Whether zh locales needed — 063 Open Issue #2 says optional |

**Deliver decision:** DELIVER SHIPPED
**Next packet (human):** 063 Step 3 — i18n + vitest
```

---

## What's NOT here (see canonical files)

| Topic | Canonical file |
|-------|---------------|
| Full VERIFY ingredient lists | [`loop-engineering.mdc`](..\timbuild\rules\loop-engineering.mdc) §§2–3 |
| Plan-author ground-check | [`plan-standards.mdc`](..\timbuild\rules\plan-standards.mdc) |
| Domain-specific examples | Project plan files under `{{PLANS_PATH}}/` |
| Stack locks (Scala, Flyway) | [`scala-stack.mdc`](..\timbuild\rules\scala-stack.mdc) + [`migration-registry.md`](..\timbuild\rules\migration-registry.md) |
