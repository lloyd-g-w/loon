`loon init` makes a directory a dune library holding the theme.

  $ loon init -dir lib/ui -library my_ui
  Setting up lib/ui as the library my_ui
    wrote    lib/ui/dune
    wrote    lib/ui/import.ml
    wrote    lib/ui/theme.ml
    wrote    lib/ui/theme.mli
    wrote    lib/ui/loon.css (+theme)
  
  Now `loon add button` (`loon list` shows the components).
  
  lib/ui/loon.css is Tailwind's input: the dune file compiles it, with the classes the
  components use. Link the result from your page.
  $ cat lib/ui/dune
  ; Components copied from loon (https://github.com/lloyd-g-w/loon) with
  ; `loon add`: they are yours to change. `loon diff` shows how they differ
  ; from loon's.
  
  (library
   (name my_ui)
   (libraries core bonsai bonsai_web virtual_dom virtual_dom.svg js_of_ocaml)
   (preprocess
    (pps ppx_jane js_of_ocaml-ppx bonsai.ppx_bonsai)))
  
  ; The stylesheet: Tailwind v4 (`tailwindcss`, e.g. nixpkgs' tailwindcss_4)
  ; compiles loon.css, scanning these components' sources for the classes
  ; they use. Add @source lines to loon.css for your own sources' classes.
  
  (rule
   (targets my_ui.css my_ui.input.css)
   (deps
    loon.css
    (glob_files *.ml))
   (action
    (progn
     (with-stdout-to
      my_ui.input.css
      (progn
       (cat loon.css)
       (echo "\n@source \"./*.ml\";\n")))
     (run tailwindcss --silent --input my_ui.input.css --output my_ui.css))))

Running it again changes nothing, and keeps a dune file that is there.

  $ echo '; mine' >> lib/ui/dune
  $ loon init -dir lib/ui | head -6
  Setting up lib/ui
    kept     lib/ui/dune (it exists)
    (3 files already as loon has them)
  
  Now `loon add button` (`loon list` shows the components).
  
  $ tail -1 lib/ui/dune
  ; mine
