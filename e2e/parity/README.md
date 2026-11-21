# Parity checks against shadcn/ui

Scripts that perform the same interactions (keyboard, pointer, wheel, focus,
open/close, resize) on loon's docs example and on shadcn's own example of a
component, and print both results side by side: `same  <step>: ...` or
`DIFF  <step>:` with loon's and shadcn's values. They are for finding
divergences while porting, not part of `./check` (they need the reference
app, and some differences are expected: page layout, fonts' sub-pixels).

## The reference app

A Vite + React app rendering shadcn's new-york-v4 `ui/` components and
`examples/` (copied from `~/src/shadcn-ui/apps/v4/registry/new-york-v4`),
with loon's theme CSS (`src/css/02-shadcn.css`, `03-theme.css`) and the
Geist fonts. `#/<example>` shows `examples/<example>.tsx` (its default
export, or `?export=Name`) centred in the page, with a `<Toaster />`.

    ./e2e/parity/setup-ref.sh            # builds it in /tmp/shadcn-ref (once)
    cd /tmp/shadcn-ref && npx vite preview --host 127.0.0.1 --port 5199 --strictPort

## Running

With the docs built (`dune build`) and the reference served:

    source <(nix print-dev-env --accept-flake-config .)   # node
    export PLAYWRIGHT_MODULE=... PLAYWRIGHT_BROWSERS_PATH=...  # as ./check finds them
    node e2e/parity/select.mjs [chromium|firefox|webkit]
    SHOTS=/tmp/shots node e2e/parity/select.mjs   # also screenshots of each step, NN-step-{loon,ref}.png
    for f in e2e/parity/*.mjs; do [ "$(basename $f)" = lib.mjs ] || node $f; done

`LOON_DOCS` (default `_build/default/docs/bin/site`) and `SHADCN_REF`
(default `http://127.0.0.1:5199/`) choose what is compared. Chromium runs
with its scrollbars shown (headless hides them by default).

`lib.mjs`: `both()` opens a page for each; `b.open(slug, title, example)`
goes to loon's example titled `title` on page `slug` and to shadcn's
`example`, marking each preview `[data-parity-root]`; `compare(b, label, fn)`
evaluates `fn` in both pages and prints the two results; `each(b, fn)` runs
an action on both; `inRoot(page, selector)` finds an element in the example;
`shot(b, name)` saves screenshots.
