open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "separator"

(*$ Demo *)
let demo =
  Node.div
    ~attrs:[ Attr.class_ "flex max-w-sm flex-col gap-4 text-sm" ]
    [ Node.div
        ~attrs:[ Attr.class_ "flex flex-col gap-1.5" ]
        [ Node.div ~attrs:[ Attr.class_ "leading-none font-medium" ] [ Node.text "shadcn/ui" ]
        ; Node.div
            ~attrs:[ Attr.class_ "text-muted-foreground" ]
            [ Node.text "The Foundation for your Design System" ]
        ]
    ; Separator.view ()
    ; Node.div
        [ Node.text
            "A set of beautifully designed components that you can customize, extend, \
             and build on."
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
