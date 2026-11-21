open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let chart_data =
  [ "2025-06-01", 178.
  ; "2025-06-02", 470.
  ; "2025-06-03", 103.
  ; "2025-06-04", 439.
  ; "2025-06-05", 88.
  ; "2025-06-06", 294.
  ; "2025-06-07", 323.
  ; "2025-06-08", 385.
  ; "2025-06-09", 438.
  ; "2025-06-10", 155.
  ; "2025-06-11", 92.
  ; "2025-06-12", 492.
  ; "2025-06-13", 81.
  ; "2025-06-14", 426.
  ; "2025-06-15", 307.
  ; "2025-06-16", 371.
  ; "2025-06-17", 475.
  ; "2025-06-18", 107.
  ; "2025-06-19", 341.
  ; "2025-06-20", 408.
  ; "2025-06-21", 169.
  ; "2025-06-22", 317.
  ; "2025-06-23", 480.
  ; "2025-06-24", 132.
  ; "2025-06-25", 141.
  ; "2025-06-26", 434.
  ; "2025-06-27", 448.
  ; "2025-06-28", 149.
  ; "2025-06-29", 103.
  ; "2025-06-30", 446.
  ]
;;

let total = List.sum (module Float) chart_data ~f:snd

let chart_config : Chart.Config.t =
  [ ( "visitors"
    , Chart.Config.item ~label:"Visitors" ~color:"var(--color-primary)" () )
  ]
;;

let view (local_ graph) =
  let from = Date.create_exn ~y:2025 ~m:Jun ~d:5 in
  let calendar =
    Calendar.component
      ~class_:"w-full"
      ~default_month:from
      ~disable_navigation:true
      ~start_month:from
      ~fixed_weeks:true
      ~show_outside_days:true
      ~disabled:(fun d -> Date.( > ) d (Date.create_exn ~y:2025 ~m:Jul ~d:1))
      ~default:
        (Range
           (Some { from; to_ = Some (Date.create_exn ~y:2025 ~m:Jun ~d:20) }))
      graph
  in
  let chart = Chart.component graph in
  let popover =
    Popover.component
      (let%arr calendar in
       let label =
         match calendar.selected with
         | Range (Some { from; to_ = Some to_ }) ->
           sprintf
             "%s - %s"
             (Calendar.format "M/d/yyyy" from)
             (Calendar.format "M/d/yyyy" to_)
         | _ -> "June 2025"
       in
       fun popover ->
         [ Popover.trigger
             popover
             (Button.view
                ~variant:Outline
                [ Icon.view Calendar; Node.text label ])
         ; Popover.content
             popover
             ~class_:"w-auto overflow-hidden p-0"
             ~align:End
             [ calendar.view ]
         ])
      graph
  in
  let%arr calendar
  and chart
  and popover in
  let filtered_data =
    match calendar.selected with
    | Range (Some { from; to_ = Some to_ }) ->
      List.filter chart_data ~f:(fun (date, _) ->
        Date.between (Date.of_string date) ~low:from ~high:to_)
    | _ -> chart_data
  in
  Card.root
    ~class_:"@container/card w-full max-w-xl"
    [ Card.header
        ~class_:"flex flex-col border-b @md/card:grid"
        [ Card.title [ Node.text "Web Analytics" ]
        ; Card.description
            [ Node.text "Showing total visitors for this month." ]
        ; Card.action ~class_:"mt-2 @md/card:mt-0" [ popover ]
        ]
    ; Card.content
        ~class_:"px-4"
        [ Chart.container
            ~config:chart_config
            ~class_:"aspect-auto h-[250px] w-full"
            chart
            (Chart.bar_chart
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               ~data:
                 (List.map filtered_data ~f:(fun (date, visitors) ->
                    [ "date", `Text date; "visitors", `Num visitors ]))
               [ Chart.cartesian_grid ~vertical:false ()
               ; Chart.x_axis
                   ~data_key:"date"
                   ~tick_line:false
                   ~axis_line:false
                   ~tick_margin:8.
                   ~min_tick_gap:20.
                   ~tick_formatter:(fun value ->
                     Calendar.format "d" (Date.of_string value))
                   ()
               ; Chart.tooltip
                   ~content:
                     (Chart.tooltip_content
                        ~class_:"w-[150px]"
                        ~name_key:"visitors"
                        ~label_formatter:(fun value _ ->
                          [ Node.text
                              (Calendar.format "PP" (Date.of_string value))
                          ])
                        ())
                   ()
               ; Chart.bar
                   ~data_key:"visitors"
                   ~fill:"var(--color-visitors)"
                   ~radius:(`All 4.)
                   ()
               ])
        ]
    ; Card.footer
        ~class_:"border-t"
        [ Node.div
            ~attrs:[ Attr.class_ "text-sm" ]
            [ Node.text "You had "
            ; Node.span
                ~attrs:[ Attr.class_ "font-semibold" ]
                [ Node.text (Chart.to_locale_string total) ]
            ; Node.text " visitors for the month of June."
            ]
        ]
    ]
;;
