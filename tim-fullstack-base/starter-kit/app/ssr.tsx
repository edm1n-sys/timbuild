import { StartServer } from '@tanstack/react-start'
import { createRouter } from './router'

export function createServerRouter() {
  const router = createRouter()
  return <StartServer router={router} />
}
