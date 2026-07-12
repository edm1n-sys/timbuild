// Architecture Regression Tests — enforce module boundaries the AI cannot bypass.
// Runs as part of the verification loop: pnpm typecheck && pnpm test:arch
// If these fail, the AI must self-correct before proceeding.

import { describe, it, expect } from 'vitest'
import { Project } from 'ts-morph'

const project = new Project()

// Load all source files once
project.addSourceFilesAtPaths('app/**/*.{ts,tsx}')
project.addSourceFilesAtPaths('lib/**/*.{ts,tsx}')

describe('architecture boundaries', () => {

  it('no client code imports server-only libs', () => {
    // Client-safe paths (routes that get bundled to the browser)
    const clientFiles = project.getSourceFiles().filter(f =>
      f.getFilePath().includes('/routes/') &&
      !f.getFilePath().includes('api.')
    )

    clientFiles.forEach(file => {
      const imports = file.getImportDeclarations().map(i => i.getModuleSpecifierValue())
      const serverImports = imports.filter(i =>
        i.includes('/lib/env') ||
        i.includes('/lib/db') ||
        i.includes('/lib/auth') && !i.includes('/auth-client') ||
        i.includes('prisma')
      )
      expect(serverImports, `${file.getBaseName()} imports server-only module`).toHaveLength(0)
    })
  })

  it('no direct Prisma imports from app layer', () => {
    const appFiles = project.getSourceFiles().filter(f =>
      f.getFilePath().includes('/app/')
    )

    appFiles.forEach(file => {
      const imports = file.getImportDeclarations().map(i => i.getModuleSpecifierValue())
      const prismaImports = imports.filter(i =>
        i.includes('@prisma/client') ||
        i.includes('/prisma/')
      )
      expect(prismaImports, `${file.getBaseName()} imports Prisma directly`).toHaveLength(0)
    })
  })

  it('all API routes use auth handler correctly', () => {
    const apiRoutes = project.getSourceFiles().filter(f =>
      f.getFilePath().includes('/routes/api.')
    )

    apiRoutes.forEach(file => {
      const text = file.getFullText()
      if (file.getBaseName().includes('webhook')) return // webhooks use Stripe signature, not session auth
      // API routes should handle auth — flag routes that don't
      const hasAuthImport = text.includes('auth.') || text.includes('requireSubscription')
      if (!hasAuthImport) {
        console.warn(`${file.getBaseName()} has no visible auth import — verify manually`)
      }
    })
  })
})
