# Handoff Packet — Reference Template

> **The active packet lives in `outstanding-tasks.md` top block (`## Executor Packet`), not here.** This file is the reference template. The executor reads `outstanding-tasks.md` as their first action — the CONTRACT table must be right there, not in a separate file.
>
> Copy this template into `outstanding-tasks.md` before each executor session.

---

## Plan Author: fill this block

```markdown
## Executor handoff — Plan NNN Step X.Y only

**Plan file:** {{PLANS_PATH}}/NNN-name.md
**Step:** X.Y only (do not start next step)
**Prerequisite checkpoints:** [list prior steps + commit hashes, e.g. "A.1 SHIPPED (abc123), A.2 SHIPPED (def456)"]

**CONTRACT (paste before any edit):**

| # | Claim | Command / Read | Pass when |
|---|-------|----------------|-----------|
| 1 | [from plan] | `[from plan]` | [from plan] |
| 2 | [from plan] | `[from plan]` | [from plan] |

**Executor deliverable:** Single checkpoint message with annotated VERIFY table. Status SHIPPED or BLOCKED.

**Forbidden:**
- Whole-phase summary without checkpoint
- `outstanding-tasks.md` ✅ without checkpoint paste
- Starting next step until human tells you
- Implementing without pasting the CONTRACT table first
```

---

## Executor: paste when starting the session

Your first action after reading `executor-protocol.mdc`:
1. Paste the CONTRACT table from this handoff packet into your response.
2. Confirm: "CONTRACT pasted. READ phase starting."
3. Begin loop per `loop-engineering.mdc` §1.

---

## Human: after executor session

Copy the executor's checkpoint into `outstanding-tasks.md`:

```markdown
## [YYYY-MM-DD HH:MM] — Plan NNN Step X.Y SHIPPED
- **Checkpoint:** [link to executor session transcript]
- **Next:** Plan NNN Step X.Z — handoff packet prepared above
```

Then create the next handoff packet for the next step. You are the only one who advances step N → N+1.
