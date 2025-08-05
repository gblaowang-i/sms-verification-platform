import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 3000,
    open: true
  },
  build: {
    // 代码分割配置
    rollupOptions: {
      output: {
        manualChunks: {
          // 将Vue相关库分离
          'vue-vendor': ['vue'],
          // 将Element Plus分离
          'element-plus': ['element-plus', '@element-plus/icons-vue'],
          // 将axios分离
          'axios': ['axios']
        }
      }
    },
    // 调整块大小警告限制
    chunkSizeWarningLimit: 1000,
    // 启用源码映射（开发时有用）
    sourcemap: false,
    // 压缩配置
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true
      }
    }
  },
  // 优化依赖预构建
  optimizeDeps: {
    include: ['vue', 'element-plus', '@element-plus/icons-vue', 'axios']
  }
}) 