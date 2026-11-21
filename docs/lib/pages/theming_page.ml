open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "theming"

(*$ Light and dark
   [Theme.root ~mode:Dark] adds the class [dark]: everything inside takes the
   dark values of the variables. *)
let modes =
  Node.div
    ~attrs:[ Attr.class_ "grid w-full gap-4 sm:grid-cols-2" ]
    (List.map Theme.Mode.all ~f:(fun mode ->
       Theme.root
         ~mode
         ~attrs:[ Attr.class_ "rounded-xl p-4" ]
         [ Card.root
             [ Card.header
                 [ Card.title
                     [ Node.text
                         (match mode with
                          | Light -> "Light"
                          | Dark -> "Dark")
                     ]
                 ; Card.description [ Node.text "The same components, the other theme." ]
                 ; Card.action [ Badge.view ~variant:Secondary [ Node.text "Badge" ] ]
                 ]
             ; Card.footer
                 ~class_:"gap-2"
                 [ Button.view [ Node.text "Button" ]
                 ; Button.view ~variant:Outline [ Node.text "Outline" ]
                 ]
             ]
         ]))
(*$*)

let variables =
  [ "background / foreground", "The page and its text."
  ; "card / card-foreground", "Cards."
  ; "popover / popover-foreground", "Popovers, menus, dialogs."
  ; "primary / primary-foreground", "Default buttons, strongest fills."
  ; "secondary / secondary-foreground", "Secondary buttons and badges."
  ; "muted / muted-foreground", "Quiet fills; secondary text."
  ; "accent / accent-foreground", "Hovers and highlighted items in menus and lists."
  ; "destructive", "Destructive actions and errors."
  ; "border", "Borders (the default border colour)."
  ; "input", "The borders of form controls."
  ; "ring", "Focus rings."
  ; "chart-1 … chart-5", "Chart colours."
  ; "sidebar, sidebar-foreground, sidebar-primary, …", "The sidebar's own palette."
  ; "radius", "The base radius: rounded-sm/md/lg/xl derive from it."
  ]
;;

let page =
  Doc.page
    ~order:2
    ~slug:page
    ~title:"Theming"
    ~section:Get_started
    ~description:"Using CSS variables and Tailwind's colour utilities, as shadcn/ui does."
    ~body:
      [ Doc.h2 "CSS variables"
      ; Doc.p
          "loon uses shadcn/ui's theme unchanged: semantic colours as CSS variables \
           on [:root], dark values under [.dark], mapped into Tailwind by [@theme \
           inline]. So [bg-primary text-primary-foreground] in a component is the \
           theme's primary colour, and a shadcn theme (from ui.shadcn.com/themes or \
           tweakcn) drops straight in: edit the variables in the [loon.css] that \
           [loon init] writes, or override them in a stylesheet loaded after loon's."
      ; Doc.pre
          ~lang:Css
          ":root {\n\
          \  --background: oklch(1 0 0);\n\
          \  --foreground: oklch(0.145 0 0);\n\
          \  --primary: oklch(0.205 0 0);\n\
          \  --primary-foreground: oklch(0.985 0 0);\n\
          \  /* ... */\n\
          \  --radius: 0.625rem;\n\
           }\n\n\
           .dark {\n\
          \  --background: oklch(0.145 0 0);\n\
          \  --foreground: oklch(0.985 0 0);\n\
          \  /* ... */\n\
           }"
      ; Doc.h2 "Variables"
      ; Doc.table
          [ "Variable"; "Used for" ]
          (List.map variables ~f:(fun (name, what) -> [ Doc.code name; Doc.text what ]))
      ; Doc.h2 "Dark mode"
      ; Doc.p
          "Dark mode is the class [dark] on an ancestor, usually [<html>]. \
           [Theme.root ~mode] puts it on a [div]; [Theme.Mode.preferred ()] reads \
           the system's preference."
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
      ; Doc.h2 "Adding colours"
      ; Doc.p
          "Declare a variable in both modes and map it in [@theme inline], in the \
           stylesheet Tailwind compiles (the CLI's [loon.css]):"
      ; Doc.pre
          ~lang:Css
          ":root {\n\
          \  --warning: oklch(0.84 0.16 84);\n\
          \  --warning-foreground: oklch(0.28 0.07 46);\n\
           }\n\n\
           .dark {\n\
          \  --warning: oklch(0.41 0.11 46);\n\
          \  --warning-foreground: oklch(0.99 0.02 95);\n\
           }\n\n\
           @theme inline {\n\
          \  --color-warning: var(--warning);\n\
          \  --color-warning-foreground: var(--warning-foreground);\n\
           }"
      ; Doc.p "Then [bg-warning text-warning-foreground] work in any [class_]."
      ]
    [ Doc.static ~page "Light and dark" modes ]
;;
