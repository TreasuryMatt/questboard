import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import pkg from './package.json'

export default defineConfig({
  plugins: [react()],
  define: {
    __APP_VERSION__: JSON.stringify(pkg.version),
  },
  // Big Sur ships Safari 14 — keep the built bundle parseable there.
  build: {
    target: 'safari14',
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:5050',
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
})
