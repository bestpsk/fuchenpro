import { defineConfig } from 'vite'
import uni from '@dcloudio/vite-plugin-uni'
import fs from 'fs'
import path from 'path'

// 自定义插件：直接返回 office-viewer 静态 HTML，跳过 Vite 的 HTML 转换
// 避免 Vite 注入 HMR client 等脚本导致 Vue 模板编译失败
function serveOfficeViewer() {
  return {
    name: 'serve-office-viewer',
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        if (req.url && req.url.startsWith('/static/office-viewer/')) {
          const filePath = path.resolve(process.cwd(), 'static', 'office-viewer', req.url.replace('/static/office-viewer/', '').split('?')[0])
          if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
            const ext = path.extname(filePath)
            const mimeMap = { '.html': 'text/html', '.js': 'application/javascript', '.css': 'text/css' }
            res.setHeader('Content-Type', mimeMap[ext] || 'application/octet-stream')
            res.end(fs.readFileSync(filePath))
            return
          }
        }
        next()
      })
    }
  }
}

export default defineConfig({
  base: './',
  plugins: [uni(), serveOfficeViewer()],
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
