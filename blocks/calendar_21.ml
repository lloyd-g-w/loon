open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~default_month:(Date.create_exn ~y:2025 ~m:Jun ~d:12)
      ~number_of_months:1
      ~caption_layout:Dropdown
      ~class_:
        "rounded-lg border shadow-sm [--cell-size:--spacing(11)] \
         md:[--cell-size:--spacing(13)]"
      ~format_month_dropdown:(fun month ->
        Calendar.format "LLLL" (Date.create_exn ~y:2025 ~m:month ~d:1))
      ~day_content:(fun date ~outside ->
        let is_weekend =
          match Date.day_of_week date with
          | Sun | Sat -> true
          | _ -> false
        in
        Node.text (Int.to_string (Date.day date))
        ::
        (if outside
         then []
         else
           [ Node.span [ Node.text (if is_weekend then "$220" else "$100") ] ]))
      ~default:
        (Range
           (Some
              { from = Date.create_exn ~y:2025 ~m:Jun ~d:12
              ; to_ = Some (Date.create_exn ~y:2025 ~m:Jun ~d:17)
              }))
      graph
  in
  let%arr calendar in
  calendar.view
;;
