# Project Activity Log

> **Living state.** Keep most recent at top. Read first before any edit.
> Append after every task batch. Update checkpoint after every plan step.
> **VERIFY contract:** See `loop-engineering.mdc` § Plan VERIFY Contract + `plan-standards.mdc` §3b.
> **Two-agent workflow:** Plan Author → `handoff-packet.md` → Executor → checkpoint back to this file. See `agent.md` § Two-agent workflow.
>
> **Handoff rule:** Never advance to step N+1 without a SHIPPED checkpoint for step N pasted here.

---

## Executor Packet — Current Step (human: fill before each executor session)

The executor reads this block first. CONTRACT table is right here — no hunting through plan files.

```markdown
**Plan:** {{PLANS_PATH}}/NNN-name.md
**Step:** X.Y only (do not start next step)
**Prerequisite:** [N/A | prior step SHIPPED @ commit abc123]

**CONTRACT (paste before any edit):**

| # | Claim | Command / Read | Pass when |
|---|-------|----------------|-----------|
| 1 | [from plan] | `[from plan]` | [from plan] |
| 2 | [from plan] | `[from plan]` | [from plan] |

**Executor deliverable:** Your final message must be the formatted checkpoint template (`loop-engineering.mdc` §4) with all rows PASS/FAIL annotated. Do not wait to be asked. Status SHIPPED or BLOCKED.
```

**Forbidden until this packet is cleared:**
- Starting next step
- `outstanding-tasks.md` ✅ without checkpoint paste

**Human router gate — accept SHIPPED only when:**
1. Every CONTRACT row PASS with cited evidence (exit code + test count / path:line)
2. No scope files touched outside packet
3. You spot-check 1–2 rows with `rg` (30 seconds)

**Reject and reply "PARTIAL — row X FAIL" when:**
- `0 tests` / missing file / broken link
- "programme complete" without index VERIFY table
- Bonus rows PASS while CONTRACT row FAIL

---

## Programme Close Packet (human: fill when all child steps SHIPPED)

The executor runs only this packet after all child steps of a parent index plan are SHIPPED.
Never fold this into a child step. "Programme complete" is only sayable after this table is all PASS.

```markdown
**Parent plan:** {{PLANS_PATH}}/NNN-index.md
**Prerequisite:** All child steps SHIPPED

**VERIFY (run all; no substitutes):**

| # | Claim | Command / Read | Pass when |
|---|-------|----------------|-----------|
| 1 | tsc clean | `npx tsc --noEmit --skipLibCheck` | exit 0 |
| 2 | TS tests | `npx vitest run <scoped>` | exit 0, N ≥ 1 tests |
| 3 | Scala tests | `sbt "testOnly <scoped>"` | exit 0, N ≥ 1 tests |
| 4 | Config valid | `powershell scripts/verify-config-roundtrip.ps1` | exit 0 |
| 5 | Truth table / artifact | `Glob <path>/KEY-FILE.md` | 1 file |
| 6 | Index doc row | `rg "Status:.*SHIPPED" <path>/index.md` | 1 match |

**Status:** SHIPPED (all PASS) | PARTIAL (list FAIL rows)
**Forbidden:** "programme complete" without this table; summary totals as sole proof.
```

---

## Checkpoint — Current Phase

| Step | READ | PROPOSE | TEST | VERIFY | Status |
|------|:----:|:-------:|:----:|:------:|:-------|
| —    | —    | —       | —    | —      | NOT STARTED |

**Forbidden until checkpoint is all SHIPPED:**
- "Phase complete"
- "All tests green" (without per-step evidence)
- "Ready for next phase"

---

## Activity Log

### [YYYY-MM-DD HH:MM] — Session Start

- **Task:** [One sentence summary]
- **Files Modified:**
  - `path/to/file.ext` (brief note)
- **Current State:** [Running / broken / needs testing]
- **Next Step / Handoff:** [Direct instruction for next agent]
- **Verify Commands Run:** `[plan VERIFY rows + exit codes — map 1:1 to plan table]`

---
