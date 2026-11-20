open! Core

let page =
  Doc.page
    ~order:1
    ~slug:"installation"
    ~title:"Installation"
    ~group:Guide
    ~description:"Add loon to a Bonsai_web project and load its stylesheet."
    ~body:
      [ Doc.h2 "Requirements"
      ; Doc.p'
          [ Doc.text "loon targets Bonsai_web on OxCaml (the "
          ; Doc.code "v0.18~preview"
          ; Doc.text
              " Jane Street packages), compiled to JavaScript with js_of_ocaml. The \
               simplest way to get that toolchain is loon's nix flake, which uses the \
               same pinned OxCaml packages as prigh and a binary cache."
          ]
      ; Doc.h2 "With nix"
      ; Doc.p "Use loon's flake as an input and build in its development shell:"
      ; Doc.pre
          ~lang:Shell
          "nix develop github:lloyd-g-w/loon   # OxCaml, dune, Bonsai, node\n\
           dune build"
      ; Doc.p "Or add it to your own flake, and take its package or its dev shell:"
      ; Doc.pre
          ~lang:Plain
          "inputs.loon.url = \"github:lloyd-g-w/loon\";\n\n\
           # loon.packages.${system}.default   the library and the loon CLI\n\
           # loon.devShells.${system}.default  the toolchain"
      ; Doc.h2 "With opam"
      ; Doc.p'
          [ Doc.text "In an OxCaml switch with the Jane Street preview packages, pin loon:" ]
      ; Doc.pre ~lang:Shell "opam pin add loon https://github.com/lloyd-g-w/loon.git"
      ; Doc.h2 "Add the library"
      ; Doc.p'
          [ Doc.text "Depend on "; Doc.code "loon"; Doc.text " in your dune file:" ]
      ; Doc.pre
          ~lang:Dune
          "(executable\n\
          \ (name main)\n\
          \ (modes js)\n\
          \ (preprocess\n\
          \  (pps ppx_jane js_of_ocaml-ppx bonsai.ppx_bonsai))\n\
          \ (libraries core bonsai_web loon))"
      ; Doc.h2 "Load the stylesheet"
      ; Doc.p'
          [ Doc.text "The components' styles are one file, "
          ; Doc.code "loon.css"
          ; Doc.text ". Either let loon add it to the page when your app starts:"
          ]
      ; Doc.pre
          "let () =\n\
          \  Loon.Stylesheet.install ();\n\
          \  Bonsai_web.Start.start App.component"
      ; Doc.p'
          [ Doc.text "or serve it yourself: it is installed in "
          ; Doc.code "share/loon/loon.css"
          ; Doc.text " (and is "
          ; Doc.code "%{lib:loon:loon.css}"
          ; Doc.text " in dune) — link it from your page's head."
          ]
      ; Doc.pre ~lang:Plain "<link rel=\"stylesheet\" href=\"loon.css\">"
      ; Doc.h2 "Wrap your app"
      ; Doc.p'
          [ Doc.text "Components look for their theme on an ancestor. Wrap your app in "
          ; Doc.code "Loon.Theme.root"
          ; Doc.text " (or give its outermost element "
          ; Doc.code "class=\"loon\""
          ; Doc.text "):"
          ]
      ; Doc.pre
          "let component (local_ graph) =\n\
          \  let count, set_count = Bonsai.state 0 graph in\n\
          \  let%arr count and set_count in\n\
          \  Loon.Theme.root\n\
          \    [ Loon.Button.view\n\
          \        ~on_click:(set_count (count + 1))\n\
          \        [ Vdom.Node.textf \"Clicked %d times\" count ]\n\
          \    ]"
      ; Doc.note
          ~tone:"tip"
          ~title:"Prefer to own the code?"
          [ Doc.p'
              [ Doc.text "Skip the library and copy components into your project with "
              ; Doc.link ~href:"#/cli" "the loon CLI"
              ; Doc.text "."
              ]
          ]
      ]
    []
;;
