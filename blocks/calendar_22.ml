open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let view (local_ graph) =
  let open_, set_open = Bonsai.state false graph in
  let calendar =
    Calendar.component
      ~caption_layout:Dropdown
      ~on_select:
        (let%arr set_open in
         fun _ -> set_open false)
      ~default:(Single None)
      graph
  in
  let id = Bonsai.path_id graph in
  let%arr open_
  and set_open
  and calendar
  and id in
  let date =
    match calendar.selected with
    | Single date -> date
    | Multiple _ | Range _ -> None
  in
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col gap-3" ]
    [ Label.view ~for_:"date" ~class_:"px-1" [ Node.text "Date of birth" ]
    ; Popover.view
        ~id:("calendar-22-" ^ id)
        ~trigger_id:"date"
        ~open_
        ~on_open_change:set_open
        (fun popover ->
           [ Popover.trigger
               popover
               (Button.view
                  ~variant:Outline
                  ~class_:"w-48 justify-between font-normal"
                  [ Node.text
                      (match date with
                       | Some date -> Calendar.format "M/d/yyyy" date
                       | None -> "Select date")
                  ; Icon.view Chevron_down
                  ])
           ; Popover.content
               popover
               ~class_:"w-auto overflow-hidden p-0"
               ~align:Start
               [ calendar.view ]
           ])
    ]
;;
