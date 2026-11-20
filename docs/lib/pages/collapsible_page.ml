open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "collapsible"

(*$ Starred repositories *)
let starred (local_ graph) =
  let repo name =
    Node.div
      ~attrs:
        [ Attr.create
            "style"
            "padding: 0.5rem 0.75rem; border: 1px solid var(--loon-border); border-radius: var(--loon-radius); font-family: var(--loon-font-mono); font-size: 0.8125rem; margin-top: 0.5rem"
        ]
      [ Node.text name ]
  in
  let list =
    Collapsible.component
      ~trigger:(Bonsai.return [ Node.text "@lloyd-g-w starred 3 more repositories" ])
      (Bonsai.return [ repo "janestreet/bonsai"; repo "oxcaml/oxcaml"; repo "ocsigen/js_of_ocaml" ])
      graph
  in
  let%arr list in
  Node.div
    ~attrs:[ Attr.create "style" "width: 100%; max-width: 24rem" ]
    [ repo "lloyd-g-w/loon"; Node.div ~attrs:[ Attr.create "style" "margin-top: 0.5rem" ] [ list ] ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Collapsible"
    ~group:Display
    ~description:"A section that shows or hides its content."
    ~usage:{|Collapsible.component ~trigger:(Bonsai.return [ Node.text "More" ]) content graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "trigger", "Vdom.Node.t list", "The button's content (a chevron follows)."
          ; "default_open", "bool", "Open at first."
          ; "disabled", "bool", "Can't be toggled."
          ]
      ; Doc.p "Closed content stays in the page (inert and hidden), so its state survives, and its height animates."
      ]
    [ Doc.example ~page "Starred repositories" starred ]
;;
