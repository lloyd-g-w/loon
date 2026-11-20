`loon add` copies a component and what it needs, the theme first.

  $ loon add button
  Adding button (and what it needs: import, theme, icon)
    wrote    src/ui/import.ml
    wrote    src/ui/theme.ml
    wrote    src/ui/theme.mli
    wrote    src/ui/icon.ml
    wrote    src/ui/icon.mli
    wrote    src/ui/button.ml
    wrote    src/ui/button.mli
    wrote    src/ui/loon.css (+theme, +button)
  
  src/ui has no dune file: `loon init -dir src/ui` makes it a library.
  
  Link src/ui/loon.css from your page (or embed it), and wrap the app in Theme.root.

The copies are loon's files, unchanged, and loon.css has a section per
component.

  $ grep '^/\* loon: ' src/ui/loon.css
  /* loon: theme */
  /* loon: button */
  $ loon diff button
  button: the same as loon's.

Adding more keeps what is there (your changes are safe) and appends the new
styles.

  $ echo '(* mine *)' >> src/ui/button.ml
  $ sed -i 's/^\.loon-button {/.loon-button { --mine: 1;/' src/ui/loon.css
  $ loon add button tabs
  Adding button, tabs (and what it needs: import, theme, icon, dom_util)
    skipped  src/ui/button.ml (it exists; -overwrite replaces it)
    wrote    src/ui/dom_util.ml
    wrote    src/ui/dom_util.mli
    wrote    src/ui/tabs.ml
    wrote    src/ui/tabs.mli
    (6 files already as loon has them)
    updated  src/ui/loon.css (+tabs)
    kept     src/ui/loon.css's button styles (they differ; -overwrite replaces them)
  
  src/ui has no dune file: `loon init -dir src/ui` makes it a library.
  
  Link src/ui/loon.css from your page (or embed it), and wrap the app in Theme.root.
  $ tail -1 src/ui/button.ml
  (* mine *)
  $ grep -c -- '--mine' src/ui/loon.css
  1
  $ grep '^/\* loon: ' src/ui/loon.css
  /* loon: theme */
  /* loon: button */
  /* loon: tabs */

-overwrite puts loon's back.

  $ loon add -overwrite button | grep -v '^ *$'
  Adding button (and what it needs: import, theme, icon)
    replaced src/ui/button.ml
    (6 files already as loon has them)
    updated  src/ui/loon.css (~button)
  src/ui has no dune file: `loon init -dir src/ui` makes it a library.
  Link src/ui/loon.css from your page (or embed it), and wrap the app in Theme.root.
  $ grep -c -- '--mine' src/ui/loon.css
  0
  [1]
  $ loon diff
  button, dom_util, icon, import, tabs, theme: the same as loon's.

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
  Would add dom_util, tabs (and what it needs: import, theme)
  $ ls elsewhere
  ls: cannot access 'elsewhere': No such file or directory
  [2]

-css-files writes one stylesheet per component instead.

  $ loon add -css-files -dir other badge | grep -v 'mli*$'
  Adding badge (and what it needs: import, theme)
    wrote    other/css/00-tokens.css
    wrote    other/css/01-base.css
    wrote    other/css/badge.css
  
  other has no dune file: `loon init -dir other` makes it a library.
  
  Link these stylesheets from your page, in this order:
    other/css/00-tokens.css
    other/css/01-base.css
    other/css/badge.css
  $ loon diff -dir other
  badge, import, theme: the same as loon's.

With no names, add asks for some.

  $ loon add
  loon: which components? (`loon list` shows them)
  [1]
