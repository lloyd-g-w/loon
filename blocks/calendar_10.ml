open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~class_:"bg-transparent p-0"
      ~default:(Single (Some (Date.create_exn ~y:2025 ~m:Jun ~d:12)))
      graph
  in
  let%arr calendar in
  Card.root
    [ Card.header
        [ Card.title [ Node.text "Appointment" ]
        ; Card.description [ Node.text "Find a date" ]
        ; Card.action
            [ Button.view
                ~size:Sm
                ~variant:Outline
                ~on_click:
                  (let today = Calendar.today () in
                   Effect.Many
                     [ calendar.set_month today
                     ; calendar.set_selected (Single (Some today))
                     ])
                [ Node.text "Today" ]
            ]
        ]
    ; Card.content [ calendar.view ]
    ]
;;
