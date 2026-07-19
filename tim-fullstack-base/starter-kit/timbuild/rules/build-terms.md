# Build Terms — Compilation Bounds & Signature Constraints

> Layer 2 on-demand file. Read before writing or modifying server functions, validators, or calculation methods. Enforced during the verification pipeline.
>
> **GATE:** This file is STABLE REFERENCE. Update only when build domain changes (compilation bounds, signature parity rules, new precise build terms). Never append session notes, activity summaries, or per-session term dumps here. Session discoveries go to `AGENT_LEARNINGS.md`. Hardening/security state → `HARDENING-GATES.md`. Living state → `outstanding-tasks.md`.

---

## 1. Compilation Bounds & Signature Constraints

- **Parameter Count & Parity Enforcement:** All core server functions (`createServerFn`) and remote accounting calculation methods must enforce strict signature parity between their defined input validators (`zodSchema`) and their internal handler execution arguments.
- **The Parity Line Rule:** If the input schema specifies 4 parameters, the underlying execution frame must accept exactly 4 structured arguments. The agent must reject any code change that introduces floating, untyped parameters or loose `any` overrides during the build verification pass.

---

## 2. Precise Build Language

| Term | Definition | Example |
|------|-----------|---------|
| Route is wired | Action composition is present in the route definition | `authMiddleware(POST, handler)` |
| Route is bare | No composition — the handler is directly exported | `export const POST = handler` |
| Tenant-scoped | Query includes an `organizationId` filter | `prisma.customRecord.findMany({ where: { organizationId } })` |
| Stub | Returns 501 Not Implemented | Never fake 200 success with convincing IDs |
| Validated | Input passes through a Zod schema defined in `lib/validation.ts` | `use(validationSchema)` |
| Hardened | All rules in `02_HARDEN_PROJECT.md` pass | Verified via checklist |

## 3. Signature Parity Example

```ts
// DEFINITION — validator specifies 4 parameters
const createInvoiceSchema = z.object({
  organizationId: z.string().uuid(),
  amount: z.number().positive(),
  currency: z.string().length(3),
  evaluationDate: z.string().date(),
})

// CORRECT — handler destructures exactly 4 matching arguments
const createInvoiceFn = createServerFn({ method: 'POST' })
  .validator(createInvoiceSchema)
  .handler(async ({ data: { organizationId, amount, currency, evaluationDate } }) => {
    // ... implementation
  })

// WRONG — handler introduces loose or floating parameters
const createInvoiceFn = createServerFn({ method: 'POST' })
  .validator(createInvoiceSchema)
  .handler(async ({ data }: { data: any }) => { // ← loose any override — REJECT
    // ...
  })
```

## 4. Rules

1. Count the parameters in your Zod schema. The handler must destructure exactly that many.
2. Never use `any` to bypass the validator type in a server function handler.
3. `npm run typecheck` must pass after every server function change. Typecheck is a minimum gate — it does not replace per-step VERIFY evidence (see `loop-engineering.mdc` § Plan VERIFY Contract and `plan-standards.mdc` §3b).
4. If the verification pipeline fails on signature mismatch, self-correct up to 3x before escalating.
5. **Never append session notes here.** Session discoveries → `AGENT_LEARNINGS.md`. Hardening state → `HARDENING-GATES.md`.

---

## 5. CI Cost Policy

> **Goal:** Catch regressions without burning minutes on every commit. Split cheap mock tests (every PR) from expensive fullstack checks (nightly + manual).

### Policy

| Job | Trigger | Cost | Purpose |
|-----|---------|------|---------|
| **e2e-mock** | Every PR + push to main | Low (~3–5 min) | Mock API tests + `npm run test:e2e` — product regression |
| **e2e-fullstack** | Nightly cron + `workflow_dispatch` + optional push to main | High (~10–15 min) | Real database + server run + health check — deploy gate evidence |

### Path filters (skip CI on doc-only commits)

```yaml
# ci.yml — ignore docs and project-plan changes
paths-ignore:
  - 'timbuild/**'
  - 'docs/**'
  - '*.md'
  - '*.mdc'
```

**Safer alternative** — positive paths on expensive jobs only:

```yaml
paths:
  - 'app/**'
  - 'src/**'
  - 'test/**'
  - 'conf/**'
  - 'lib/**'
  - 'build.sbt'
  - 'package.json'
  - '.github/workflows/**'
```

### Human habits

| Habit | Effect |
|-------|--------|
| Draft PRs while iterating | CI can be skipped until "Ready for review" (repo setting) |
| Batch pushes | Fewer Actions runs — push once when green locally |
| `git push` only when `npm run verify` passes locally | You already have verify in `agent.md` — use it |

### Example YAML (`.github/workflows/e2e.yml`)

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 17 * * *'   # nightly
  workflow_dispatch:

jobs:
  e2e-mock:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci
      - run: npx playwright install chromium
      - run: npm run dev &
      - run: npx wait-on http://localhost:5173 --timeout 60000
      - run: npm run test:e2e -- --grep-invert fullstack-health

  e2e-fullstack:
    if: github.event_name == 'workflow_dispatch' || github.event_name == 'schedule' || (github.event_name == 'push' && github.ref == 'refs/heads/main')
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env: { POSTGRES_PASSWORD: postgres }
        ports: ['5432:5432']
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci
      - run: npx prisma db push
      - run: npm run dev &
      - run: npx wait-on http://localhost:5173 --timeout 60000
      - run: npm run test:e2e -- --grep fullstack-health
```

### Optional label gate (pre-merge fullstack)

```yaml
if: contains(github.event.pull_request.labels.*.name, 'fullstack-ci')
```

Adds a pull-request label trigger for the expensive job without enabling it on every push.
