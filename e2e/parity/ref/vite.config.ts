import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"
import tailwindcss from "@tailwindcss/vite"
import path from "node:path"

const r = (p: string) => path.resolve(import.meta.dirname, p)
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: [
      { find: /^@\/registry\/new-york-v4\/(.*)$/, replacement: r("src/registry/$1") },
      { find: /^cn$/, replacement: r("src/registry/lib/utils.ts") },
      { find: /^@\/lib\/utils$/, replacement: r("src/registry/lib/utils.ts") },
      { find: /^@\/components\/ui\/(.*)$/, replacement: r("src/registry/ui/$1") },
      { find: /^@\/hooks\/(.*)$/, replacement: r("src/hooks/$1") },
      { find: /^next\/link$/, replacement: r("src/stubs/next-link.tsx") },
      { find: /^next\/image$/, replacement: r("src/stubs/next-image.tsx") },
    ],
  },
  server: { hmr: false },
  build: { chunkSizeWarningLimit: 100000, sourcemap: false, minify: false },
})
