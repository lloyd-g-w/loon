open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let time_input ~id ~label ~default_value =
  Node.div
    ~attrs:[ Attr.class_ "flex w-full flex-col gap-3" ]
    [ Label.view ~for_:id [ Node.text label ]
    ; Node.div
        ~attrs:[ Attr.class_ "relative flex w-full items-center gap-2" ]
        [ Icon.view
            ~class_:
              "text-muted-foreground pointer-events-none absolute left-2.5 \
               size-4 select-none"
            Clock_2
        ; Input.view
            ~id
            ~type_:Time
            ~attrs:[ Attr.create "step" "1"; Attr.create "value" default_value ]
            ~class_:
              "appearance-none pl-8 \
               [&::-webkit-calendar-picker-indicator]:hidden \
               [&::-webkit-calendar-picker-indicator]:appearance-none"
            ()
        ]
    ]
;;

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~class_:"bg-transparent p-0"
      ~default:(Single (Some (Date.create_exn ~y:2025 ~m:Jun ~d:12)))
      graph
  in
  let%arr calendar in
  Card.root
    ~class_:"w-fit py-4"
    [ Card.content ~class_:"px-4" [ calendar.view ]
    ; Card.footer
        ~class_:"flex flex-col gap-6 border-t px-4 !pt-4"
        [ time_input
            ~id:"time-from"
            ~label:"Start Time"
            ~default_value:"10:30:00"
        ; time_input ~id:"time-to" ~label:"End Time" ~default_value:"12:30:00"
        ]
    ]
;;
