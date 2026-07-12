import { StartClient } from '@tanstack/react-start'
import { createRouter } from './router'
import { mount } from '@tanstack/react-start/browser'

const router = createRouter()

mount(() => <StartClient router={router} />)
