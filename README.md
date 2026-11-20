# loon

Calm, well-made components for [Bonsai_web](https://github.com/janestreet/bonsai),
on [OxCaml](https://oxcaml.org). In the spirit of
[shadcn/ui](https://ui.shadcn.com): a small set of accessible components,
themed by CSS variables, that you can use as a library — or copy into your
project with `loon add` and make your own.

- **Accessible**: the WAI-ARIA pattern for each widget — roles, keyboard
  (arrows, Home/End, typeahead, Esc), focus kept in dialogs and returned
  after, visible focus rings.
- **Themeable**: a few dozen `--loon-*` variables; light and dark, five
  accents (teal, lake, moss, ember, iris), per subtree.
- **Phones first-class**: 44px touch targets, sheets and native pickers
  where they suit a phone better.
- **Plain OCaml**: a stateless `view` you control, or a Bonsai `component`
  that keeps its state; each one module with a documented `.mli`.

The documentation site (`nix build .#docs`, or `dune build` then open
`_build/default/docs/bin/site/index.html` over http) shows every component
live next to its source.

## Quick start

With Nix, add loon to your flake's inputs and its package to your build:

```nix
inputs.loon.url = "github:lloyd-g-w/loon";
```

Depend on it in dune:

```dune
(executable
 (name main)
 (modes js)
 (libraries bonsai_web loon))
```

Load the stylesheet — link `loon.css` (installed in `share/loon/`), or let
OCaml put it in the page — and wrap the app in a theme:

```ocaml
open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon

let app (local_ graph) =
  let count, set_count = Bonsai.state 0 graph in
  let%arr count and set_count in
  Theme.root
    ~mode:(Theme.Mode.preferred ())
    [ Card.view
        ~title:"Counter"
        ~description:(sprintf "Pressed %d times." count)
        ~footer:[ Button.view ~on_click:(set_count (count + 1)) [ Vdom.Node.text "Press" ] ]
        []
    ]
;;

let () =
  Stylesheet.install ();
  Bonsai_web.Start.start app
;;
```

## Components

| Group | Components |
|---|---|
| Forms | Button, Input, Textarea, Label, Field, Checkbox, Switch, Radio group, Native select, Select, Combobox, Slider, Toggle, Toggle group, Calendar |
| Overlays | Popover, Tooltip, Dropdown menu, Dialog, Alert dialog, Sheet, Command palette |
| Display | Card, Badge, Avatar, Table, Data table (sort, filter, select, paginate), Accordion, Collapsible, Separator, Kbd |
| Navigation | Tabs, Breadcrumb, Pagination |
| Feedback | Alert, Toast, Progress, Spinner, Skeleton, Empty |

Plus `Icon` (line icons sized and coloured by the text), `Theme` and
`Stylesheet`, and the helpers the components share (`Floating`, `Modal`,
`List_nav`, `Roving`, `Fuzzy`, …).

## Theming

Everything is a `--loon-*` variable (colours in oklch, radii, shadows,
fonts, durations), set by the theme's classes `.loon-light` and
`.loon-dark` and by `data-loon-accent`. `Theme.root ~mode ~accent` (or
`Theme.attrs`) themes a subtree, so a dark panel can sit in a light page.
Override any of them in a stylesheet after `loon.css`:

```css
.loon-light,
.loon-dark {
  --loon-radius: 0.375rem;
  --loon-font: "Inter", system-ui, sans-serif;
}
```

The docs' Theming page lists every variable.

## Copying components: the CLI

```sh
nix run github:lloyd-g-w/loon -- init     # src/ui: a dune library `ui` with the theme
loon add button dialog                    # copies them and what they need
loon list                                 # what there is
loon info select                          # its files and what it needs
loon diff                                 # how your copies differ from loon's
```

`loon add` takes `-dir DIR` (default `src/ui`), `-overwrite`, `-dry-run`,
`-all` and `-css-files` (one stylesheet per component rather than one
`loon.css`). The copies are yours: write `Ui.Button.view` where the docs
write `Loon.Button.view`.

## Development

```sh
nix develop          # prigh's OxCaml toolchain, from its binary cache
dune build @runtest  # expect tests (components, the docs app, the CLI)
./check              # build, dune tests, and the e2e in Chromium
./check --full       # the e2e in Chromium, Firefox and WebKit
```

The e2e (`e2e/run.sh`) drives the built docs site with Playwright: every
page, navigation, theme and accent, the examples' tabs and copying, search,
and phones (no sideways scrolling, the sidebar sheet, 44px targets). It
diffs what it sees with `e2e/<engine>.expected`; `UPDATE=1` rewrites them
and `SHOTS=dir` keeps screenshots. Nix runs it too:
`nix build .#checks.x86_64-linux.e2e`.

See `AGENTS.md` for the conventions a component follows, and
`nix/README.md` for the toolchain.

## Licence

MIT. The docs site bundles the Recursive fonts (SIL Open Font Licence,
`docs/bin/recursive-OFL.txt`) and temporal-polyfill (MIT).
