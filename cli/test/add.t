`loon add` copies a component and what it needs, the theme first.

  $ loon add button
  Adding button (and what it needs: import, theme, cn) in the Vega style
    wrote    src/ui/import.ml
    wrote    src/ui/theme.ml
    wrote    src/ui/theme.mli
    wrote    src/ui/cn.ml
    wrote    src/ui/cn.mli
    wrote    src/ui/button.ml
    wrote    src/ui/button.mli
    wrote    src/ui/loon.css (+theme)
  
  src/ui has no dune file: `loon init -dir src/ui` makes it a library.
  
  src/ui/loon.css is Tailwind's input: the dune file compiles it, with the classes the
  components use. Link the result from your page.

The copies are loon's files with the style's classes inlined (Vega, the
default: loon.json's "style", from `loon init -style`, or -style), and
loon.css has a section per component.

  $ grep '^/\* loon: ' src/ui/loon.css
  /* loon: theme */
  $ loon diff button
  button: the same as loon's.

Adding more keeps what is there (your changes are safe) and appends the new
styles.

  $ echo '(* mine *)' >> src/ui/button.ml
  $ sed -i 's/^\.loon-button {/.loon-button { --mine: 1;/' src/ui/loon.css
  $ loon add button tabs
  Adding button, tabs (and what it needs: import, theme, cn, dom_util) in the Vega style
    skipped  src/ui/button.ml (it exists; -overwrite replaces it)
    wrote    src/ui/dom_util.ml
    wrote    src/ui/dom_util.mli
    wrote    src/ui/tabs.ml
    wrote    src/ui/tabs.mli
    (6 files already as loon has them)
  
  src/ui has no dune file: `loon init -dir src/ui` makes it a library.
  
  src/ui/loon.css is Tailwind's input: the dune file compiles it, with the classes the
  components use. Link the result from your page.
  $ tail -1 src/ui/button.ml
  (* mine *)
  $ grep -c -- '--mine' src/ui/loon.css
  0
  [1]
  $ grep '^/\* loon: ' src/ui/loon.css
  /* loon: theme */

-overwrite puts loon's back.

  $ loon add -overwrite button | grep -v '^ *$'
  Adding button (and what it needs: import, theme, cn) in the Vega style
    replaced src/ui/button.ml
    (6 files already as loon has them)
  src/ui has no dune file: `loon init -dir src/ui` makes it a library.
  src/ui/loon.css is Tailwind's input: the dune file compiles it, with the classes the
  components use. Link the result from your page.
  $ grep -c -- '--mine' src/ui/loon.css
  0
  [1]
  $ loon diff
  button, cn, dom_util, import, tabs, theme: the same as loon's.

Unknown names are all reported, with the closest ones, and nothing is
written.

  $ loon add -dir elsewhere buton tabz zzzzzz
  loon: unknown component "buton": did you mean button?
  unknown component "tabz": did you mean tabs or table?
  unknown component "zzzzzz" (`loon list` shows them)
  [1]
  $ ls elsewhere
  ls: cannot access 'elsewhere': No such file or directory
  [2]

Names may be written as modules or files, with - for _.

  $ loon add -dry-run -dir elsewhere Dom-util tabs.ml | head -1
  Would add dom_util, tabs (and what it needs: import, theme, cn) in the Vega style
  $ ls elsewhere
  ls: cannot access 'elsewhere': No such file or directory
  [2]

With no names, add asks for some.

  $ loon add
  loon: which components? (`loon list` shows them)
  [1]

A block, as `npx shadcn add login-03`: the block's module and the
components it uses, side by side, so that it builds in the library
(compile.t builds every block).

  $ loon add -dir app/ui login-03 | grep -E '^Adding|login_03'
  Adding login_03 (and what it needs: import, theme, cn, button, card, dom_util, label, field, icon, control, input) in the Vega style
    wrote    app/ui/login_03.ml
    wrote    app/ui/login_03.mli

Its `open Loon` refers to the library's own modules: a local Loon names
those `open! Core` would hide (Core has a Field too); the others need no
open.

  $ head -9 app/ui/login_03.ml
  (* The library's own modules, for [open Loon] below: [open! Core] hides them. *)
  module Loon = struct
    module Field = Field
  end
  
  open! Core
  open Bonsai_web
  open Loon
  module Node = Vdom.Node
  $ loon add -dir app/ui calendar-01 > /dev/null
  $ grep -c '^open Loon' app/ui/calendar_01.ml
  0
  [1]
  $ loon diff -dir app/ui login-03
  login_03: the same as loon's.

`-all` adds every component, not the blocks.

  $ loon add -all -dry-run | head -1 | grep -c 'login_03'
  0
  [1]

In another style, the classes are that style's: shadcn's cn-* hooks are
replaced by them, merged under the component's own.

  $ loon add -dir other -style lyra badge | head -1
  Adding badge (and what it needs: import, theme, cn) in the Lyra style
  $ grep -A3 '^let base' other/badge.ml
  let base =
    "h-5 gap-1 rounded-none border border-transparent px-2 py-0.5 text-xs font-medium \
     transition-all has-data-[icon=inline-end]:pr-1.5 has-data-[icon=inline-start]:pl-1.5 \
     [&>svg]:size-3! group/badge inline-flex w-fit shrink-0 items-center justify-center \
  $ loon add -dir other -style nope badge
  loon: unknown style "nope" (the styles: vega, luma, lyra, maia, mira, nova, rhea, sera)
  [1]
