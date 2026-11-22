import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"
import tailwindcss from "@tailwindcss/vite"
import path from "node:path"

const r = (p: string) => path.resolve(import.meta.dirname, p)
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: [
      // bases/radix, and the examples' styled copies of it
      { find: /^@\/registry\/bases\/radix\/(.*)$/, replacement: r("src/registry/$1") },
      { find: /^@\/styles\/radix-[a-z]+\/(.*)$/, replacement: r("src/registry/$1") },
      { find: /^@\/app\/\(create\)\/components\/icon-placeholder$/, replacement: r("src/stubs/icon-placeholder.tsx") },
      { find: /^cn$/, replacement: r("src/ny/lib/utils.ts") },
      // new-york-v4
      { find: /^@\/registry\/new-york-v4\/(.*)$/, replacement: r("src/ny/$1") },
      { find: /^@\/lib\/utils$/, replacement: r("src/ny/lib/utils.ts") },
      { find: /^@\/components\/ui\/(.*)$/, replacement: r("src/ny/ui/$1") },
      { find: /^@\/hooks\/(.*)$/, replacement: r("src/hooks/$1") },
      { find: /^next\/link$/, replacement: r("src/stubs/next-link.tsx") },
      { find: /^next\/image$/, replacement: r("src/stubs/next-image.tsx") },
    ],
  },
  server: { hmr: false },
  build: { chunkSizeWarningLimit: 100000, sourcemap: false, minify: false },
})
