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
    ~open_delay:10.
    ~close_delay:100.
    (Bonsai.return (fun card ->
       [ Hover_card.trigger card (Button.view ~variant:Link [ Node.text "Hover Here" ])
       ; Hover_card.content
           card
           ~class_:"flex w-64 flex-col gap-0.5"
           [ Node.div ~attrs:[ Attr.class_ "font-semibold" ] [ Node.text "@nextjs" ]
           ; Node.div
               [ Node.text "The React Framework – created and maintained by @vercel." ]
           ; Node.div
               ~attrs:[ Attr.class_ "mt-1 text-xs text-muted-foreground" ]
               [ Node.text "Joined December 2021" ]
           ]
       ]))
    graph
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Hover card"
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
