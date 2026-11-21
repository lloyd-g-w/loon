open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "skeleton"

(*$ Demo *)
let demo =
  Node.div
    ~attrs:[ Attr.class_ "flex items-center space-x-4" ]
    [ Skeleton.view ~class_:"h-12 w-12 rounded-full" []
    ; Node.div
        ~attrs:[ Attr.class_ "space-y-2" ]
        [ Skeleton.view ~class_:"h-4 w-[250px]" []
        ; Skeleton.view ~class_:"h-4 w-[200px]" []
        ]
    ]
(*$*)

(*$ Card *)
let card =
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col space-y-3" ]
    [ Skeleton.view ~class_:"h-[125px] w-[250px] rounded-xl" []
    ; Node.div
        ~attrs:[ Attr.class_ "space-y-2" ]
        [ Skeleton.view ~class_:"h-4 w-[250px]" []
        ; Skeleton.view ~class_:"h-4 w-[200px]" []
        ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Skeleton"
    ~group:Feedback
    ~description:"Use to show a placeholder while content is loading."
    ~usage:{|Skeleton.view ~class_:"h-[20px] w-[100px] rounded-full" []|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "class_"
            , "string"
            , "Its size and shape ([h-4 w-[250px]], [rounded-full]), merged last." )
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ]
    [ Doc.static ~page "Demo" demo; Doc.static ~page "Card" card ]
;;
