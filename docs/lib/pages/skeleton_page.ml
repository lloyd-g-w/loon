open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "skeleton"

(*$ A card loading *)
let card =
  Node.div
    ~attrs:[ Attr.class_ "docs-row"; Attr.create "style" "align-items: flex-start; flex-wrap: nowrap" ]
    [ Skeleton.view ~shape:Circle ~width:"3rem" ~height:"3rem" ()
    ; Node.div
        ~attrs:[ Attr.class_ "docs-stack"; Attr.create "style" "flex: 1; max-width: 20rem" ]
        [ Skeleton.view ~shape:Text ~width:"45%" (); Skeleton.text ~lines:3 () ]
    ]
(*$*)

(*$ A picture and a paragraph *)
let media =
  Node.div
    ~attrs:[ Attr.class_ "docs-stack"; Attr.create "style" "max-width: 22rem" ]
    [ Skeleton.view ~height:"10rem" ()
    ; Skeleton.view ~shape:Text ~width:"70%" ()
    ; Skeleton.view ~shape:Text ~width:"40%" ()
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Skeleton"
    ~group:Feedback
    ~description:"A shimmering placeholder where content is loading."
    ~usage:{|Skeleton.view ~shape:Circle ~width:"3rem" ~height:"3rem" ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "shape", "Skeleton.Shape.t", "Rect (default), Circle or Text (a rounded line)."
          ; "width, height", "string", "CSS lengths."
          ; "Skeleton.text ~lines", "int", "Lines of text, the last shorter."
          ]
      ]
    [ Doc.static ~page "A card loading" card; Doc.static ~page "A picture and a paragraph" media ]
;;
