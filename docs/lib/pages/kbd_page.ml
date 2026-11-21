open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "kbd"

(*$ Demo *)
let demo =
  let key k = Kbd.view [ Node.text k ] in
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col items-center gap-4" ]
    [ Kbd.group [ key "⌘"; key "⇧"; key "⌥"; key "⌃" ]
    ; Kbd.group [ key "Ctrl"; Node.span [ Node.text "+" ]; key "B" ]
    ]
(*$*)

(*$ Group
   [Kbd.group] keeps keys together in text. *)
let group =
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col items-center gap-4" ]
    [ Node.p
        ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ]
        [ Node.text "Use "
        ; Kbd.group
            [ Kbd.view [ Node.text "Ctrl + B" ]; Kbd.view [ Node.text "Ctrl + K" ] ]
        ; Node.text " to open the command palette"
        ]
    ]
(*$*)

(*$ Button *)
let button =
  Node.div
    ~attrs:[ Attr.class_ "flex flex-wrap items-center gap-4" ]
    [ Button.view
        ~variant:Outline
        ~size:Sm
        ~class_:"pr-2"
        [ Node.text "Accept "; Kbd.view [ Node.text "⏎" ] ]
    ; Button.view
        ~variant:Outline
        ~size:Sm
        ~class_:"pr-2"
        [ Node.text "Cancel "; Kbd.view [ Node.text "Esc" ] ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Kbd"
    ~description:"Used to display textual user input from keyboard."
    ~usage:
      {|Kbd.group [ Kbd.view [ Node.text "Ctrl" ]; Kbd.view [ Node.text "B" ] ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "class_", "string", "More Tailwind classes, merged last."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ]
    [ Doc.static ~page "Demo" demo
    ; Doc.static ~page "Group" group
    ; Doc.static ~page "Button" button
    ]
;;
