open! Core

let page =
  Doc.page
    ~order:1
    ~slug:"installation"
    ~title:"Installation"
    ~section:Get_started
    ~description:"Add loon to a Bonsai_web project and build its stylesheet."
    ~body:
      [ Doc.h2 "Requirements"
      ; Doc.p'
          [ Doc.text "loon targets Bonsai_web on OxCaml (the "
          ; Doc.code "v0.18~preview"
          ; Doc.text
              " Jane Street packages), compiled to JavaScript with \
               js_of_ocaml. The simplest way to get that toolchain is loon's \
               nix flake, which uses the same pinned OxCaml packages as prigh \
               and a binary cache."
          ]
      ; Doc.p'
          [ Doc.text
              "Use loon as a library (below), or copy its components into your \
               project with "
          ; Doc.link ~href:"#/cli" "the CLI"
          ; Doc.text " and make them your own."
          ]
      ; Doc.h2 "Start from the template"
      ; Doc.p
          "loon's flake has a template: a small app with loon, its dune rules \
           and a flake that builds it."
      ; Doc.pre
          ~lang:Shell
          "nix flake init -t github:lloyd-g-w/loon\n\
           nix develop   # OxCaml, dune, Bonsai, loon and Tailwind v4\n\
           dune build    # main.bc.js and main.css; serve them with index.html"
      ; Doc.h2 "Add loon to a project"
      ; Doc.p'
          [ Doc.text
              "With nix, take loon's package (the library with the OxCaml \
               toolchain and Bonsai, and the "
          ; Doc.code "loon"
          ; Doc.text " CLI) as a build input, with nixpkgs' "
          ; Doc.code "tailwindcss_4"
          ; Doc.text ":"
          ]
      ; Doc.pre
          ~lang:Plain
          "inputs.loon.url = \"github:lloyd-g-w/loon\";\n\n\
           # loon.packages.${system}.loon      the library and the loon CLI\n\
           # loon.devShells.${system}.default  loon's own development shell"
      ; Doc.p'
          [ Doc.text
              "With opam, in an OxCaml switch with the Jane Street preview \
               packages:"
          ]
      ; Doc.pre
          ~lang:Shell
          "opam pin add loon https://github.com/lloyd-g-w/loon.git"
      ; Doc.p'
          [ Doc.text "Then depend on "
          ; Doc.code "loon"
          ; Doc.text " in your dune file:"
          ]
      ; Doc.pre
          ~lang:Dune
          "(executable\n\
          \ (name main)\n\
          \ (modes js)\n\
          \ (preprocess\n\
          \  (pps ppx_jane js_of_ocaml-ppx bonsai.ppx_bonsai))\n\
          \ (libraries core bonsai bonsai_web virtual_dom loon))"
      ; Doc.h2 "Build the stylesheet"
      ; Doc.p'
          [ Doc.text
              "The components are styled by Tailwind v4 from their class \
               strings. loon installs its Tailwind input, "
          ; Doc.code "loon.input.css"
          ; Doc.text
              " (Tailwind, tw-animate-css, shadcn's theme and variants), \
               beside its sources, which its @source lines name. Import it and \
               add your own sources, and one stylesheet has loon's classes and \
               yours:"
          ]
      ; Doc.pre
          ~lang:Dune
          "(rule\n\
          \ (with-stdout-to main.input.css\n\
          \  (progn\n\
          \   (echo \"@import \\\"%{lib:loon:loon.input.css}\\\";\\n\")\n\
          \   (echo \"@source \\\"./*.ml\\\";\\n\"))))\n\n\
           (rule\n\
          \ (target main.css)\n\
          \ (deps main.input.css %{lib:loon:loon.input.css} (glob_files *.ml))\n\
          \ (action\n\
          \  (run tailwindcss --silent --input main.input.css --output \
           main.css)))"
      ; Doc.p'
          [ Doc.text
              "Link it from your page's head. Your own CSS (theme overrides, "
          ; Doc.code "@theme"
          ; Doc.text ") goes after the import, in "
          ; Doc.code "main.input.css"
          ; Doc.text "."
          ]
      ; Doc.pre ~lang:Plain "<link rel=\"stylesheet\" href=\"main.css\">"
      ; Doc.p'
          [ Doc.text
              "Using no Tailwind classes of your own? loon's stylesheet alone \
               is prebuilt: "
          ; Doc.code "share/loon/loon.css"
          ; Doc.text ", or "
          ; Doc.code "Loon.Stylesheet.install ()"
          ; Doc.text " when your app starts, which puts it in the page."
          ]
      ; Doc.h2 "Use a component"
      ; Doc.p'
          [ Doc.text "The stylesheet gives "
          ; Doc.code "<body>"
          ; Doc.text
              " the theme's background and text colours, as shadcn's does. "
          ; Doc.code "Loon.Theme.root"
          ; Doc.text " does the same for a subtree ("
          ; Doc.code "~mode:Dark"
          ; Doc.text " adds the class "
          ; Doc.code "dark"
          ; Doc.text "; see "
          ; Doc.link ~href:"#/theming" "Theming"
          ; Doc.text ")."
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
              [ Doc.text
                  "Skip the library and copy components into your project with "
              ; Doc.link ~href:"#/cli" "the loon CLI"
              ; Doc.text "."
              ]
          ]
      ]
    []
;;
