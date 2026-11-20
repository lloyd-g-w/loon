open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "avatar"

(*$ Pictures and initials
   Initials show while the picture loads, and if it fails. *)
let basic =
  Node.div
    ~attrs:[ Attr.class_ "docs-row" ]
    [ Avatar.view ~src:"https://github.com/lloyd-g-w.png" "Lloyd Williams"
    ; Avatar.view "Ada Lovelace"
    ; Avatar.view "Grace Hopper"
    ; Avatar.view ~src:"/does-not-exist.png" "Alan Turing"
    ; Avatar.view ~shape:Square "Edsger Dijkstra"
    ]
(*$*)

(*$ Sizes and status *)
let sizes =
  Node.div
    ~attrs:[ Attr.class_ "docs-row" ]
    (List.map Avatar.Size.all ~f:(fun size ->
       Avatar.view ~size ~status:`Online "Barbara Liskov"))
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
          ; "status", "[ `Online | `Busy | `Away | `Offline ]", "A dot in the corner."
          ; "name", "string", "The alt text, and where the initials and colour come from."
          ]
      ; Doc.p
          "Avatar.group overlaps avatars; past max, the rest are counted in a +N."
      ]
    [ Doc.static ~page "Pictures and initials" basic
    ; Doc.static ~page "Sizes and status" sizes
    ; Doc.static ~page "Group" group
    ]
;;
