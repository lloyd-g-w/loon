open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~default_month:(Date.create_exn ~y:2025 ~m:Jun ~d:12)
      ~number_of_months:1
      ~min:5
      ~class_:"rounded-lg border shadow-sm"
      ~default:
        (Range
           (Some
              { from = Date.create_exn ~y:2025 ~m:Jun ~d:12
              ; to_ = Some (Date.create_exn ~y:2025 ~m:Jun ~d:26)
              }))
      graph
  in
  let%arr calendar in
  Vdom.Node.div
    ~attrs:[ Vdom.Attr.class_ "flex min-w-0 flex-col gap-2" ]
    [ calendar.view
    ; Vdom.Node.div
        ~attrs:[ Vdom.Attr.class_ "text-muted-foreground text-center text-xs" ]
        [ Vdom.Node.text "A minimum of 5 days is required" ]
    ]
;;
