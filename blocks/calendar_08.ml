open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~default_month:(Date.create_exn ~y:2025 ~m:Jun ~d:12)
      ~disabled:(fun d -> Date.( < ) d (Date.create_exn ~y:2025 ~m:Jun ~d:12))
      ~class_:"rounded-lg border shadow-sm"
      ~default:(Single (Some (Date.create_exn ~y:2025 ~m:Jun ~d:12)))
      graph
  in
  let%arr calendar in
  calendar.view
;;
