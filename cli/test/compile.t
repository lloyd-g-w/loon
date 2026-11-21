A project made with `loon init` and `loon add` builds with dune: the copies
need nothing from loon but the libraries the dune file names.

  $ cat > dune-project <<EOF
  > (lang dune 3.17)
  > EOF
  $ loon init > /dev/null
  $ loon add button tabs card badge > /dev/null
  $ cat > src/app.ml <<EOF
  > open! Core
  > module Vdom = Virtual_dom.Vdom
  > 
  > let view (local_ graph) =
  >   let tabs =
  >     Ui.Tabs.component ~default_value:"a" (Bonsai.return (fun t ->
  >       [ Ui.Tabs.list t [ Ui.Tabs.trigger ~value:"a" [ Vdom.Node.text "A" ] ]
  >       ; Ui.Tabs.content t ~value:"a" [ Vdom.Node.text "a" ]
  >       ])) graph
  >   in
  >   Bonsai.map tabs ~f:(fun tabs ->
  >     Ui.Theme.root
  >       [ Ui.Card.root
  >           [ Ui.Card.header [ Ui.Card.title [ Vdom.Node.text "Hello" ] ]
  >           ; Ui.Card.content [ Ui.Button.view [ Vdom.Node.text "Go" ]; tabs ]
  >           ]
  >       ])
  > ;;
  > EOF
  $ cat > src/dune <<EOF
  > (library (name app) (libraries core bonsai bonsai_web virtual_dom ui)
  >  (preprocess (pps ppx_jane bonsai.ppx_bonsai)))
  > EOF
  $ env -u INSIDE_DUNE -u DUNE_BUILD_DIR dune build --root . 2> build.log; echo "dune exited $?"
  dune exited 0
  $ grep -v 'missing-effects\|^Entering\|^Leaving' build.log
  [1]
  $ ls _build/default/src/app.cma _build/default/src/ui/ui.cma
  _build/default/src/app.cma
  _build/default/src/ui/ui.cma

The stylesheet is Tailwind's output, with shadcn's classes the components use.

  $ grep -o 'has-data-\\\[slot\\=card-action\\\]' _build/default/src/ui/ui.css | sort -u
  has-data-\[slot\=card-action\]
  $ grep -c -- '--tw-animation\|@keyframes enter' _build/default/src/ui/ui.css | sed 's/^[1-9][0-9]*$/some/'
  some

Every component builds this way, not only those: none may use something
`loon add` does not copy.

  $ loon add -all > /dev/null
  $ env -u INSIDE_DUNE -u DUNE_BUILD_DIR dune build --root . 2> build.log; echo "dune exited $?"
  dune exited 0
  $ grep -v 'missing-effects\|^Entering\|^Leaving' build.log
  [1]

Sonner's own stylesheet comes with it, after the theme.

  $ grep -c '^\[data-sonner-toaster\] {' _build/default/src/ui/ui.css
  1
  $ loon info sonner | grep uses
  uses: cn dom_util icon import theme
