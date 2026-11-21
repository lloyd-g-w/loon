open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~number_of_months:2
      ~default_month:(Date.create_exn ~y:2025 ~m:Jun ~d:12)
      ~required:true
      ~max:5
      ~class_:"rounded-lg border shadow-sm"
      ~default:
        (Multiple
           [ Date.create_exn ~y:2025 ~m:Jun ~d:12
           ; Date.create_exn ~y:2025 ~m:Jul ~d:24
           ])
      graph
  in
  let%arr calendar in
  calendar.view
;;
