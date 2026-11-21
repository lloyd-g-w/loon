open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "aspect_ratio"

(*$ Demo *)
let demo =
  Aspect_ratio.view
    ~ratio:(16. /. 9.)
    ~class_:"rounded-lg bg-muted"
    [ Node.img
        ~attrs:
          [ Attr.src
              "https://images.unsplash.com/photo-1588345921523-c2dcdb7f1dcd?w=800&dpr=2&q=80"
          ; Attr.alt "Photo by Drew Beamer"
          ; Attr.class_
              "h-full w-full rounded-lg object-cover dark:brightness-[0.2] dark:grayscale"
          ]
        ()
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Aspect ratio"
    ~group:Display
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
