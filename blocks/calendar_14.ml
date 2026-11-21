open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon

let booked_dates =
  List.init 12 ~f:(fun i -> Date.create_exn ~y:2025 ~m:Jun ~d:(15 + i))
;;

let is_booked d = List.mem booked_dates d ~equal:Date.equal

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~default_month:(Date.create_exn ~y:2025 ~m:Jun ~d:12)
      ~disabled:is_booked
      ~modifiers:[ is_booked, "[&>button]:line-through opacity-100" ]
      ~class_:"rounded-lg border shadow-sm"
      ~default:(Single (Some (Date.create_exn ~y:2025 ~m:Jun ~d:12)))
      graph
  in
  let%arr calendar in
  calendar.view
;;
