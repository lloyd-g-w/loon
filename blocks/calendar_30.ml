open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~caption_layout:Dropdown
      ~default:
        (Range
           (Some
              { from = Date.create_exn ~y:2025 ~m:Jun ~d:4
              ; to_ = Some (Date.create_exn ~y:2025 ~m:Jun ~d:10)
              }))
      graph
  in
  let popover =
    Popover.component
      ~trigger_id:"dates"
      (let%arr calendar in
       let label =
         match calendar.selected with
         | Range (Some { from; to_ = Some to_ }) ->
           Little_date.format_date_range ~include_time:false (from, 0) (to_, 0)
         | _ -> "Select date"
       in
       fun popover ->
         [ Popover.trigger
             popover
             (Button.view
                ~variant:Outline
                ~class_:"w-56 justify-between font-normal"
                [ Node.text label; Icon.view Chevron_down ])
         ; Popover.content
             popover
             ~class_:"w-auto overflow-hidden p-0"
             ~align:Start
             [ calendar.view ]
         ])
      graph
  in
  let%arr popover in
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col gap-3" ]
    [ Label.view ~for_:"dates" ~class_:"px-1" [ Node.text "Select your stay" ]
    ; popover
    ]
;;
