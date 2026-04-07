import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  define: {
    global: 'globalThis',
  },
  server: {
    host: true,
    port: 5173,
    strictPort: true,
    proxy: {
      // User service (8081)
      '/api/user': {
        target: 'http://localhost:8081',
        changeOrigin: true,
      },
      // Chat REST (8080)
      '/api/chat': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
      // WebSocket/SockJS (8080)
      '/ws': {
        target: 'http://localhost:8080',
        ws: true,
        changeOrigin: true,
      },
    },
  },
})
