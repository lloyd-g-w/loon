open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "pagination"

(*$ Pages *)
let pages (local_ graph) =
  let pagination = Pagination.component ~default:4 ~pages:(Bonsai.return 12) graph in
  let%arr { Pagination.page; view } = pagination in
  Node.div
    ~attrs:[ Attr.class_ "docs-stack"; Attr.create "style" "align-items: center; width: 100%" ]
    [ view
    ; Node.span
        ~attrs:[ Attr.create "style" "color: var(--loon-muted-foreground); font-size: 0.875rem" ]
        [ Node.textf "Showing results %d–%d of 120" (((page - 1) * 10) + 1) (page * 10) ]
    ]
(*$*)

(*$ Compact *)
let compact (local_ graph) =
  let pagination = Pagination.component ~compact:true ~pages:(Bonsai.return 8) graph in
  let%arr { Pagination.view; _ } = pagination in
  view
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Pagination"
    ~group:Navigation
    ~description:"Moving through the pages of a long list."
    ~usage:{|Pagination.view ~page ~pages:12 ~on_change:set_page ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "page", "int", "The current page, from 1."
          ; "pages", "int", "How many there are."
          ; "on_change", "int -> unit Effect.t", "Go to a page."
          ; "siblings", "int", "Pages shown either side of the current one (default 1)."
          ; "compact", "bool", "\"Page 3 of 10\" in place of the numbers."
          ]
      ; Doc.p
          "[Pagination.component] keeps the page itself and returns it with the view."
      ]
    [ Doc.example ~page "Pages" pages; Doc.example ~page "Compact" compact ]
;;
