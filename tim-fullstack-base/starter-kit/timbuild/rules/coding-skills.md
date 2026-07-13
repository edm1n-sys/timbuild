# Coding Skills — Numbered Standards

> **Purpose:** Numbered index of all coding rules. Other files reference skills by number (e.g. `coding-skills.md #10`).
> **Authority:** For execution protocol → [`loop-engineering.mdc`](loop-engineering.mdc). For plan authoring → [`plan-standards.mdc`](plan-standards.mdc). For per-session mandate → [`agent.md`](agent.md).
> **Phase 3b** = [`loop-engineering.mdc`](loop-engineering.mdc) (full execution protocol).

---

## Phase 1 — Safe Changes (skills 1–7)

| # | Skill | Rule | Violation |
|---|-------|------|-----------|
| 1 | **Ask before building** | When a task involves architectural decisions, ask the user before writing code | Building the wrong thing silently |
| 2 | **Read before editing** | Never edit a file you haven't read in this session | Stale state from conversation memory |
| 3 | **Verify after writing** | After creating a file, verify it exists (`Test-Path`). After editing JSON, validate (`ConvertFrom-Json`) | Broken files, invalid JSON |
| 4 | **Run tests after change batch** | `npx vitest run`, `npx tsc --noEmit`, `sbt test` after every change batch | Regressions found too late |
| 5 | **One tool per action** | Each edit is its own tool call. Don't chain 5 edits in one call | Unreviewable mega-diffs, partial failures |
| 6 | **Exact string match** | Edit tool uses literal strings, not regex. Provide enough context for uniqueness | Wrong or duplicate match |
| 7 | **No regex on TS/JSON** | Use Edit with exact strings. For bulk renames, use `replaceAll` | Regex edge cases corrupt code |

---

## Phase 2 — Verification & Loop (skills 8–10)

| # | Skill | Where to find the full rules |
|---|-------|------------------------------|
| 8 | **Loop until verified** | → [`loop-engineering.mdc`](loop-engineering.mdc) § The loop + § Definition of Done |
| 9 | **Docs follow code** | → [`execution-principles.mdc`](execution-principles.mdc) rule 8 |
| 10 | **Checkpoints** | → [`loop-engineering.mdc`](loop-engineering.mdc) § Checkpoint table |

**Full execution protocol:** [`loop-engineering.mdc`](loop-engineering.mdc) — READ → PROPOSE → TEST → VERIFY → REPEAT per step. Do not duplicate these rules here.

---

## Phase 3 — Session & Config (skills 11–15)

| # | Skill | Rule | Violation |
|---|-------|------|-----------|
| 11 | **Session handoff** | Read `outstanding-tasks.md` top entry before any edit. Append after task batch | Lost context between sessions |
| 12 | **Config in 4+ places → audit all** | When config lives in 4+ locations, sync all after any change | Split-brain config state |
| 13 | **Use `===` not `.contains()`** | Strict equality for identifiers, not substring matching | Wrong matches, false hits |
| 14 | **`structuredClone()` for deep copy** | Use `structuredClone()` not `JSON.parse(JSON.stringify())` or spread for deep object copies | Shared references, mutation bugs |
| 15 | **Required field on shared interface → find ALL sites** | When adding a required field to a shared interface, grep ALL construction sites | Incomplete implementations |

---

## Phase 4 — Drift & Encoding (skills 16–17)

| # | Skill | Rule | Violation |
|---|-------|------|-----------|
| 16 | **Pre-commit drift detection** | Compile: 0 errors. Typecheck: 0 errors. Tests: all pass. No cross-module imports without `shared/` path | Pipeline breaks on merge |
| 17 | **UTF-8 without BOM** | All `.scala`, `.ts`, `.tsx`, `.json` — never save with BOM. Use `[System.Text.UTF8Encoding]::new($false)` | Silent compiler rejection |

---

## Cross-references

| Skill # referenced from | File |
|--------------------------|------|
| #8, #10 | [`loop-engineering.mdc`](loop-engineering.mdc) (canonical source) |
| #9 | [`execution-principles.mdc`](execution-principles.mdc) rule 8 |
| #12–15 | [`AGENT_LEARNINGS.md`](AGENT_LEARNINGS.md) anti-patterns |
| #16–17 | [`encoding-standards.mdc`](encoding-standards.mdc), [`build-terms.md`](build-terms.md) |
| All | [`loop-engineering.mdc`](loop-engineering.mdc) § Plan VERIFY Contract → [`plan-standards.mdc`](plan-standards.mdc) §3b |
