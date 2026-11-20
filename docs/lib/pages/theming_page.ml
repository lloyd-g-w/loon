open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "theming"

(*$ Accents
   Any element can set data-loon-accent; Theme.root takes ~accent. *)
let accents =
  Node.div
    ~attrs:[ Attr.class_ "docs-stack" ]
    (List.map Theme.Accent.all ~f:(fun accent ->
       Node.div
         ~attrs:
           [ Attr.class_ "docs-row"
           ; Attr.create "data-loon-accent" (Theme.Accent.name accent)
           ]
         [ Button.view ~variant:Accent [ Node.text (String.capitalize (Theme.Accent.name accent)) ]
         ; Badge.view ~variant:Accent [ Node.text "Badge" ]
         ; Button.view ~variant:Outline [ Node.text "Focus me" ]
         ]))
(*$*)

(*$ Light and dark
   Each subtree can choose: here, the same card in both modes. *)
let modes =
  Node.div
    ~attrs:[ Attr.class_ "docs-row" ]
    (List.map Theme.Mode.all ~f:(fun mode ->
       Theme.root
         ~mode
         ~attrs:[ Attr.class_ "docs-theme-sample" ]
         [ Card.view
             ~title:(match mode with Light -> "Light" | Dark -> "Dark")
             ~description:"The same variables, other values."
             ~footer:[ Button.view [ Node.text "Continue" ] ]
             [ Badge.view ~variant:Success ~dot:true [ Node.text "All systems normal" ] ]
         ]))
(*$*)

let variables =
  [ "--loon-background", "The page."
  ; "--loon-foreground", "Text on the page."
  ; "--loon-surface", "Cards and other raised surfaces."
  ; "--loon-overlay", "Popovers, menus and dialogs."
  ; "--loon-muted", "Quiet fills: hovers, inputs, segmented tabs."
  ; "--loon-muted-foreground", "Secondary text."
  ; "--loon-subtle", "A step stronger than muted."
  ; "--loon-border", "Dividers and outlines."
  ; "--loon-input", "The borders of form controls."
  ; "--loon-primary", "Primary buttons and the strongest fills."
  ; "--loon-primary-foreground", "Text on primary."
  ; "--loon-secondary", "Secondary buttons."
  ; "--loon-accent", "The accent: links, focus, switches, accent variants."
  ; "--loon-accent-foreground", "Text on the accent."
  ; "--loon-accent-soft", "A pale accent for selected rows and badges."
  ; "--loon-danger", "Destructive actions and errors (and -foreground, -soft)."
  ; "--loon-success", "Success (and -soft)."
  ; "--loon-warning", "Warnings (and -soft)."
  ; "--loon-ring", "Focus rings."
  ; "--loon-scrim", "Behind modal dialogs and sheets."
  ; "--loon-shadow-sm", "Small shadows (and --loon-shadow, --loon-shadow-lg)."
  ; "--loon-radius", "The base corner radius (-sm and -lg derive from it)."
  ; "--loon-font", "The interface font (and --loon-font-mono)."
  ; "--loon-ease", "The easing of transitions."
  ; "--loon-duration", "The length of transitions."
  ]
;;

let page =
  Doc.page
    ~order:2
    ~slug:page
    ~title:"Theming"
    ~group:Guide
    ~description:
      "loon's look is a few dozen CSS variables: change them to make it yours."
    ~body:
      [ Doc.h2 "Dark mode"
      ; Doc.p'
          [ Doc.text "A subtree is light or dark by its class: "
          ; Doc.code "loon-light"
          ; Doc.text " or "
          ; Doc.code "loon-dark"
          ; Doc.text ". "
          ; Doc.code "Loon.Theme.root ~mode"
          ; Doc.text " sets it, and "
          ; Doc.code "Theme.Mode.preferred ()"
          ; Doc.text " reads the system's preference:"
          ]
      ; Doc.pre
          "let component (local_ graph) =\n\
          \  let mode, set_mode = Bonsai.state (Loon.Theme.Mode.preferred ()) graph in\n\
          \  let%arr mode and set_mode in\n\
          \  Loon.Theme.root ~mode\n\
          \    [ Loon.Button.view\n\
          \        ~variant:Ghost\n\
          \        ~on_click:(set_mode (Loon.Theme.Mode.toggle mode))\n\
          \        [ Vdom.Node.text \"Toggle theme\" ]\n\
          \    ]"
      ; Doc.h2 "Accents"
      ; Doc.p'
          [ Doc.text "Five accents ship with loon — teal, lake, moss, ember and iris — \
                      chosen with "
          ; Doc.code "~accent"
          ; Doc.text " or "
          ; Doc.code "data-loon-accent"
          ; Doc.text ". Each has light and dark values."
          ]
      ; Doc.h2 "Variables"
      ; Doc.table
          [ "Variable"; "Used for" ]
          (List.map variables ~f:(fun (name, what) -> [ Doc.code name; Doc.text what ]))
      ; Doc.h2 "Overriding"
      ; Doc.p
          "Set variables in a stylesheet after loon.css: on the theme's classes \
           (.loon-light, .loon-dark) for the whole app, or on any element for its \
           subtree. Colours are written in oklch, which keeps lightness even \
           across hues; any CSS colour works."
      ; Doc.pre
          ~lang:Css
          ".loon-light,\n\
           .loon-dark {\n\
          \  --loon-radius: 0.375rem;\n\
          \  --loon-font: \"Inter\", system-ui, sans-serif;\n\
          }\n\n\
           /* a brand accent, in both modes */\n\
           .loon[data-loon-accent=\"brand\"] {\n\
          \  --loon-accent: oklch(0.6 0.2 340);\n\
          \  --loon-accent-soft: oklch(0.95 0.04 340);\n\
          \  --loon-ring: oklch(0.6 0.2 340 / 0.5);\n\
          }\n\
           .loon-dark[data-loon-accent=\"brand\"] {\n\
          \  --loon-accent: oklch(0.75 0.15 340);\n\
          \  --loon-accent-soft: oklch(0.3 0.07 340);\n\
          }"
      ; Doc.note
          ~title:"Motion"
          [ Doc.p
              "Animations are short and follow --loon-duration; with \
               prefers-reduced-motion they are all but switched off."
          ]
      ]
    [ Doc.static ~page "Accents" accents; Doc.static ~page "Light and dark" modes ]
;;
