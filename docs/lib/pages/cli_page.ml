open! Core

let page =
  Doc.page
    ~order:3
    ~slug:"cli"
    ~title:"CLI"
    ~group:Guide
    ~description:
      "Copy components into your project, with what they depend on, and make them \
       your own."
    ~body:
      [ Doc.h2 "Why copy?"
      ; Doc.p
          "A library is easiest to start with, but components are where an app's look \
           and behaviour live. Copying a component's source gives you the same thing \
           loon ships, in your tree: change its markup, its styles, its API — nothing \
           to fork, nothing to wait for."
      ; Doc.h2 "Set up"
      ; Doc.p'
          [ Doc.code "loon init"
          ; Doc.text " creates a directory (by default "
          ; Doc.code "src/ui"
          ; Doc.text ") with a dune library, the theme's stylesheet and the small "
          ; Doc.code "Import"
          ; Doc.text " module the components share:"
          ]
      ; Doc.pre ~lang:Shell "nix run github:lloyd-g-w/loon -- init\n# or, installed: loon init"
      ; Doc.h2 "Add components"
      ; Doc.pre ~lang:Shell "loon add button tabs\nloon add dialog -dir lib/ui"
      ; Doc.p
          "Each component comes with the components and helpers it uses, and its CSS \
           is added to the directory's [loon.css]. Files you already have are left \
           alone unless you pass [-overwrite]; [-css-files] keeps one stylesheet per \
           component in [css/] instead."
      ; Doc.h2 "Commands"
      ; Doc.table
          [ "Command"; "What it does" ]
          [ [ Doc.code "loon list"; Doc.text "The components, with a line about each." ]
          ; [ Doc.code "loon init"; Doc.text "Creates the ui directory and its dune file." ]
          ; [ Doc.code "loon info NAME"
            ; Doc.text "What a component is, its files and what it needs."
            ]
          ; [ Doc.code "loon add NAME…"
            ; Bonsai_web.Vdom.Node.span
                (Doc.inline
                   "Copies components and their dependencies ([-all] for every \
                    one, [-dry-run] to see what it would do).")
            ]
          ; [ Doc.code "loon diff NAME"
            ; Doc.text "Shows how your copy differs from loon's."
            ]
          ; [ Doc.code "loon css"; Doc.text "Prints the whole stylesheet." ]
          ]
      ; Doc.h2 "Using copied components"
      ; Doc.p'
          [ Doc.text "The copies are a library called "
          ; Doc.code "ui"
          ; Doc.text ": depend on it and write "
          ; Doc.code "Ui.Button.view"
          ; Doc.text " where these docs write "
          ; Doc.code "Loon.Button.view"
          ; Doc.text "."
          ]
      ]
    []
;;
