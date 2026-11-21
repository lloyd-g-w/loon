open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~default_month:(Date.create_exn ~y:2025 ~m:Jun ~d:12)
      ~number_of_months:2
      ~class_:"rounded-lg border shadow-sm"
      ~default:
        (Range
           (Some
              { from = Date.create_exn ~y:2025 ~m:Jun ~d:12
              ; to_ = Some (Date.create_exn ~y:2025 ~m:Jul ~d:15)
              }))
      graph
  in
  let%arr calendar in
  calendar.view
;;
