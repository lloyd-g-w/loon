#!/usr/bin/env bash
# Builds the reference app (shadcn's bases/radix components and
# examples/radix, falling back to new-york-v4's examples for those loon still
# ports from there, in Vite + React) in ${SHADCN_REF_DIR:-/tmp/shadcn-ref};
# see README.md. Needs node and npm, and shadcn's source in
# ${SHADCN_SRC:-~/src/shadcn-ui}.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
loon="$here/../.."
src="${SHADCN_SRC:-$HOME/src/shadcn-ui}/apps/v4"
dir="${SHADCN_REF_DIR:-/tmp/shadcn-ref}"
mkdir -p "$dir/src/hooks" "$dir/src/stubs" "$dir/public"
cd "$dir"
rm -rf src/registry src/ny
# bases/radix: src/registry (ui, blocks, hooks, lib), examples/radix in
# src/registry/examples.
cp -r "$src/registry/bases/radix" src/registry
rm -rf src/registry/examples && mkdir src/registry/examples
# The radix examples whose imports the app has (not the AI, RTL or Base UI
# ones).
ok_import='^(react|react-dom|lucide-react|@tabler/icons-react|sonner|date-fns|date-fns/.*|@tanstack/react-table|embla-carousel-autoplay|embla-carousel-react|input-otp|recharts|react-day-picker|radix-ui|zod|react-hook-form|@hookform/resolvers/zod|@/styles/radix-nova/ui/[a-z-]+|@/registry/bases/radix/.*)$'
for f in "$src"/examples/radix/*.tsx; do
	bad=0
	while read -r m; do
		if ! [[ $m =~ $ok_import ]]; then
			bad=1
			break
		fi
		case "$m" in
		@/styles/radix-nova/ui/*)
			u="${m#@/styles/radix-nova/ui/}"
			if [ ! -f "src/registry/ui/$u.tsx" ] ||
				grep -q '@base-ui/react\|@shadcn/react\|highlighter\|shadcn/schema\|shiki' "src/registry/ui/$u.tsx"; then
				bad=1
				break
			fi
			;;
		esac
	done < <(grep -hoE '(from|import|import\() "[^"]*"' "$f" | sed -E 's/.* "(.*)"/\1/')
	if [ $bad = 0 ]; then cp "$f" src/registry/examples/; fi
done
# new-york-v4: src/ny, its examples the fallback for #/<name>.
cp -r "$src/registry/new-york-v4" src/ny
rm -f src/ny/examples/{calendar-hijri,input-group-custom}.tsx src/ny/examples/form-*.tsx
cp "$src/hooks/use-media-query.tsx" "$src/hooks/use-copy-to-clipboard.ts" src/hooks/
cp "$loon"/docs/bin/geist-*.woff2 public/
cp -r "$here/ref/." .
cat >src/ny/lib/utils.ts <<'EOF'
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
EOF
{
	echo '@import "tailwindcss";'
	echo '@import "tw-animate-css";'
	echo '@custom-variant dark (&:is(.dark *));'
	echo '@source "./registry";'
	echo '@source "./ny";'
	echo '@source "./parity";'
	# loon's theme and its Vega style (on :root, as loon's docs), which
	# gives the bases' cn-* hooks their look.
	cat "$loon/src/css/02-shadcn.css" "$loon/src/css/03-theme.css" "$loon/src/css/styles/vega.css"
	cat <<'EOF'
@font-face { font-family: "Geist"; src: url("/geist-sans.woff2") format("woff2"); font-weight: 100 900; }
@font-face { font-family: "Geist Mono"; src: url("/geist-mono.woff2") format("woff2"); font-weight: 100 900; }
:root { --font-sans: "Geist", ui-sans-serif, system-ui, sans-serif; --font-mono: "Geist Mono", ui-monospace, monospace; }
body { font-family: var(--font-sans); }
EOF
} >src/index.css
if [ ! -d node_modules ]; then
	npm install --no-audit --no-fund react@19.2.3 react-dom@19.2.3 radix-ui@^1.4.3 cmdk vaul@1.1.2 \
		sonner@^2 react-day-picker@^9.7 embla-carousel-react@8.5.2 embla-carousel-autoplay@8.5.2 \
		react-resizable-panels@^4 recharts@3.8.0 lucide-react@0.474.0 input-otp date-fns \
		@tanstack/react-table@^9 next-themes zod react-hook-form @hookform/resolvers @tabler/icons-react \
		tailwindcss@^4 @tailwindcss/vite tw-animate-css class-variance-authority clsx tailwind-merge \
		vite @vitejs/plugin-react
fi
npx vite build
