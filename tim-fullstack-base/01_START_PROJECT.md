# 01_START_PROJECT — Day-1 Bootstrap

> **What this is:** The AI reads this when dropped into a new, empty project directory.
> It orchestrates the copy of `starter-kit/` bones into the new repo, then walks
> through env setup, dependency install, database init, and verification.
> No feature code is written here — only the foundation.

---

## AI Agent Instructions

You are scaffolding a new project from `tim-fullstack-base`. Follow these steps in order.

### Phase 1 — Copy the Starter Kit

1. Locate the base kit at the path the human provides (or ask for it).
2. Copy the entire contents of `starter-kit/` into the new project root.
   - Preserve the `timbuild/rules/` directory structure — these `.mdc` files
     must land at the new project's `timbuild/rules/` so AI agents activate them.
   - Do **not** copy `node_modules/`, `.git/`, `dist/`, or any build artifacts.
3. Update `package.json`:
   - Set `"name"` to the new project folder name.
   - Update `"description"` to reflect the new project.
4. Scan every copied file for placeholder tokens like `{{PROJECT_NAME}}`,
   `{{DATABASE_NAME}}`, `{{APP_URL}}` and prompt the human for replacements.

### Phase 2 — Environment Setup

1. Check if `.env` exists. If not, create one from `.env.example` if present.
2. Print the **Human Checklist** below for the user to run.

### Phase 3 — Verify

1. Confirm the dev server starts (`npm run dev` / `pnpm dev`).
2. Report the outcome.

---

## Human Checklist

```bash
# 1. Environment variables
# Copy and fill in:
cp .env.example .env
# Edit .env with your secrets (DB URL, auth secret, Stripe keys, etc.)

# 2. Install dependencies
pnpm install

# 3. Database setup (Prisma)
npx prisma generate
npx prisma db push

# 4. Start dev server
pnpm dev
```

Confirm the dev server runs with no errors, then tell the AI to proceed to feature development.

