open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "tooltip"

(*$ Demo *)
let demo (local_ graph) =
  Tooltip.component
    (Bonsai.return (fun tooltip ->
       [ Tooltip.trigger tooltip (Button.view ~variant:Outline [ Node.text "Hover" ])
       ; Tooltip.content tooltip [ Node.p [ Node.text "Add to library" ] ]
       ]))
    graph
(*$*)

(*$ Sides *)
let sides (local_ graph) =
  let tooltip side (local_ graph) =
    Tooltip.component
      (Bonsai.return (fun tooltip ->
         [ Tooltip.trigger
             tooltip
             (Button.view
                ~variant:Outline
                [ Node.text (String.capitalize (Popper.Side.name side)) ])
         ; Tooltip.content tooltip ~side [ Node.p [ Node.text "Add to library" ] ]
         ]))
      graph
  in
  let top = tooltip Top graph in
  let right = tooltip Right graph in
  let bottom = tooltip Bottom graph in
  let left = tooltip Left graph in
  let%arr top and right and bottom and left in
  Node.div ~attrs:[ Attr.class_ "flex flex-wrap gap-2" ] [ left; top; bottom; right ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Tooltip"
    ~description:
      "A popup that displays information related to an element when the element \
       receives keyboard focus or the mouse hovers over it."
    ~usage:
      {|Tooltip.component
  (return (fun tooltip ->
     [ Tooltip.trigger tooltip (Button.view ~variant:Outline [ Node.text "Hover" ])
     ; Tooltip.content tooltip [ Node.p [ Node.text "Add to library" ] ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "open_, on_open_change"
            , "bool, bool -> unit Effect.t"
            , "[Tooltip.view]: controlled. [Tooltip.component] keeps it \
               ([?default_open])." )
          ; ( "side, side_offset, align, align_offset"
            , "Popper.Side.t, float, Popper.Align.t, float"
            , "[content]: where it opens ([Top], 0px, [Center] by default); it flips \
               when there is no room." )
          ]
      ; Doc.p
          "As shadcn's, it opens at once (no delay): when the pointer moves over the \
           trigger or the keyboard focuses it, and closes when the pointer leaves the \
           trigger and the tooltip, on a press, on blur and on Esc. While open the \
           trigger is described by the tooltip's text ([aria-describedby])."
      ]
    [ Doc.example ~page "Demo" demo; Doc.example ~page "Sides" sides ]
;;
