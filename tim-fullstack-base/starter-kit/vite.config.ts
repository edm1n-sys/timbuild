import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { tanstackStart } from '@tanstack/react-start/vite'

export default defineConfig({
  plugins: [
    tailwindcss(),
    react(),
    tanstackStart(),
  ],
})

