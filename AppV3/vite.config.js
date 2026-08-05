import { defineConfig } from 'vite'
import uni from '@dcloudio/vite-plugin-uni'
import fs from 'fs'
import path from 'path'

// 递归复制目录（兼容旧版 Node，不依赖 fs.cpSync）
function copyDirRecursive(src, dest) {
  if (!fs.existsSync(src)) return
  fs.mkdirSync(dest, { recursive: true })
  for (const entry of fs.readdirSync(src)) {
    const srcPath = path.join(src, entry)
    const destPath = path.join(dest, entry)
    if (fs.statSync(srcPath).isDirectory()) {
      copyDirRecursive(srcPath, destPath)
    } else {
      fs.copyFileSync(srcPath, destPath)
    }
  }
}

// 自定义插件：
// 1. dev：直接返回 office-viewer 静态 HTML，跳过 Vite 的 HTML 转换
//    避免 Vite 注入 HMR client 等脚本导致 Vue 模板编译失败
// 2. build：将根目录 static/office-viewer/ 复制到 H5 构建产物
//    （根目录 static/ 不在 src/static/ 下，默认不会被构建复制，导致部署后 viewer.html 404 → 白屏）
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
    },
    // 构建产物写入完成后触发：补齐 office-viewer 静态资源
    writeBundle(options) {
      const outDir = options.dir
      if (!outDir) return
      // 仅对 H5 构建生效（mp-weixin 不走本地 viewer 路径，且需控制包体积）
      const normalizedDir = String(outDir).replace(/\\/g, '/')
      if (!/\/h5(\/|$)/.test(normalizedDir)) return

      const srcDir = path.resolve(process.cwd(), 'static', 'office-viewer')
      const destDir = path.resolve(outDir, 'static', 'office-viewer')
      if (!fs.existsSync(srcDir)) {
        console.warn('[serve-office-viewer] 源目录不存在，跳过复制:', srcDir)
        return
      }
      copyDirRecursive(srcDir, destDir)
      console.log('[serve-office-viewer] office-viewer 已复制到构建产物:', destDir)
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
