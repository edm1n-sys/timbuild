# SPEC — {{Feature Name}}

> Generated: {{date}}  
> Phase 1 of spec-driven development (interview → plan → execute).

---

## Problem Statement

_What are we solving, and why now? What happens if we don't build this?_

---

## Requirements

### Functional

- [ ] 
- [ ]

### Non-Functional

- [ ] 
- [ ]

---

## Data Model Changes

_New models, fields, or relations. Include Prisma schema snippets._

### New / Modified Tables

```
model Example {
  id        String   @id @default(cuid())
  createdAt DateTime @default(now())
}
```

### Migration Risk

_Does this require a backfill? Is it additive or breaking?_

---

## API Surface

| Method | Route              | Auth     | Description        |
|--------|--------------------|----------|--------------------|
| GET    | /api/{{resource}}  | Optional | ...                |
| POST   | /api/{{resource}}  | Required | ...                |

---

## UI / UX

- [ ] Page / component sketches
- [ ] Loading states
- [ ] Error states
- [ ] Empty states
- [ ] Mobile responsiveness

---

## Edge Cases & Risks

- _What happens when the DB is unreachable?_
- _What happens on duplicate submission?_
- _What happens when rate limits are hit?_

---

## Open Questions

1. 
2. 
3. 

---

_Once this spec is approved, proceed to PLAN.md._

