open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "breadcrumb"

(*$ Basic *)
let basic =
  Breadcrumb.view
    Breadcrumb.Item.
      [ create ~href:"#/" "Home"
      ; create ~href:"#/" "Components"
      ; create "Breadcrumb"
      ]
;;

(*$*)

(*$ Collapsed
   Past [max_items], the middle of the trail folds into an ellipsis. *)
let collapsed =
  Breadcrumb.view
    ~max_items:3
    Breadcrumb.Item.
      [ create ~href:"#/" "Home"
      ; create ~href:"#/" "Projects"
      ; create ~href:"#/" "loon"
      ; create ~href:"#/" "src"
      ; create "breadcrumb.ml"
      ]
;;

(*$*)

(*$ Custom separator *)
let slashes =
  Breadcrumb.view
    ~separator:(Node.text "/")
    Breadcrumb.Item.
      [ create ~href:"#/" "lloyd-g-w"; create ~href:"#/" "loon"; create "main" ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Breadcrumb"
    ~group:Navigation
    ~description:"Where a page sits in a hierarchy, with links back up."
    ~usage:
      {|Breadcrumb.view Breadcrumb.Item.[ create ~href:"/" "Home"; create "Settings" ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "items"
            , "Breadcrumb.Item.t list"
            , "Each with an href or an on_click effect; the last is the \
               current page." )
          ; "max_items", "int", "Collapse the middle past this many."
          ; "separator", "Vdom.Node.t", "Between items (default a chevron)."
          ]
      ]
    [ Doc.static ~page "Basic" basic
    ; Doc.static ~page "Collapsed" collapsed
    ; Doc.static ~page "Custom separator" slashes
    ]
;;
