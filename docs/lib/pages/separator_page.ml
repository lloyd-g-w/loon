open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "separator"

(*$ Demo *)
let demo =
  Node.div
    [ Node.div
        ~attrs:[ Attr.class_ "space-y-1" ]
        [ Node.h4
            ~attrs:[ Attr.class_ "text-sm leading-none font-medium" ]
            [ Node.text "Radix Primitives" ]
        ; Node.p
            ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ]
            [ Node.text "An open-source UI component library." ]
        ]
    ; Separator.view ~class_:"my-4" ()
    ; Node.div
        ~attrs:[ Attr.class_ "flex h-5 items-center space-x-4 text-sm" ]
        [ Node.div [ Node.text "Blog" ]
        ; Separator.view ~orientation:Vertical ()
        ; Node.div [ Node.text "Docs" ]
        ; Separator.view ~orientation:Vertical ()
        ; Node.div [ Node.text "Source" ]
        ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Separator"
    ~description:"Visually or semantically separates content."
    ~usage:{|Separator.view ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "orientation", "Separator.Orientation.t", "[Horizontal] (default) or [Vertical]."
          ; ( "decorative"
            , "bool"
            , "[true] (default): [role=\"none\"], hidden from screen readers; [false]: a \
               [role=\"separator\"]." )
          ; "class_", "string", "More Tailwind classes, merged last."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ]
    [ Doc.static ~page "Demo" demo ]
;;
