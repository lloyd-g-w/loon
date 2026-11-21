open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~default_month:(Date.create_exn ~y:2025 ~m:Jun ~d:17)
      ~number_of_months:2
      ~disabled:(fun d ->
        match Date.day_of_week d with
        | Sun | Sat -> true
        | _ -> false)
      ~class_:"rounded-lg border shadow-sm"
      ~exclude_disabled:true
      ~default:
        (Range
           (Some
              { from = Date.create_exn ~y:2025 ~m:Jun ~d:17
              ; to_ = Some (Date.create_exn ~y:2025 ~m:Jun ~d:20)
              }))
      graph
  in
  let%arr calendar in
  calendar.view
;;
