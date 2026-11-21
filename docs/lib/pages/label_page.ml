open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "label"

(*$ Demo *)
let demo (local_ graph) =
  let%arr terms = Checkbox.component ~id:"terms" graph in
  Node.div
    ~attrs:[ Attr.class_ "flex gap-2" ]
    [ terms.view; Label.view ~for_:"terms" [ Node.text "Accept terms and conditions" ] ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Label"
    ~group:Forms
    ~description:"Renders an accessible label associated with controls."
    ~usage:{|Label.view ~for_:"email" [ Node.text "Your email address" ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "for_", "string", "The id of the control it labels: a click on the label focuses or toggles it."
          ; "class_", "string", "More Tailwind classes, merged last (they win conflicts)."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ; Doc.p
          "In forms, use [Field.label] (the same label, in a [Field]): see the Field \
           page."
      ]
    [ Doc.example ~page "Demo" demo ]
;;
