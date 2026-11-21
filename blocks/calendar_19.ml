open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node

let presets =
  [ "Today", 0
  ; "Tomorrow", 1
  ; "In 3 days", 3
  ; "In a week", 7
  ; "In 2 weeks", 14
  ]
;;

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~default_month:(Date.create_exn ~y:2025 ~m:Jun ~d:12)
      ~class_:"bg-transparent p-0 [--cell-size:--spacing(9.5)]"
      ~default:(Single (Some (Date.create_exn ~y:2025 ~m:Jun ~d:12)))
      graph
  in
  let%arr calendar in
  Card.root
    ~class_:"max-w-[300px] py-4"
    [ Card.content ~class_:"px-4" [ calendar.view ]
    ; Card.footer
        ~class_:"flex flex-wrap gap-2 border-t px-4 !pt-4"
        (List.map presets ~f:(fun (label, days) ->
           Button.view
             ~variant:Outline
             ~size:Sm
             ~class_:"flex-1"
             ~on_click:
               (calendar.set_selected
                  (Single (Some (Date.add_days (Calendar.today ()) days))))
             [ Node.text label ]))
    ]
;;
