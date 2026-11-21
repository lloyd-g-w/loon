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
      ~class_:"mx-auto [--cell-size:clamp(0px,calc(100vw/7.5),52px)]"
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
    ; Drawer.view
        ~id:("calendar-32-" ^ id)
        ~trigger_id:"date"
        ~open_
        ~on_open_change:set_open
        (fun drawer ->
           [ Drawer.trigger
               drawer
               (Button.view
                  ~variant:Outline
                  ~class_:"w-48 justify-between font-normal"
                  [ Node.text
                      (match date with
                       | Some date -> Calendar.format "M/d/yyyy" date
                       | None -> "Select date")
                  ; Icon.view Calendar_plus
                  ])
           ; Drawer.content
               drawer
               ~class_:"w-auto overflow-hidden p-0"
               [ Drawer.header
                   ~class_:"sr-only"
                   [ Drawer.title drawer [ Node.text "Select date" ]
                   ; Drawer.description
                       drawer
                       [ Node.text "Set your date of birth" ]
                   ]
               ; calendar.view
               ]
           ])
    ; Node.div
        ~attrs:[ Attr.class_ "text-muted-foreground px-1 text-sm" ]
        [ Node.text "This example works best on mobile." ]
    ]
;;
