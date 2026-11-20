loon is a component library for Bonsai_web on OxCaml, in the spirit of
shadcn/ui: well-made, accessible components themed by CSS variables, used as
a library (`loon`) or copied into a project with `loon add`.

## Layout and builds

| Directory | What |
|---|---|
| `src/` | the `loon` library: one module per component (`button.ml`/`.mli`), its styles in `src/css/<component>.css` |
| `src/css/` | concatenated in name order into `loon.css` (installed, and embedded as `Loon.Stylesheet.css`): `00-tokens.css` (theme variables), `01-base.css`, then the components' |
| `test/` | expect tests, run under node: `test_<component>.ml` |
| `docs/lib/` | the documentation site (`loon_docs`); `docs/lib/pages/<slug>_page.ml` is a component's page, found by `docs/gen` (no list to edit) |
| `docs/bin/` | `main.bc.js` and the page, assembled under `docs/bin/site/` |
| `cli/` | the `loon` command (`loon add`, ...) |
| `e2e/` | Playwright scripts against the built site |
| `nix/` | the OxCaml pins and patches, shared with prigh (see `nix/README.md`) |

- Dev shell: `nix develop` (prigh's OxCaml 5.2 toolchain, from its binary
  cache). In scripts, `nix print-dev-env > /tmp/loon-env.sh` once, then
  `source /tmp/loon-env.sh` is instant.
- Build and test: `dune build @runtest` then `dune promote` when the diff is
  right. `./test` runs everything (dune tests and the browser e2e).
- Only one dune process at a time per checkout.
- Look at what you build: `node e2e/shot.mjs OUT.png [WxH] [light|dark]
  [#/slug]` screenshots the built site (with `PLAYWRIGHT_MODULE`,
  `PLAYWRIGHT_BROWSERS_PATH` and `FONTCONFIG_FILE` set; see `./test`).

## Components

- One module per component, with an `.mli` documenting it. A component
  opens `Import` (`open! Import`) and refers to other components by their
  module name (`Button`, `Icon`), never through `Loon.`: `loon add` copies
  the files into a project unchanged.
- Stateless parts are plain functions returning `Vdom.Node.t`, taking
  `?attrs:Attr.t list` first (merged with ours via `Import.attrs`).
- Stateful components come in two forms: a controlled `view` (the state and
  an `on_change : _ -> unit Effect.t` passed in) and a `component` that keeps
  the state in Bonsai (`local_ Bonsai.graph -> ... Bonsai.t`). Test the
  `view` with `Render.html`, the `component` with `Bonsai_web_test.Handle`
  (clicks, keys).
- Variants and sizes are variant types with `[@@deriving enumerate]`, so
  docs and tests can show them all.
- Classes are `loon-<component>` and `loon-<component>-<part>`; state is in
  `data-state`, `aria-*` attributes. Every colour, radius, shadow and
  duration comes from a `--loon-*` variable in `00-tokens.css`; components
  must look right in `.loon-dark` and with every `data-loon-accent`.
- Accessibility: the WAI-ARIA pattern for the widget (roles, `aria-*`,
  keyboard: arrows, Home/End, Esc closes, Enter/Space activate), visible
  focus rings (`:focus-visible` with `--loon-ring`), 44px touch targets
  where it is a phone's primary control, `prefers-reduced-motion`.
- Keys: `Dom_util.key ev` (a `Dom_html.Keyboard_code.t`, which works in
  tests); `Dom_util.prevent_default`, `Dom_util.focus_selector`.

## Docs pages

Each component has `docs/lib/pages/<slug>_page.ml` defining `page`. Its
examples are top-level values between a line `(*$ Title` (a comment, which
may continue with a description) and a line `(*$*)`; the generator copies
that text as the example's source, so write examples as a user would.
`Doc.static ~page "Title" node` or `Doc.example ~page "Title" component`.

## OCaml conventions

As in prigh: `type t` inside a module named for the type; `.mli` for every
module; Core's `Int.Map`-style modules; run `ocamlformat` (the dev shell's
upstream one cannot parse OxCaml syntax like `local_`: format such files by
hand in the same style). Only comment what is hard to see from the code.

## Tests

Expect tests with readable output (HTML, or text), for every component and
every interaction. The e2e checks the site in Chromium, Firefox and WebKit,
on desktops and phones (390x844 and 320x640, touch), and that no page
overflows sideways or logs an error.
