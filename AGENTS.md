loon is a direct port of [shadcn/ui](https://ui.shadcn.com) (new-york-v4
style, neutral base colour) to Bonsai_web on OxCaml: the same components,
with the same Tailwind classes, DOM, data attributes and behaviour, used as a
library (`loon`) or copied into a project with `loon add`. Breaking changes
are fine: match shadcn rather than keeping old loon APIs.

The reference checkouts (read-only): `~/src/shadcn-ui` (components in
`apps/v4/registry/new-york-v4/ui/*.tsx`, their examples in
`.../new-york-v4/examples/*.tsx`, blocks and charts beside them),
`~/src/lucide` (icons). Radix's behaviour: https://www.radix-ui.com/primitives/docs.

## Layout and builds

| Path | What |
|---|---|
| `src/` | the `loon` library: one module per component (`button.ml`/`.mli`) |
| `src/css/` | Tailwind's input, concatenated in name order: `00-tailwind.css` (`@import "tailwindcss"`), `01-tw-animate.css`, `02-shadcn.css` (shadcn's variants and keyframes), `03-theme.css` (shadcn's neutral theme, `@theme inline`, base layer); then `10-`/`11-` and `<component>.css`: the old hand-written styles of components **not yet ported** (delete a component's file when you port it) |
| `src/loon.css` (built) | `tailwindcss` over that input, scanning `src/*.ml` for class names; installed, and embedded as `Loon.Stylesheet.css` (`src/embedded/`) |
| `tools/` | `gen-icons.mjs` writes `src/icon.ml(i)` from Lucide (`tools/icons.txt`: the icons included) |
| `test/` | expect tests, run under node: `test_<component>.ml` |
| `docs/lib/` | the documentation site; `docs/lib/pages/<slug>_page.ml` is a page, found by `docs/gen` (no list to edit) |
| `docs/bin/` | the page and its assets; `docs/bin/site/` is the built site (its `loon.css` scans the docs' sources too, so examples may use any Tailwind class) |
| `cli/` | the `loon` command: `cli/gen` embeds `src/` into `cli/registry` (no list to edit); cram tests in `cli/test` |
| `e2e/` | Playwright scripts against the built site |
| `nix/` | the OxCaml pins and patches, shared with prigh |
| `THIRD_PARTY_NOTICES.md` | shadcn/ui, Radix, tw-animate-css, Lucide, Geist |

- Dev shell: `nix develop` (OxCaml, `tailwindcss` v4, node). In scripts,
  `nix print-dev-env --accept-flake-config . > /tmp/<you>-env.sh` once, then
  `source` it (use your own file name: parallel agents overwrite each other's).
- `dune build @runtest`, then `dune promote` when the diff is right.
  `./check` runs everything (dune tests and the browser e2e; `--full` for
  Firefox and WebKit too). One dune process at a time per checkout.
- Look at what you build: `node e2e/shot.mjs OUT.png [WxH] [light|dark]
  [#/slug]` (with `PLAYWRIGHT_MODULE`, `PLAYWRIGHT_BROWSERS_PATH`,
  `FONTCONFIG_FILE` set; see `./check`), and compare with ui.shadcn.com.

## Porting a component from shadcn

Read `ui/<name>.tsx` and the Radix primitive it wraps, then write
`src/<name>.ml`/`.mli`:

- **Class strings verbatim.** Copy every `className`/`cva` string exactly,
  as complete string literals in the `.ml`, so Tailwind's scanner sees them.
  Never build a class name from pieces (`"size-" ^ n`): Tailwind would not
  generate it. A `cva` becomes a function from variant types to literal
  strings (see `Button.classes`).
- **`Cn` is `cn`.** Join with `Cn.cn [ base; variant_classes; class_ ]` or
  `Cn.with_class ?class_ [ ... ]`: the caller's `class_` comes last and wins
  conflicts (a tailwind-merge port; extend `Cn` if a conflict it misses
  matters).
- **Same DOM and attributes.** The element shadcn renders (`<button>`,
  `<div>`), `data-slot="<slot>"` exactly as in the `.tsx`, and what the Radix
  primitive puts on the DOM: `data-state="open|closed|active|inactive|
  checked|unchecked"`, `data-orientation`, `data-disabled=""`,
  `data-variant`, `data-size`, `role`, `aria-*`, ids linking trigger and
  content (`aria-controls`, `aria-labelledby`). shadcn's selectors
  (`data-[state=open]:`, `group-data-[...]`, `has-data-[slot=...]`,
  `aria-invalid:`) then work unchanged.
- **Radix behaviour.** Keyboard (arrows, Home/End, typeahead, Enter/Space,
  Esc), focus (into the content on open, back to the trigger on close,
  trapped in modals), dismissing on outside click. Reuse the helpers already
  in `src/` (`Dom_util`, `Floating`, `Modal`, `List_nav`, `Roving`,
  `Fuzzy`, `Keep_in_view`), restyled or rewritten as needed. Animations come
  from shadcn's `data-[state=open]:animate-in` classes (tw-animate-css); an
  exit animation needs the element kept for its duration (or drop it).
- **API shaped like shadcn's composition.** One function per shadcn part,
  named after it without the prefix: `Card.root`/`header`/`title`/
  `description`/`action`/`content`/`footer`; `Tabs.view`/`list`/`trigger`/
  `content`. Every function takes `?attrs:Attr.t list` and `?class_:string`
  first, then the part's own props as labelled arguments
  (`?variant`/`?size`/`?disabled`, using variant types with
  `[@@deriving enumerate, sexp_of, compare, equal]` and a `name` giving
  shadcn's string), children last as `Node.t list`. `asChild` becomes a
  second function (`Button.link` for `<Button asChild><a>`) or a `classes`
  function the caller applies to any element.
- **State: controlled `view` and Bonsai `component`.** Stateful parts take
  the state and `on_change : _ -> unit Effect.t` (Radix's controlled props)
  in `view`; `component ~default_... (local_ graph)` keeps the state in
  Bonsai (Radix's uncontrolled). Parts that need the root's state get a
  context value from the root (see `Tabs.t`, passed to `list`/`trigger`/
  `content` by a function the root calls).
- **Icons are Lucide.** `Icon.view ?class_ Name` renders as lucide-react
  does (`class="lucide lucide-<name>"`, stroke 2); shadcn's
  `[&_svg:not([class*='size-'])]:size-4` sizes them. Need an icon not in
  `Icon.t`? Add its name to `tools/icons.txt` and run `node
  tools/gen-icons.mjs` (needs `~/src/lucide`).
- **Dark mode is the class `dark`** on an ancestor (`Theme.root ~mode:Dark`
  or `<html class="dark">`), as shadcn's `@custom-variant dark`.
- Delete the component's old `src/css/<name>.css` and any `loon-<name>`
  classes; update the components that used its old API.
- `loon add` copies a component plus the modules it names; the first
  sentence of the `.mli`'s leading doc comment is its description (use
  shadcn's description, then "Port of shadcn/ui's [Name]."). A component must
  build when copied alone (`cli/test/compile.t` builds every one): name
  other components by module (`Button`), never `Loon.`, and never a
  generated module. A component's styles are its Tailwind classes, so it
  carries no CSS.

Practical notes:

- A component starts with `open! Import` (Core, `Node`, `Attr`, `Effect`,
  `Bonsai`, and `data`/`aria` attribute helpers). Put the caller's `attrs`
  last in the list, after ours.
- Keys: `Dom_util.key ev` (a `Dom_html.Keyboard_code.t`, which works in
  tests); `Dom_util.prevent_default`, `Dom_util.focus_selector`.
- A long class string may be split across lines only at a space, with
  OCaml's `\` continuation (as in `button.ml`); never split a class.
- `src/css/10-loon-tokens.css` (the old `--loon-*` variables) stays until
  the last component is ported: unported components and the docs' own
  `docs/bin/docs.css` still use them.
- The e2e prints some docs content (sidebar groups, search results such as
  example titles, the Button page's first example). When a port changes it
  on purpose, rewrite the expectations with `UPDATE=1 ./check --full` (all
  three engines) and check the diff.

## Tests

`test/test_<name>.ml`: one test printing the full HTML with classes
(`Render.html`), the others without (`Render.html ~classes:false`, and
`Render.handle`, which leaves classes out by default) so they show
structure, ARIA and data attributes; drive every interaction through
`Bonsai_web_test.Handle` (clicks, keys, `Handle.input_text`). Check
`Cn` merges in `test_cn.ml` when you rely on a new conflict group.

## Docs pages

`docs/lib/pages/<slug>_page.ml` defines `page` (`Doc.page ~slug ~title
~group ~description ?usage ?body examples`; argument tables with
`Doc.props`). Port shadcn's own examples for the component
(`examples/<name>-demo.tsx` first, then the others), with their markup,
Tailwind classes and text. Each example is a top-level value between a line
`(*$ Title` (a comment, which may continue with a description) and a line
`(*$*)`; the generator copies that text as the example's source, so write it
as a user would. `Doc.static ~page "Title" node` or `Doc.example ~page
"Title" component`. Group: the sidebar section (as ui.shadcn.com's docs:
components are listed alphabetically).

## OCaml conventions

As in prigh: `type t` inside a module named for the type; `.mli` for every
module; Core's `Int.Map`-style modules; run `ocamlformat` (the dev shell's
upstream one cannot parse OxCaml syntax like `local_`: format such files by
hand in the same style). Only comment what is hard to see from the code.
