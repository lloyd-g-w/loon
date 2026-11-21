open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~class_:
        "rounded-lg border [--cell-size:--spacing(11)] \
         md:[--cell-size:--spacing(12)]"
      ~button_variant:Ghost
      ~default:(Single (Some (Date.create_exn ~y:2025 ~m:Jun ~d:12)))
      graph
  in
  let%arr calendar in
  calendar.view
;;
