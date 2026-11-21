# loon

[shadcn/ui](https://ui.shadcn.com), ported to
[Bonsai_web](https://github.com/janestreet/bonsai) on
[OxCaml](https://oxcaml.org): the same components — the same Tailwind
classes, DOM, data attributes and Radix behaviour — as OCaml modules. Use
them as a library, or copy them into your project with `loon add` and make
them your own, as with shadcn.

- **shadcn's look, exactly**: the new-york-v4 style, neutral theme, Lucide
  icons; styled by Tailwind v4 from the components' class strings.
- **Radix's behaviour**: roles, ARIA, keyboard and focus as Radix
  Primitives do them.
- **Plain OCaml**: each component one module with a documented `.mli`;
  composed like shadcn's parts (`Card.root`, `Card.header`, ...); stateful
  ones as a controlled `view` or a Bonsai `component`.

The port is in progress: Button, Badge, Card and Tabs are ported; the other
components still have loon's earlier styles.

The documentation site (`nix build .#docs`, or `dune build` then serve
`_build/default/docs/bin/site/` over http) shows every component live next
to its source.

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

Load the stylesheet — link `loon.css` (installed in `share/loon/`, built by
Tailwind from loon's sources), or let OCaml put it in the page:

```ocaml
open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon

let app (local_ graph) =
  let count, set_count = Bonsai.state 0 graph in
  let%arr count and set_count in
  Card.root
    ~class_:"w-full max-w-sm"
    [ Card.header
        [ Card.title [ Vdom.Node.text "Counter" ]
        ; Card.description [ Vdom.Node.textf "Pressed %d times." count ]
        ]
    ; Card.footer
        [ Button.view ~on_click:(set_count (count + 1)) [ Vdom.Node.text "Press" ] ]
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

Plus `Icon` (Lucide), `Cn` (shadcn's `cn`: class names, with a
tailwind-merge), `Theme` and `Stylesheet`, and the helpers the components
share (`Floating`, `Modal`, `List_nav`, `Roving`, `Fuzzy`, …).

## Theming

shadcn's theme: CSS variables (`--background`, `--primary`, `--radius`, ...)
on `:root`, and dark values under the class `dark` (on `<html>`, or
`Theme.root ~mode:Dark` for a subtree). Override them in a stylesheet after
`loon.css`, as you would shadcn's `globals.css`.

## Copying components: the CLI

```sh
nix run github:lloyd-g-w/loon -- init     # src/ui: a dune library `ui` with the theme
loon add button dialog                    # copies them and what they need
loon list                                 # what there is
loon info select                          # its files and what it needs
loon diff                                 # how your copies differ from loon's
```

`loon add` takes `-dir DIR` (default `src/ui`), `-overwrite`, `-dry-run`,
and `-all`. The project's `loon.css` (the theme) is Tailwind's input: the
dune file `loon init` writes compiles it with `tailwindcss`, scanning the
components for their classes. The copies are yours: write `Ui.Button.view`
where the docs write `Loon.Button.view`.

## Development

```sh
nix develop          # prigh's OxCaml toolchain (binary cache), tailwindcss, node
dune build @runtest  # expect tests (components, the docs app, the CLI)
./check              # build, dune tests, and the e2e in Chromium
./check --full       # the e2e in Chromium, Firefox and WebKit
```

The e2e (`e2e/run.sh`) drives the built docs site with Playwright: every
page, navigation, the theme toggle, the examples' tabs and copying, search,
and phones (no sideways scrolling, the sidebar sheet, 44px targets). It
diffs what it sees with `e2e/<engine>.expected`; `UPDATE=1` rewrites them
and `SHOTS=dir` keeps screenshots. Nix runs it too:
`nix build .#checks.x86_64-linux.e2e`.

See `AGENTS.md` for the conventions a component follows, and
`nix/README.md` for the toolchain.

## Licence

MIT. loon is derived from shadcn/ui (MIT), and includes tw-animate-css
(MIT) and Lucide's icons (ISC); the docs site bundles the Geist fonts (OFL)
and temporal-polyfill (MIT). See `THIRD_PARTY_NOTICES.md`.
