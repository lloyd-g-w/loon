open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "chart_tooltip"

(* Every example draws the same stacked bar chart; only its tooltip
   differs, as in shadcn's. *)
let chart_data =
  List.map
    [ "2024-07-15", 450., 300.
    ; "2024-07-16", 380., 420.
    ; "2024-07-17", 520., 120.
    ; "2024-07-18", 140., 550.
    ; "2024-07-19", 600., 350.
    ; "2024-07-20", 480., 400.
    ]
    ~f:(fun (date, running, swimming) ->
      [ "date", `Text date; "running", `Num running; "swimming", `Num swimming ])
;;

let chart_config : Chart.Config.t =
  [ "running", Chart.Config.item ~label:"Running" ~color:"var(--chart-1)" ()
  ; "swimming", Chart.Config.item ~label:"Swimming" ~color:"var(--chart-2)" ()
  ]
;;

(* [toLocaleDateString("en-US", { weekday: "short" })]: "Mon". *)
let weekday date =
  Date.of_string date
  |> Date.day_of_week
  |> Day_of_week.to_string
  |> String.lowercase
  |> String.capitalize
;;

let card ?(config = chart_config) ~title ~description chart tooltip =
  Card.root
    [ Card.header
        [ Card.title [ Node.text title ]; Card.description [ Node.text description ] ]
    ; Card.content
        [ Chart.container
            ~config
            chart
            (Chart.bar_chart
               ~data:chart_data
               [ Chart.x_axis
                   ~data_key:"date"
                   ~tick_line:false
                   ~tick_margin:10.
                   ~axis_line:false
                   ~tick_formatter:weekday
                   ()
               ; Chart.bar
                   ~data_key:"running"
                   ~stack_id:"a"
                   ~fill:"var(--color-running)"
                   ~radius:(`Corners (0., 0., 4., 4.))
                   ()
               ; Chart.bar
                   ~data_key:"swimming"
                   ~stack_id:"a"
                   ~fill:"var(--color-swimming)"
                   ~radius:(`Corners (4., 4., 0., 0.))
                   ()
               ; tooltip
               ])
        ]
    ]
;;

(*$ Tooltip - Default
    Default tooltip with ChartTooltipContent. *)
let default (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Tooltip - Default"
    ~description:"Default tooltip with ChartTooltipContent."
    chart
    (Chart.tooltip ~content:(Chart.tooltip_content ()) ~cursor:false ~default_index:1 ())
;;

(*$*)

(*$ Tooltip - Line Indicator
    Tooltip with line indicator. *)
let indicator_line (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Tooltip - Line Indicator"
    ~description:"Tooltip with line indicator."
    chart
    (Chart.tooltip
       ~content:(Chart.tooltip_content ~indicator:Line ())
       ~cursor:false
       ~default_index:1
       ())
;;

(*$*)

(*$ Tooltip - No Indicator
    Tooltip with no indicator. *)
let indicator_none (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Tooltip - No Indicator"
    ~description:"Tooltip with no indicator."
    chart
    (Chart.tooltip
       ~content:(Chart.tooltip_content ~hide_indicator:true ())
       ~cursor:false
       ~default_index:1
       ())
;;

(*$*)

(*$ Tooltip - Custom label
    Tooltip with custom label from chartConfig. *)
let label_custom (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let config : Chart.Config.t =
    [ "activities", Chart.Config.item ~label:"Activities" ()
    ; "running", Chart.Config.item ~label:"Running" ~color:"var(--chart-1)" ()
    ; "swimming", Chart.Config.item ~label:"Swimming" ~color:"var(--chart-2)" ()
    ]
  in
  card
    ~config
    ~title:"Tooltip - Custom label"
    ~description:"Tooltip with custom label from chartConfig."
    chart
    (Chart.tooltip
       ~content:(Chart.tooltip_content ~label_key:"activities" ~indicator:Line ())
       ~cursor:false
       ~default_index:1
       ())
;;

(*$*)

(*$ Tooltip - Label Formatter
    Tooltip with label formatter. *)
let label_formatter (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  (* [toLocaleDateString("en-US", { day: "numeric", month: "long", year:
     "numeric" })]: "July 16, 2024". *)
  let long_date value =
    let date = Date.of_string value in
    let months =
      [| "January"; "February"; "March"; "April"; "May"; "June"; "July"; "August"
       ; "September"; "October"; "November"; "December"
      |]
    in
    sprintf
      "%s %d, %d"
      months.(Month.to_int (Date.month date) - 1)
      (Date.day date)
      (Date.year date)
  in
  card
    ~title:"Tooltip - Label Formatter"
    ~description:"Tooltip with label formatter."
    chart
    (Chart.tooltip
       ~content:
         (Chart.tooltip_content
            ~label_formatter:(fun value _payload -> [ Node.text (long_date value) ])
            ())
       ~cursor:false
       ~default_index:1
       ())
;;

(*$*)

(*$ Tooltip - No Label
    Tooltip with no label. *)
let label_none (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Tooltip - No Label"
    ~description:"Tooltip with no label."
    chart
    (Chart.tooltip
       ~content:(Chart.tooltip_content ~hide_indicator:true ~hide_label:true ())
       ~cursor:false
       ~default_index:1
       ())
;;

(*$*)

(*$ Tooltip - Formatter
    Tooltip with custom formatter. *)
let formatter (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Tooltip - Formatter"
    ~description:"Tooltip with custom formatter ."
    chart
    (Chart.tooltip
       ~content:
         (Chart.tooltip_content
            ~hide_label:true
            ~formatter:(fun (item : Chart.Item.t) _index ->
              let label =
                match List.Assoc.find chart_config ~equal:String.equal item.name with
                | Some { label = Some label; _ } -> label
                | _ -> item.name
              in
              [ Node.div
                  ~attrs:
                    [ Attr.class_
                        "flex min-w-[130px] items-center text-xs text-muted-foreground"
                    ]
                  [ Node.text label
                  ; Node.div
                      ~attrs:
                        [ Attr.class_
                            "ml-auto flex items-baseline gap-0.5 font-mono font-medium \
                             text-foreground tabular-nums"
                        ]
                      [ Node.text
                          (Option.value_map item.value ~default:"" ~f:Chart.Value.to_string)
                      ; Node.span
                          ~attrs:[ Attr.class_ "font-normal text-muted-foreground" ]
                          [ Node.text "kcal" ]
                      ]
                  ]
              ])
            ())
       ~cursor:false
       ~default_index:1
       ())
;;

(*$*)

(*$ Tooltip - Icons
    Tooltip with icons. *)
let icons (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let config : Chart.Config.t =
    [ ( "running"
      , Chart.Config.item
          ~label:"Running"
          ~color:"var(--chart-1)"
          ~icon:(fun () -> Icon.view Footprints)
          () )
    ; ( "swimming"
      , Chart.Config.item
          ~label:"Swimming"
          ~color:"var(--chart-2)"
          ~icon:(fun () -> Icon.view Waves)
          () )
    ]
  in
  card
    ~config
    ~title:"Tooltip - Icons"
    ~description:"Tooltip with icons."
    chart
    (Chart.tooltip
       ~content:(Chart.tooltip_content ~hide_label:true ())
       ~cursor:false
       ~default_index:1
       ())
;;

(*$*)

(*$ Tooltip - Advanced
    Tooltip with custom formatter and total. *)
let advanced (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let kcal value =
    Node.div
      ~attrs:
        [ Attr.class_
            "ml-auto flex items-baseline gap-0.5 font-mono font-medium text-foreground \
             tabular-nums"
        ]
      [ Node.text value
      ; Node.span ~attrs:[ Attr.class_ "font-normal text-muted-foreground" ] [ Node.text "kcal" ]
      ]
  in
  card
    ~title:"Tooltip - Advanced"
    ~description:"Tooltip with custom formatter and total."
    chart
    (Chart.tooltip
       ~content:
         (Chart.tooltip_content
            ~hide_label:true
            ~class_:"w-[180px]"
            ~formatter:(fun (item : Chart.Item.t) index ->
              let label =
                match List.Assoc.find chart_config ~equal:String.equal item.name with
                | Some { label = Some label; _ } -> label
                | _ -> item.name
              in
              let num key = Option.value (Chart.Row.num item.row key) ~default:0. in
              [ Node.div
                  ~attrs:
                    [ Attr.class_ "h-2.5 w-2.5 shrink-0 rounded-[2px] bg-(--color-bg)"
                    ; Attr.css_var ~name:"color-bg" (sprintf "var(--color-%s)" item.name)
                    ]
                  []
              ; Node.text label
              ; kcal (Option.value_map item.value ~default:"" ~f:Chart.Value.to_string)
              ; (* Add this after the last item *)
                (if index = 1
                 then
                   Node.div
                     ~attrs:
                       [ Attr.class_
                           "mt-1.5 flex basis-full items-center border-t pt-1.5 text-xs \
                            font-medium text-foreground"
                       ]
                     [ Node.text "Total"
                     ; kcal (Chart.Value.to_string (`Num (num "running" +. num "swimming")))
                     ]
                 else Node.none)
              ])
            ())
       ~cursor:false
       ~default_index:1
       ())
;;

(*$*)

let page =
  Doc.page
    ~slug:"chart-tooltip"
    ~title:"Tooltips"
    ~section:Charts
    ~order:7
    ~description:
      "Chart tooltips: indicators, custom labels, label formatters, formatters and icons."
    [ Doc.example ~page "Tooltip - Default" (Chart_data.frame default)
    ; Doc.example ~page "Tooltip - Line Indicator" (Chart_data.frame indicator_line)
    ; Doc.example ~page "Tooltip - No Indicator" (Chart_data.frame indicator_none)
    ; Doc.example ~page "Tooltip - Custom label" (Chart_data.frame label_custom)
    ; Doc.example ~page "Tooltip - Label Formatter" (Chart_data.frame label_formatter)
    ; Doc.example ~page "Tooltip - No Label" (Chart_data.frame label_none)
    ; Doc.example ~page "Tooltip - Formatter" (Chart_data.frame formatter)
    ; Doc.example ~page "Tooltip - Icons" (Chart_data.frame icons)
    ; Doc.example ~page "Tooltip - Advanced" (Chart_data.frame advanced)
    ]
;;
