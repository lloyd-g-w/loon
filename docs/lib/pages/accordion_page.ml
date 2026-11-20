open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "accordion"

let faq =
  [ Accordion.Item.create
      ~id:"what"
      ~title:"What is loon?"
      (Node.text
         "A set of components for Bonsai_web, styled with CSS variables, that you can use as a library or copy into your project.")
  ; Accordion.Item.create
      ~id:"accessible"
      ~title:"Is it accessible?"
      (Node.text
         "Yes. Components follow the WAI-ARIA patterns: roles, states and the keyboard.")
  ; Accordion.Item.create
      ~id:"animated"
      ~title:"Is it animated?"
      (Node.text
         "Yes, gently, and not at all if you have asked your system to reduce motion.")
  ]
;;

(*$ One at a time *)
let single (local_ graph) =
  Accordion.component ~default:[ "what" ] (Bonsai.return faq) graph
(*$*)

(*$ Several open *)
let multiple (local_ graph) = Accordion.component ~kind:Multiple (Bonsai.return faq) graph
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Accordion"
    ~group:Display
    ~description:"Headings that each reveal a section of content."
    ~usage:{|Accordion.component ~kind:Multiple (Bonsai.return items) graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "kind", "Accordion.Kind.t", "Single { collapsible } (the default: one open at a time) or Multiple."
          ; "default", "string list", "The ids open at first."
          ; "items", "Accordion.Item.t list", "Each with an id, a title and content."
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.p "Up and Down move between headings, Home and End to the first and last; Enter or Space opens and closes."
      ]
    [ Doc.example ~page "One at a time" single; Doc.example ~page "Several open" multiple ]
;;
