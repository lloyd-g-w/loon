open! Core
open Bonsai_web
open Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let example_view (example : Doc.Example.t) (local_ graph) =
  let preview = example.view graph in
  let%arr preview in
  Node.section
    ~attrs:[ Attr.class_ "docs-example" ]
    [ Node.h3 [ Node.text example.title ]
    ; Node.div ~attrs:[ Attr.class_ "docs-preview" ] [ preview ]
    ; Node.pre ~attrs:[ Attr.class_ "docs-source" ] [ Node.text example.source ]
    ]
;;

let page_view (page : Doc.Page.t) (local_ graph) =
  let examples =
    List.map page.examples ~f:(fun e -> example_view e graph) |> Bonsai.all
  in
  let%arr examples in
  Node.article
    ~attrs:[ Attr.id page.slug; Attr.class_ "docs-page" ]
    ([ Node.h1 [ Node.text page.title ]; Doc.p page.description ] @ examples @ page.body)
;;

let component (local_ graph) =
  let pages = List.map Pages.all ~f:(fun p -> page_view p graph) |> Bonsai.all in
  let%arr pages in
  Loon.Theme.root [ Node.main ~attrs:[ Attr.class_ "docs-main" ] pages ]
;;
