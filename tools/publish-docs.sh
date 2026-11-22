#!/usr/bin/env bash
# Builds the docs site (nix build .#docs) and force-pushes it, as a single
# commit, to the gh-pages branch of origin, which GitHub Pages serves
# (Settings → Pages → Source: Deploy from a branch, gh-pages, / (root)).
#
#   tools/publish-docs.sh            # build and push
#   REMOTE=upstream tools/publish-docs.sh
set -euo pipefail

cd "$(dirname "$0")/.."
remote=${REMOTE:-origin}
url=$(git remote get-url "$remote")
rev=$(git rev-parse --short HEAD)
dirty=$(git diff --quiet HEAD -- || echo "-dirty")

out=$(nix build --accept-flake-config --no-link --print-out-paths .#docs)

site=$(mktemp -d)
trap 'rm -rf "$site"' EXIT
cp -rL "$out"/. "$site"
chmod -R u+w "$site"
rm -rf "$site/dune" "$site/main.bc.map"
touch "$site/.nojekyll"

git -C "$site" init -q -b gh-pages
git -C "$site" add -A
git -C "$site" \
  -c user.name="$(git config user.name)" -c user.email="$(git config user.email)" \
  commit -qm "docs: loon ${rev}${dirty}"
git -C "$site" push -qf "$url" gh-pages
echo "published docs for ${rev}${dirty} to ${remote}/gh-pages"
