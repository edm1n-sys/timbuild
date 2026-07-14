# Two-Agent Workflow — One-Page Reference

> **Print this.** Keep it open. It replaces piecing together 5 files every session.

---

## The flow (one cycle = one plan step)

```
Step 1: Plan Author (P)           Step 2: Human              Step 3: Executor (X)
┌─────────────────────────┐      ┌──────────────────┐      ┌──────────────────────────┐
│ Paste: PLAN-AUTHOR-     │      │                  │      │ Paste: EXECUTOR-PROTOCOL  │
│   PROTOCOL.mdc          │      │ Copy VERIFY table │      │ Paste CONTRACT table from │
│ Write plan + VERIFY     │──┐   │  from plan into   │   ┌──│  handoff packet           │
│   tables                │  │   │  handoff packet   │   │  │ READ → PROPOSE → TEST    │
│ Run pre-state VERIFY    │  │   │ Pick one step ID  │   │  │ VERIFY → checkpoint      │
│ Stamp EXECUTABLE        │  │   └──────────────────┘   │  └──────────────────────────┘
└─────────────────────────┘  │              │            │              │
                             │              ▼            │              ▼
                             │    ┌──────────────────┐   │    ┌──────────────────┐
                             ├───►│ handoff-packet.md │◄──┘    │ Checkpoint SHIPPED│
                             │    │ (CONTRACT table)  │        │ Pasted to         │
                             │    └──────────────────┘        │ outstanding-tasks │
                             │                                └──────────────────┘
                             │                                         │
                             │    ┌──────────────────────────────────┐ │
                             └───►│ Human advances to next step      │◄┘
                                  │ Creates new handoff packet       │
                                  └──────────────────────────────────┘
```

---

## Cheat sheet (copy-paste commands)

| You want... | Open agent | Paste this prompt | Say |
|-------------|-----------|-------------------|-----|
| **New plan** or revise plan | Plan Author chat | `plan-author-protocol.mdc` | "Make plan NNN EXECUTABLE. Run pre-state VERIFY per step." |
| **Run one step** | Executor chat | `executor-protocol.mdc` | "Run plan NNN Step X.Y only. Here is the handoff packet:" |
| **Prove step done** | — | — | Paste executor's checkpoint into `outstanding-tasks.md` (link, not narrative) |

---

## Handoff packet (you fill this — paste into executor chat)

```markdown
## Executor packet — Plan NNN Step X.Y

**Plan file:** {{PLANS_PATH}}/NNN-name.md
**Step:** X.Y only (do not start next step)
**Prerequisite:** [N/A | prior step SHIPPED @ commit abc123]

**CONTRACT (paste before any edit):**

| # | Claim | Command / Read | Pass when |
|---|-------|----------------|-----------|
| 1 | [copy from plan step VERIFY table] | `[copy command]` | [copy pass-when] |
| 2 | [copy from plan step VERIFY table] | `[copy command]` | [copy pass-when] |

**Executor deliverable:** Single checkpoint message with annotated VERIFY table. Status SHIPPED or BLOCKED.
**Forbidden:** Next step, whole-phase summary, outstanding-tasks update without checkpoint.
```

---

## Human checklist (per step)

- [ ] Plan Author session complete: plan marked EXECUTABLE
- [ ] Handoff packet filled with CONTRACT table from plan
- [ ] Executor session launched with `executor-protocol.mdc` + handoff packet
- [ ] Executor returned checkpoint SHIPPED (all rows PASS)
- [ ] Checkpoint pasted into `outstanding-tasks.md`
- [ ] Create next handoff packet for next step

**You are the only one who advances step N → N+1.**
