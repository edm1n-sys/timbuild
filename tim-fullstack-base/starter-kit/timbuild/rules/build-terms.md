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
| Tenant-scoped | Query includes an `organizationId` filter | `prisma.taxRecord.findMany({ where: { organizationId } })` |
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
