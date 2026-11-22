open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "aspect_ratio"

(*$ Demo *)
let demo =
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-sm" ]
    [ Aspect_ratio.view
        ~ratio:(16. /. 9.)
        ~class_:"rounded-lg bg-muted"
        [ Node.img
            ~attrs:
              [ Attr.src "https://avatar.vercel.sh/shadcn1"
              ; Attr.alt "Photo"
              ; Attr.class_
                  "absolute inset-0 h-full w-full rounded-lg object-cover grayscale \
                   dark:brightness-20"
              ]
            ()
        ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Aspect ratio"
    ~description:"Displays content within a desired ratio."
    ~usage:
      {|Aspect_ratio.view ~ratio:(16. /. 9.)
  [ Node.img ~attrs:[ Attr.src "..."; Attr.class_ "rounded-md object-cover" ] () ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "ratio", "float", "Width over height ([16. /. 9.]); 1 by default."
          ; "class_", "string", "More Tailwind classes, merged last (on the content's box)."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ]
    [ Doc.static ~page "Demo" demo ]
;;
