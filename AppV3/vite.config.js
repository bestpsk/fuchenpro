import { defineConfig } from 'vite'
import uni from '@dcloudio/vite-plugin-uni'

export default defineConfig({
  plugins: [uni()],
  transpileDependencies: ['uview-plus'],
  esbuild: {
    drop: process.env.NODE_ENV === 'production' ? ['console', 'debugger'] : []
  },
  server: {
    port: 5174,
    host: '0.0.0.0',
    open: false,
    proxy: {
      '/prod-api': {
        target: 'http://localhost:8787',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/prod-api/, '')
      },
      '/profile': {
        target: 'http://localhost:8787',
        changeOrigin: true
      }
    }
  }
})
