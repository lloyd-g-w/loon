open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "kbd"

(*$ Keys and combinations *)
let keys =
  Node.div
    ~attrs:[ Attr.class_ "docs-stack" ]
    [ Node.div
        ~attrs:[ Attr.class_ "docs-row" ]
        [ Kbd.view "Esc"; Kbd.view "Tab"; Kbd.view "K" ]
    ; Node.div
        ~attrs:[ Attr.class_ "docs-row" ]
        [ Kbd.combo [ "Cmd"; "K" ]
        ; Kbd.combo [ "Ctrl"; "Shift"; "P" ]
        ; Kbd.combo ~symbols:false [ "Ctrl"; "Alt"; "Delete" ]
        ]
    ]
;;

(*$*)

(*$ In a sentence *)
let sentence =
  Node.p
    ~attrs:
      [ Attr.create
          "style"
          "color: var(--loon-muted-foreground); font-size: 0.875rem"
      ]
    [ Node.text "Press "
    ; Kbd.combo [ "Cmd"; "K" ]
    ; Node.text " to search, or "
    ; Kbd.view "?"
    ; Node.text " for every shortcut."
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Kbd"
    ~group:Display
    ~description:"Keyboard keys and shortcuts."
    ~usage:{|Kbd.combo [ "Cmd"; "K" ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "Kbd.view key", "string", "One key."
          ; "Kbd.combo keys", "string list", "Keys pressed together."
          ; ( "symbols"
            , "bool"
            , "Show Cmd, Shift, Alt, Ctrl, Enter… as ⌘ ⇧ ⌥ ⌃ ↵ (default true)."
            )
          ]
      ]
    [ Doc.static ~page "Keys and combinations" keys
    ; Doc.static ~page "In a sentence" sentence
    ]
;;
