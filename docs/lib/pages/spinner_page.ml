open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "spinner"

(*$ Sizes *)
let sizes =
  Node.div
    ~attrs:[ Attr.class_ "docs-row" ]
    (List.map Spinner.Size.all ~f:(fun size -> Spinner.view ~size ()))
;;

(*$*)

(*$ In context
   The spinner takes the colour of the text around it. *)
let in_context =
  Node.div
    ~attrs:[ Attr.class_ "docs-row" ]
    [ Node.span
        ~attrs:
          [ Attr.create
              "style"
              "display: inline-flex; gap: 0.5rem; align-items: center; color: \
               var(--loon-muted-foreground); font-size: 0.875rem"
          ]
        [ Spinner.view ~size:Sm (); Node.text "Syncing 12 files…" ]
    ; Badge.view
        ~variant:Outline
        [ Spinner.view ~size:Sm ~label:"Deploying" (); Node.text "Deploying" ]
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Spinner"
    ~group:Feedback
    ~description:"A small spinning sign that something is loading."
    ~usage:{|Spinner.view ~label:"Saving" ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "size", "Spinner.Size.t", "Sm, Md (default) or Lg."
          ; "label", "string", "Read by screen readers (default \"Loading\")."
          ]
      ]
    [ Doc.static ~page "Sizes" sizes; Doc.static ~page "In context" in_context ]
;;
