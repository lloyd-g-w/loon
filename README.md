# loon

[shadcn/ui](https://ui.shadcn.com), ported to
[Bonsai_web](https://github.com/janestreet/bonsai) on
[OxCaml](https://oxcaml.org): the same components — the same Tailwind
classes, DOM, data attributes and Radix behaviour — as OCaml modules. Use
them as a library, or copy them into your project with `loon add` and make
them your own, as with shadcn.

Docs: <https://lloyd-g-w.github.io/loon/> (published from the `gh-pages`
branch by `tools/publish-docs.sh`)

- **shadcn's look, exactly**: every shadcn style (Vega, the default, Nova,
  Maia, Lyra, Mira, Luma, Sera, Rhea: `Theme.root ~style`, or `loon init
  --style` to inline one into copied components), neutral theme, Lucide
  icons; styled by Tailwind v4 from the components' class strings.
- **Radix's behaviour**: roles, ARIA, keyboard and focus as Radix
  Primitives do them.
- **Plain OCaml**: each component one module with a documented `.mli`;
  composed like shadcn's parts (`Card.root`, `Card.header`, ...); stateful
  ones as a controlled `view` or a Bonsai `component`.

The documentation site (`nix build .#docs`, or `dune build` then serve
`_build/default/docs/bin/site/` over http) shows every component live next
to its source, and ports ui.shadcn.com's other pages: Blocks (dashboard,
sidebars, login, signup and calendars: the `loon_blocks` library in
`blocks/`), Charts, Create and Typeset.

## Quick start

Two ways, as with shadcn: depend on the `loon` library, or copy the
components into your project with the `loon` CLI (below).

### As a library

Start from the template (Nix; a small app in `examples/app/`):

```sh
nix flake init -t github:lloyd-g-w/loon
nix develop          # OxCaml, dune, Bonsai, loon and Tailwind v4
dune build           # _build/default/main.bc.js and main.css; or: nix build
```

Or add it to a project: with Nix, `inputs.loon.url =
"github:lloyd-g-w/loon"` and `loon.packages.${system}.loon` among your
build inputs (it brings the OxCaml toolchain and Bonsai); with opam, `opam
pin add loon https://github.com/lloyd-g-w/loon.git` in an OxCaml switch.
Then, in dune:

```dune
(executable
 (name main)
 (modes js)
 (preprocess (pps ppx_jane js_of_ocaml-ppx bonsai.ppx_bonsai))
 (libraries core bonsai bonsai_web virtual_dom loon))

; One stylesheet for loon's classes and yours: loon's Tailwind input
; (installed with the library; its @source lines name the sources of loon
; and loon.blocks), then your sources.
(rule
 (with-stdout-to main.input.css
  (progn
   (echo "@import \"%{lib:loon:loon.input.css}\";\n")
   (echo "@source \"./*.ml\";\n"))))

(rule
 (target main.css)
 (deps main.input.css %{lib:loon:loon.input.css} (glob_files *.ml))
 (action (run tailwindcss --silent --optimize --input main.input.css --output main.css)))
```

and link `main.css` from your page (`--optimize` flattens the CSS nesting
loon's styles carry, which browsers match several times slower). (If you
use no Tailwind classes of your own, `share/loon/loon.css` is loon's alone,
prebuilt, and `Loon.Stylesheet.install ()` puts it in the page.)

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

let () = Bonsai_web.Start.start app
```

### Copying the components: the CLI

```sh
nix run github:lloyd-g-w/loon -- init     # src/ui: a dune library `ui` with the theme
loon add button dialog                    # copies them and what they need
loon add login-03                         # a block (a page), with its components
loon list                                 # what there is: components, then blocks
loon info select                          # its files and what it needs
loon diff                                 # how your copies differ from loon's
```

`loon add` takes `-dir DIR` (default `src/ui`), `-overwrite`, `-dry-run`,
and `-all`, and copies the modules a component uses (Sidebar brings Sheet,
Tooltip, Portal, Popper, …). A block (shadcn's pages: `dashboard-01`,
`sidebar-07`, `login-03`, …) is copied the same way, beside the components
it uses: `Ui.Login_03.view` is the page. The directory's `loon.css` is Tailwind v4's
input: Tailwind, tw-animate-css, shadcn's custom variants and theme
(`@theme inline`, `.dark`), and Sonner's stylesheet once you add `sonner`.
The dune file `loon init` writes compiles it to `ui.css` with `tailwindcss`
(v4, e.g. nixpkgs' `tailwindcss_4`), scanning the components' sources; for your
own sources' classes, add `@source` lines to `loon.css` (and the files to
the rule's `deps`); `cli/test/compile.t` builds such a project. The copies are yours: write
`Ui.Button.view` where the docs write `Loon.Button.view`.

## Components

Accordion, Alert, Alert dialog, Aspect ratio, Avatar, Badge, Breadcrumb,
Button, Button group, Calendar, Card, Carousel, Chart, Checkbox,
Collapsible, Combobox, Command, Context menu, Data table, Dialog, Drawer,
Dropdown menu, Empty, Field, Hover card, Input, Input group, Input OTP,
Item, Kbd, Label, Menubar, Native select, Navigation menu, Pagination,
Popover, Progress, Radio group, Resizable, Scroll area, Select, Separator,
Sheet, Sidebar, Skeleton, Slider, Sonner, Spinner, Switch, Table, Tabs,
Textarea, Toggle, Toggle group, Tooltip.

Plus `Icon` (Lucide), `Tabler` (Tabler Icons, for dashboard-01), `Cn` (shadcn's `cn`, with a tailwind-merge port),
`Theme`, `Stylesheet`, `Use_mobile`, and the Radix primitives the
components share (`Portal`, `Popper`, `Presence`, `Dismiss`, `Focus`,
`Menu`, `Modal`, `Slot`, `List_nav`, `Roving`, …).

## Theming

shadcn's theme: CSS variables (`--background`, `--primary`, `--radius`, ...)
on `:root`, and dark values under the class `dark` (on `<html>`, or
`Theme.root ~mode:Dark` for a subtree). Override them in a stylesheet after
`loon.css`, as you would shadcn's `globals.css`.

## Development

```sh
nix develop          # prigh's OxCaml toolchain (binary cache), tailwindcss, node
dune build @runtest  # expect tests (components, the docs app, the CLI, examples/)
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

MIT. loon is derived from shadcn/ui and Radix Primitives (MIT), and
includes tw-animate-css and Sonner's stylesheet (MIT), Lucide's icons
(ISC) and Tabler's icons (MIT); the docs site bundles fonts (Geist and others, OFL) and
temporal-polyfill (MIT). See `THIRD_PARTY_NOTICES.md`.
