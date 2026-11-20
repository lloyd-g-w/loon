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
  >     Ui.Tabs.component
  >       (Bonsai.return
  >          [ Ui.Tabs.Tab.create ~id:"a" ~label:"A" (Vdom.Node.text "a") ])
  >       graph
  >   in
  >   Bonsai.map tabs ~f:(fun tabs ->
  >     Ui.Theme.root
  >       [ Ui.Card.view ~title:"Hello" [ Ui.Button.view [ Vdom.Node.text "Go" ]; tabs ] ])
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

Every component builds this way, not only those: none may use something
`loon add` does not copy.

  $ loon add -all > /dev/null
  $ env -u INSIDE_DUNE -u DUNE_BUILD_DIR dune build --root . 2> build.log; echo "dune exited $?"
  dune exited 0
  $ grep -v 'missing-effects\|^Entering\|^Leaving' build.log
  [1]
