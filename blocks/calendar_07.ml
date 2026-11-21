open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~default_month:(Date.create_exn ~y:2025 ~m:Jun ~d:18)
      ~number_of_months:2
      ~min:2
      ~max:20
      ~class_:"rounded-lg border shadow-sm"
      ~default:
        (Range
           (Some
              { from = Date.create_exn ~y:2025 ~m:Jun ~d:18
              ; to_ = Some (Date.create_exn ~y:2025 ~m:Jul ~d:7)
              }))
      graph
  in
  let%arr calendar in
  Vdom.Node.div
    ~attrs:[ Vdom.Attr.class_ "flex min-w-0 flex-col gap-2" ]
    [ calendar.view
    ; Vdom.Node.div
        ~attrs:[ Vdom.Attr.class_ "text-muted-foreground text-center text-xs" ]
        [ Vdom.Node.text "Your stay must be between 2 and 20 nights" ]
    ]
;;
