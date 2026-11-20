open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "separator"

(*$ Horizontal and vertical *)
let basic =
  Node.div
    [ Node.div
        ~attrs:[ Attr.class_ "docs-stack"; Attr.create "style" "gap: 0.25rem" ]
        [ Node.strong [ Node.text "loon" ]
        ; Node.span
            ~attrs:[ Attr.create "style" "color: var(--loon-muted-foreground)" ]
            [ Node.text "Components for Bonsai, on OxCaml." ]
        ]
    ; Separator.view ~attrs:[ Attr.create "style" "margin: 1rem 0" ] ()
    ; Node.div
        ~attrs:[ Attr.class_ "docs-row"; Attr.create "style" "height: 1.25rem" ]
        [ Node.text "Blog"
        ; Separator.view ~orientation:Vertical ()
        ; Node.text "Docs"
        ; Separator.view ~orientation:Vertical ()
        ; Node.text "Source"
        ]
    ]
(*$*)

(*$ With a label *)
let labelled = Separator.view ~label:"or continue with" ()
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Separator"
    ~group:Display
    ~description:"A thin line between groups of content."
    ~usage:{|Separator.view ~label:"or" ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "orientation", "Separator.Orientation.t", "Horizontal (default) or Vertical."
          ; "label", "string", "Text in the middle of the line."
          ; "semantic", "bool", "role=\"separator\" rather than decorative (default false)."
          ]
      ]
    [ Doc.static ~page "Horizontal and vertical" basic
    ; Doc.static ~page "With a label" labelled
    ]
;;
