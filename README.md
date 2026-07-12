# timbuild — project bootstrap system

**Location:** `{{Timbuild_PATH}}\tim-fullstack-base\`

---

## How this kit works with AI (RAG model)

Each file is a self-contained prompt the AI consumes when pointed to it:

| File | How the AI uses it |
|---|---|
| `timbuild/rules/*.mdc` | Always active — auto-injected rules for AI agents. No manual reading needed. |
| `encoding-standards.mdc` (in rules/) | Enforces UTF-8 without BOM on all text files. Blocks encoding corruption. |
| `01_START_PROJECT.md` | Read once at project start. Full bootstrap workflow. |
| `02_HARDEN_PROJECT.md` | Read at pre-launch. AI audits your project against every item. |
| `templates/SPEC.md` | Read when specing a feature. AI interviews you using the template. |
| `templates/PLAN.md` | Read after spec is approved. AI produces implementation plan. |
| `templates/SESSION_HANDOFF.md` | Read at session end. AI fills this out before stopping. |
| `agent.md` | Read first every session. Routes to the right file for your scenario (bootstrap, feature, hardening, etc.). |
| `agent_terminology.md` | Extended glossary + flag & temporal semantic controls (Layer 2). |
| `agent_schema.md` | Relational definitions, tenant boundaries, model map (Layer 2). |
| `build-terms.md` | Compilation bounds, signature parity, precise build language (Layer 2). |
| `starter-kit/*.ts` | Copied into your project as source code. Not read as prompts. |

---

## What you get out of this kit

| Input | Output |
|---|---|
| `01_START_PROJECT.md` + empty folder | Running TanStack Start app with auth, DB, bg workers, shadcn, Tailwind v4 |
| `02_HARDEN_PROJECT.md` + existing project | Gap report + auto-fixes for every security category |
| `templates/SPEC.md` + feature idea | Written spec: requirements, data model, API surface, edge cases |
| `templates/PLAN.md` + approved spec | Implementation plan: files, order, verification steps |
| `execution-principles.mdc` | Autonomous loop: verify -> self-correct 3x -> log -> handoff |
| `AGENT_LEARNINGS.md` | Persistent memory of anti-patterns. Read before coding, append after mistakes. |
| `SESSION_HANDOFF.md` | Zero-context-loss between sessions. Filled out before stopping. |
| `__tests__/architecture.test.ts` | Blocks client code from importing server libs, Prisma from app layer |
| `lib/validation.ts` + zod | Structured 400 errors on every server function input |
| `lib/rate-limiter.ts` | Token-bucket rate limiting (strict/moderate/relaxed presets) |
| `lib/env.ts` imported at entry | Crashes on startup if DATABASE_URL or BETTER_AUTH_SECRET is missing |
| `lib/tenant.ts` + Prisma | Auto-scoped queries per org — no cross-org data leaks |
| `.gitignore` | Blocks `.next/`, `.tanstack/`, `postgres_data/`, `*.dump` from context |
| `scripts/backup.sh` | Daily pg_dump with 7-day rotation |
| `timbuild/rules/` into any project | AI stops inventing terms, follows loop, preserves working code |

---

## The verification pipeline

```
npm run verify
```

Chains in order:

1. **Biome check** (`npm run format`) — style, code smells, security vulnerabilities.
   Auto-fixes in milliseconds. Rust-native.

2. **Architecture test** (`npm run test:arch`) — enforces module boundaries:
   - Client routes cannot import server-only libs (db, env, prisma)
   - App layer cannot import @prisma/client directly
   - API routes must have auth or be explicitly exempted

3. **Prisma diff** (`npm run db:diff`) — exits non-zero if schema deviates
   from the database. Forces a migration or prisma db push.

4. **Typecheck** (`npm run typecheck`) — tsc --noEmit.

If any step fails, the AI self-corrects up to 3 times silently before escalating.

---

## Greenfield playbook — exact steps for a new project

### Step 1: Create the folder

```bash
mkdir %USERPROFILE%\Projects\my-new-saas
cd %USERPROFILE%\Projects\my-new-saas
# Open this empty folder in your AI agent
```

### Step 2: Fire the starter command

In AI agent chat, type:

> "Read {{Timbuild_PATH}}\tim-fullstack-base\01_START_PROJECT.md
> and bootstrap from {{Timbuild_PATH}}\tim-fullstack-base\starter-kit\"

The AI copies the skeleton, updates package.json name, and prints a checklist.

### Step 3: Boot the stack

```bash
docker compose -f {{Timbuild_PATH}}\tim-fullstack-base\docker-compose.yml up -d
npm install
npx prisma generate && npx prisma db push
npm run dev
```

### Step 4: Build features

The autonomous loop handles everything. You architect, the AI codes, verifies, self-corrects, and logs.

> "Build the login page with shadcn tabs for email/password and Google OAuth.
> Wire it to our auth server function and wrap the dashboard route with
> requireSubscription middleware."

The AI reads AGENT_LEARNINGS.md, writes code, runs npm run verify,
self-corrects up to 3x, logs to the activity log, and fills SESSION_HANDOFF.md
before stopping.

---

## Day 30 wrap-up — pre-launch hardening for a nearly-finished app

When features are complete and you are preparing for production traffic,
run this script in AI agent chat:

```
The app features are completely built. We are now entering Phase 2: Production Hardening.

1. Read 02_HARDEN_PROJECT.md and audit the entire repository.
2. Run a strict static analysis pass using Biome to catch any floating
   promises, missing dependencies, or unhandled errors.
3. Verify that all server functions are wrapped in authMiddleware and that
   no raw database secrets are exposed outside our secure env.ts wrapper.
4. Run our npm run verify loop until everything is perfectly green.

Do not write new features. Only apply security wrappers, production
environment validations, and responsive UI touchups. Give me a clean
status report when complete.
```

The AI will:

- Audit all 10 categories in 02_HARDEN_PROJECT.md
- Run Biome static analysis
- Verify auth middleware on every server function
- Check OAuth redirect URIs point to production, not localhost
- Inject CSP, X-Frame-Options, X-Content-Type-Options into the root HTML stream in __root.tsx
- Run the verify pipeline until green

### What you do manually

| Provider | Action |
|---|---|
| Google Cloud Console | Whitelist production callback URL, copy Client ID + Secret to hosting env vars |
| Apple Developer | Same — production callback URL and credentials |
| GitHub OAuth | Same |
| Stripe Dashboard | Switch from test keys to live keys, set webhook endpoint to production URL |
| Resend / SendGrid | Verify production domain for email sending |
| Database provider | Enable automated backups, point connection string to production endpoint |

---

## Pre-launch — app is built, needs audit + polish

```
Phase 1 — Full security audit (AI runs this)
  "Read 02_HARDEN_PROJECT.md. Audit this project against every item.
   Fix what you can safely fix. Escalate secrets rotation to me."

Phase 2 — Adopt guardrails from the kit
  No input validation      -> lib/validation.ts
  No rate limiting         -> lib/rate-limiter.ts
  Env vars not validated   -> lib/env.ts
  No kill switch           -> lib/kill-switch.ts
  No health endpoint       -> ask AI to create one
  No backup script         -> scripts/backup.sh

Phase 3 — Error handling sweep
  "Audit every server function. Does it have a try-catch?
   Does it return a structured error response?"

Phase 4 — Performance check
  "Find N+1 queries, missing indexes, unbound queries."

Phase 5 — UI polish pass
  "Check for: missing loading states, error states, empty states,
   mobile breakage at 320px wide."
```

---

## Mid-project adoption — existing project, no kit

```
Step 1 — Copy timbuild/rules/ into your project
  Zero code impact. AI instantly learns your terminology and execution loop.

Step 2 — Import individual guards
  lib/rate-limiter.ts     standalone
  lib/validation.ts       needs zod
  lib/env.ts              standalone
  lib/kill-switch.ts      standalone
  lib/tenant.ts           needs Prisma

Step 3 — Run hardening checklist
  "Read 02_HARDEN_PROJECT.md and audit this project."

Step 4 — Use templates for new features
  "Spec the payment flow. Use the template at templates/SPEC.md"
```

---

## Brownfield — bringing order to a legacy project

```
Step 1 — Terminology first
  Create project-terminology.mdc. AI stops inventing synonyms.

Step 2 — Add execution-principles.mdc
  Verify loop, self-correction, pre-commit drift detection.

Step 3 — Adopt one guard
  Start with lib/validation.ts. Tell AI: all server functions must use it.

Step 4 — Gap analysis
  "Read 02_HARDEN_PROJECT.md. Audit only. Do not change anything."

Step 5 — Template new features
  Even brownfield projects deserve a spec and a plan.
```

---

## The autonomous loop

```
[Human Request]
     |
     v
[Read AGENT_LEARNINGS.md]
     |
     v
[Plan Changes]
     |
     v
[Write Code]
     |
     v
[Verification — npm run verify]
    1. Biome check
    2. Architecture test
    3. Prisma diff
    4. Typecheck
     |
     +-- [FAIL] -- Self-correct (up to 3x) --> [Write Code]
     |
     v
[ALL GREEN]
     |
     v
[Log to activity log]
     |
     v
[Append to AGENT_LEARNINGS.md]
     |
     v
[Fill SESSION_HANDOFF.md]
     |
     v
[Done / Next task]
```

Human only enters when: AI fails 3x, secrets need rotating, or a new feature needs spec approval.

---

## UI design system

### Layout

| Rule | Detail |
|---|---|
| No cards inside cards | Full-width bands or constrained inner content. Cards for repeated items, modals, tools. |
| No gradient orbs | No decorative blobs as backgrounds. |
| No hero page for tools | Show usable interface first. Hero pages for branded sites only. |
| Text must fit container | Every viewport. Dynamic sizing if needed. |
| Stable dimensions | Fixed aspect ratios on icon buttons, counters, tiles. Hover states cannot shift layout. |

### Components

| Pattern | Guideline |
|---|---|
| Icons | lucide-react. Use icons where a symbol exists (save, B/I, arrows). |
| Tooltips | Every icon button needs one. |
| Controls | Segmented for modes, toggles for binary, sliders/inputs for numbers, menus for options, tabs for views. |
| Cards | Max 8px border radius. |

### Color and type

| Rule | Detail |
|---|---|
| No single-hue themes | Avoid one-hue UIs. Limit purple-blue, beige, dark slate, brown. |
| No viewport font scaling | Letter spacing 0. |
| Heading sizes | Hero-scale for branded sections only. Smaller inside dashboards, cards, tool surfaces. |

### App type

| Type | Style |
|---|---|
| SaaS, dashboard, tool | Quiet, utilitarian, dense. Prioritize scanning and repeated action. |
| Game, creative, portfolio | Expressive, animated, full-bleed media. |
| Branded landing page | Brand visible first-viewport. Real images or generated bitmaps. |

### Paste this when starting UI work

```
"Follow these UI rules: no cards inside cards, no gradient orbs, no hero page
 for tools. Use lucide-react icons with tooltips. SaaS layouts are utilitarian
 and dense. Stable dimensions on all interactive elements. Text must fit at
 all viewports. shadcn components with Tailwind v4 theme variables from global.css."
```

---

## Other files in this folder

| File | What it is |
|---|---|
| `how_to_use_scaffold.txt` | Original reference. 15 patterns, task routing A-E. Superseded by kit files. |
| `outstanding-tasksrules.txt` | Activity log pattern for session-to-session handoff. |

---

## What is in the kit

```
tim-fullstack-base/
├── docker-compose.yml              # PostgreSQL 16
├── 01_START_PROJECT.md             # AI launchpad
├── 02_HARDEN_PROJECT.md            # hardening checklist (10 categories)
├── templates/
│   ├── SPEC.md                     # feature spec
│   ├── PLAN.md                     # implementation plan
│   ├── roadmap.md                  # project tracking
│   └── SESSION_HANDOFF.md          # end-of-session handoff
├── starter-kit/
    ├── package.json                # pinned deps + verify script
    ├── .env.example                # matches Docker credentials
    ├── .gitignore                  # context token guardrails
    ├── __tests__/
    │   └── architecture.test.ts    # module boundary enforcement
    ├── lib/                        # 9 guardrail modules
    ├── app/                        # TanStack Start routes, router, CSS
    ├── prisma/schema.prisma        # Full multi-tenant schema
    ├── workers/pg-boss.ts          # background job client
    ├── scripts/backup.sh           # pg_dump + 7-day rotation
    └── timbuild/rules/
        ├── project-terminology.mdc
        ├── execution-principles.mdc    # autonomous loop
        encoding-standards.mdc     # UTF-8 without BOM encoding contract
        ├── AGENT_LEARNINGS.md          # anti-pattern ledger
        ├── preserve-features.mdc
        ├── memory.mdc
        └── agent.md                    # project overview
        agent_terminology.md        # extended glossary + flag semantics
        agent_schema.md             # relational definitions + tenant boundaries
        build-terms.md              # compilation bounds + signature parity
```

---

## Quick reference

| Goal | Action |
|---|---|
| Start a new session | `agent.md` — routes to the right file (bootstrap, feature, hardening, etc.) |
| Bootstrap new repo | `01_START_PROJECT.md` (AI reads it) |
| Session continuity (Day 2+) | `outstanding-tasks.md` → `AGENT_LEARNINGS.md` |
| Terminology changes | `agent_terminology.md` (after `project-terminology.mdc`) |
| Queries / migrations | `agent_schema.md` — tenant boundaries, model map |
| Server functions | `build-terms.md` — signature parity rules |
| Run verification pipeline | `npm run verify` |
| Pre-launch security audit | `02_HARDEN_PROJECT.md` (AI runs it) |
| Self-correction loop | Wired in `execution-principles.mdc` — 3x retry |
| End-session handoff | `templates/SESSION_HANDOFF.md` (AI fills it) |
| Error handling sweep | Prompt: "Audit all routes for unhandled errors" |
| Performance audit | Prompt: "Find N+1 queries and missing indexes" |
| UI polish pass | Prompt: paste UI rules block |
| Adopt rules into existing project | Copy `timbuild/rules/` folder |
| Import individual guard | Copy one file from `lib/` |
| Spec a feature | `templates/SPEC.md` |
| Plan implementation | `templates/PLAN.md` |
| Start the database | `docker compose up -d` |

**Docker:** container `tim-postgres-dev`, port 5432, user `postgres`, password `securepassword123`
