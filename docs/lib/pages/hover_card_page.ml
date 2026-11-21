open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "hover_card"

(*$ Demo *)
let demo (local_ graph) =
  Hover_card.component
    (Bonsai.return (fun card ->
       [ Hover_card.trigger card (Button.view ~variant:Link [ Node.text "@nextjs" ])
       ; Hover_card.content
           card
           ~class_:"w-80"
           [ Node.div
               ~attrs:[ Attr.class_ "flex justify-between gap-4" ]
               [ Node.span
                   ~attrs:
                     [ Attr.class_
                         "relative flex size-8 shrink-0 overflow-hidden rounded-full"
                     ]
                   [ Node.img
                       ~attrs:
                         [ Attr.src "https://github.com/vercel.png"
                         ; Attr.class_ "aspect-square size-full"
                         ]
                       ()
                   ]
               ; Node.div
                   ~attrs:[ Attr.class_ "space-y-1" ]
                   [ Node.h4
                       ~attrs:[ Attr.class_ "text-sm font-semibold" ]
                       [ Node.text "@nextjs" ]
                   ; Node.p
                       ~attrs:[ Attr.class_ "text-sm" ]
                       [ Node.text "The React Framework – created and maintained by @vercel." ]
                   ; Node.div
                       ~attrs:[ Attr.class_ "text-xs text-muted-foreground" ]
                       [ Node.text "Joined December 2021" ]
                   ]
               ]
           ]
       ]))
    graph
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Hover card"
    ~group:Overlays
    ~description:"For sighted users to preview content available behind a link."
    ~usage:
      {|Hover_card.component
  (return (fun card ->
     [ Hover_card.trigger card (Button.view ~variant:Link [ Node.text "Hover" ])
     ; Hover_card.content card
         [ Node.text "The React Framework – created and maintained by @vercel." ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "open_, on_open_change"
            , "bool, bool -> unit Effect.t"
            , "[Hover_card.view]: controlled. [Hover_card.component] keeps it \
               ([?default_open])." )
          ; ( "open_delay, close_delay"
            , "float"
            , "Milliseconds the pointer rests on the trigger before it opens (700), and \
               away from the trigger and the card before it closes (300)." )
          ; ( "side, side_offset, align, align_offset"
            , "Popper.Side.t, float, Popper.Align.t, float"
            , "[content]: where it opens ([Bottom], 4px, [Center] by default)." )
          ]
      ]
    [ Doc.example ~page "Demo" demo ]
;;
