open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~number_of_months:2
      ~start_month:(Date.create_exn ~y:2025 ~m:Jun ~d:1)
      ~end_month:(Date.create_exn ~y:2025 ~m:Jul ~d:31)
      ~disable_navigation:true
      ~class_:"rounded-lg border shadow-sm"
      ~default:
        (Range
           (Some
              { from = Date.create_exn ~y:2025 ~m:Jun ~d:17
              ; to_ = Some (Date.create_exn ~y:2025 ~m:Jun ~d:20)
              }))
      graph
  in
  let%arr calendar in
  Vdom.Node.div
    ~attrs:[ Vdom.Attr.class_ "flex min-w-0 flex-col gap-2" ]
    [ calendar.view
    ; Vdom.Node.div
        ~attrs:[ Vdom.Attr.class_ "text-muted-foreground text-center text-xs" ]
        [ Vdom.Node.text "We are open in June and July only." ]
    ]
;;
