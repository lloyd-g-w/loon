open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let time_input ~id ~label ~default_value =
  Node.div
    [ Label.view ~for_:id ~class_:"sr-only" [ Node.text label ]
    ; Input.view
        ~id
        ~type_:Time
        ~attrs:[ Attr.create "step" "1"; Attr.create "value" default_value ]
        ~class_:
          "appearance-none [&::-webkit-calendar-picker-indicator]:hidden \
           [&::-webkit-calendar-picker-indicator]:appearance-none"
        ()
    ]
;;

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~class_:"bg-transparent p-0 [--cell-size:--spacing(10.5)]"
      ~default:(Single (Some (Date.create_exn ~y:2025 ~m:Jun ~d:12)))
      graph
  in
  let%arr calendar in
  Card.root
    ~class_:"w-fit py-4"
    [ Card.content ~class_:"px-4" [ calendar.view ]
    ; Card.footer
        ~class_:"flex gap-2 border-t px-4 !pt-4 *:[div]:w-full"
        [ time_input
            ~id:"time-from"
            ~label:"Start Time"
            ~default_value:"10:30:00"
        ; Node.span [ Node.text "-" ]
        ; time_input ~id:"time-to" ~label:"End Time" ~default_value:"12:30:00"
        ]
    ]
;;
