open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "avatar"

(* A picture, inline so that the example works offline. *)
let portrait =
  "data:image/svg+xml;utf8,"
  ^ String.concat
      [ "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 40 40'>"
      ; "<defs><linearGradient id='g' x1='0' y1='0' x2='1' y2='1'>"
      ; "<stop offset='0' stop-color='%2338bdf8'/><stop offset='1' \
         stop-color='%230f766e'/>"
      ; "</linearGradient></defs><rect width='40' height='40' \
         fill='url(%23g)'/>"
      ; "<circle cx='20' cy='16' r='7' fill='%23ecfeff'/>"
      ; "<path d='M6 40c2-9 8-13 14-13s12 4 14 13z' fill='%23ecfeff'/></svg>"
      ]
;;

(*$ Pictures and initials
   Initials show while the picture loads, and if it fails. *)
let basic =
  Node.div
    ~attrs:[ Attr.class_ "docs-row" ]
    [ Avatar.view ~src:portrait "Lloyd Williams"
    ; Avatar.view "Ada Lovelace"
    ; Avatar.view "Grace Hopper"
    ; Avatar.view "Alan Turing"
    ; Avatar.view ~shape:Square "Edsger Dijkstra"
    ]
;;

(*$*)

(*$ Sizes and status *)
let sizes =
  Node.div
    ~attrs:[ Attr.class_ "docs-row" ]
    (List.map Avatar.Size.all ~f:(fun size ->
       Avatar.view ~size ~status:`Online "Barbara Liskov"))
;;

(*$*)

(*$ Group *)
let group =
  Avatar.group
    ~max:4
    (List.map
       [ "Ada Lovelace"
       ; "Alan Turing"
       ; "Grace Hopper"
       ; "Edsger Dijkstra"
       ; "Barbara Liskov"
       ; "Donald Knuth"
       ; "Margaret Hamilton"
       ]
       ~f:(fun name -> Avatar.view name))
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Avatar"
    ~group:Display
    ~description:"A person's picture, or their initials."
    ~usage:{|Avatar.view ~src:user.picture user.name|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "src", "string", "The picture's URL."
          ; "size", "Avatar.Size.t", "Xs, Sm, Md (default), Lg or Xl."
          ; "shape", "Avatar.Shape.t", "Circle (default) or Square."
          ; ( "status"
            , "[ `Online | `Busy | `Away | `Offline ]"
            , "A dot in the corner." )
          ; ( "name"
            , "string"
            , "The alt text, and where the initials and colour come from." )
          ]
      ; Doc.p
          "Avatar.group overlaps avatars; past max, the rest are counted in a \
           +N."
      ]
    [ Doc.static ~page "Pictures and initials" basic
    ; Doc.static ~page "Sizes and status" sizes
    ; Doc.static ~page "Group" group
    ]
;;
