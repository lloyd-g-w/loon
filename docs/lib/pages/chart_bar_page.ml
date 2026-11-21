open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "chart_bar"

(* The data, config and footer most of the examples share, as shadcn's do. *)
let chart_data =
  List.map
    [ "January", 186., 80.
    ; "February", 305., 200.
    ; "March", 237., 120.
    ; "April", 73., 190.
    ; "May", 209., 130.
    ; "June", 214., 140.
    ]
    ~f:(fun (month, desktop, mobile) ->
      [ "month", `Text month; "desktop", `Num desktop; "mobile", `Num mobile ])
;;

let chart_config : Chart.Config.t =
  [ "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--chart-1)" ()
  ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"var(--chart-2)" ()
  ]
;;

let browser_data visitors =
  List.map2_exn
    [ "chrome"; "safari"; "firefox"; "edge"; "other" ]
    visitors
    ~f:(fun browser visitors ->
      [ "browser", `Text browser
      ; "visitors", `Num visitors
      ; "fill", `Text ("var(--color-" ^ browser ^ ")")
      ])
;;

let browser_config : Chart.Config.t =
  [ "visitors", Chart.Config.item ~label:"Visitors" ()
  ; "chrome", Chart.Config.item ~label:"Chrome" ~color:"var(--chart-1)" ()
  ; "safari", Chart.Config.item ~label:"Safari" ~color:"var(--chart-2)" ()
  ; "firefox", Chart.Config.item ~label:"Firefox" ~color:"var(--chart-3)" ()
  ; "edge", Chart.Config.item ~label:"Edge" ~color:"var(--chart-4)" ()
  ; "other", Chart.Config.item ~label:"Other" ~color:"var(--chart-5)" ()
  ]
;;

(* [chartConfig[value]?.label] *)
let config_label (config : Chart.Config.t) value =
  match List.Assoc.find config ~equal:String.equal value with
  | Some { label = Some label; _ } -> label
  | _ -> ""
;;

let header ~title =
  Card.header
    [ Card.title [ Node.text title ]
    ; Card.description [ Node.text "January - June 2024" ]
    ]
;;

let footer =
  Card.footer
    ~class_:"flex-col items-start gap-2 text-sm"
    [ Node.div
        ~attrs:[ Attr.class_ "flex gap-2 leading-none font-medium" ]
        [ Node.text "Trending up by 5.2% this month "
        ; Icon.view ~class_:"h-4 w-4" Trending_up
        ]
    ; Node.div
        ~attrs:[ Attr.class_ "leading-none text-muted-foreground" ]
        [ Node.text "Showing total visitors for the last 6 months" ]
    ]
;;

let month_axis =
  Chart.x_axis
    ~data_key:"month"
    ~tick_line:false
    ~tick_margin:10.
    ~axis_line:false
    ~tick_formatter:(fun value -> String.prefix value 3)
    ()
;;

(*$ Bar Chart - Interactive
    An interactive bar chart. *)
let interactive (local_ graph) =
  let active_chart, set_active_chart = Bonsai.state "desktop" graph in
  let chart = Chart.component graph in
  let%arr active_chart and set_active_chart and chart in
  let config : Chart.Config.t =
    [ "views", Chart.Config.item ~label:"Page Views" ()
    ; "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--chart-2)" ()
    ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"var(--chart-1)" ()
    ]
  in
  let total key =
    List.sum
      (module Float)
      Chart_data.visitors_by_day
      ~f:(fun row -> Option.value (Chart.Row.num row key) ~default:0.)
  in
  Card.root
    ~class_:"py-0"
    [ Card.header
        ~class_:"flex flex-col items-stretch border-b p-0! sm:flex-row"
        [ Node.div
            ~attrs:
              [ Attr.class_
                  "flex flex-1 flex-col justify-center gap-1 px-6 pt-4 pb-3 sm:py-0!"
              ]
            [ Card.title [ Node.text "Bar Chart - Interactive" ]
            ; Card.description [ Node.text "Showing total visitors for the last 3 months" ]
            ]
        ; Node.div
            ~attrs:[ Attr.class_ "flex" ]
            (List.map [ "desktop"; "mobile" ] ~f:(fun key ->
               Node.button
                 ~attrs:
                   [ Attr.create
                       "data-active"
                       (Bool.to_string (String.equal active_chart key))
                   ; Attr.class_
                       "relative z-30 flex flex-1 flex-col justify-center gap-1 border-t \
                        px-6 py-4 text-left even:border-l data-[active=true]:bg-muted/50 \
                        sm:border-t-0 sm:border-l sm:px-8 sm:py-6"
                   ; Attr.on_click (fun _ -> set_active_chart key)
                   ]
                 [ Node.span
                     ~attrs:[ Attr.class_ "text-xs text-muted-foreground" ]
                     [ Node.text (config_label config key) ]
                 ; Node.span
                     ~attrs:[ Attr.class_ "text-lg leading-none font-bold sm:text-3xl" ]
                     [ Node.text (Chart.to_locale_string (total key)) ]
                 ]))
        ]
    ; Card.content
        ~class_:"px-2 sm:p-6"
        [ Chart.container
            ~config
            ~class_:"aspect-auto h-[250px] w-full"
            chart
            (Chart.bar_chart
               ~data:Chart_data.visitors_by_day
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; Chart.x_axis
                   ~data_key:"date"
                   ~tick_line:false
                   ~axis_line:false
                   ~tick_margin:8.
                   ~min_tick_gap:32.
                   ~tick_formatter:(fun value -> Chart_data.short_date value)
                   ()
               ; Chart.tooltip
                   ~content:
                     (Chart.tooltip_content
                        ~class_:"w-[150px]"
                        ~name_key:"views"
                        ~label_formatter:(fun value _ ->
                          [ Node.text (Chart_data.short_date ~year:true value) ])
                        ())
                   ()
               ; Chart.bar
                   ~data_key:active_chart
                   ~fill:("var(--color-" ^ active_chart ^ ")")
                   ()
               ])
        ]
    ]
;;

(*$*)

(*$ Bar Chart
    A bar chart. *)
let default (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Bar Chart"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.bar_chart
               ~data:chart_data
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.bar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~radius:(`All 8.) ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Bar Chart - Horizontal
    A horizontal bar chart. *)
let horizontal (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Bar Chart - Horizontal"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.bar_chart
               ~data:chart_data
               ~layout:Vertical
               ~margin:(Chart.margin ~left:(-20.) ())
               [ Chart.x_axis ~type_:Number ~data_key:"desktop" ~hide:true ()
               ; Chart.y_axis
                   ~data_key:"month"
                   ~type_:Category
                   ~tick_line:false
                   ~tick_margin:10.
                   ~axis_line:false
                   ~tick_formatter:(fun value -> String.prefix value 3)
                   ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.bar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~radius:(`All 5.) ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Bar Chart - Multiple
    A multiple bar chart. *)
let multiple (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Bar Chart - Multiple"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.bar_chart
               ~data:chart_data
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~indicator:Dashed ())
                   ()
               ; Chart.bar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~radius:(`All 4.) ()
               ; Chart.bar ~data_key:"mobile" ~fill:"var(--color-mobile)" ~radius:(`All 4.) ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Bar Chart - Stacked + Legend
    A stacked bar chart with a legend. *)
let stacked (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Bar Chart - Stacked + Legend"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.bar_chart
               ~data:chart_data
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip ~content:(Chart.tooltip_content ~hide_label:true ()) ()
               ; Chart.legend ~content:(Chart.legend_content ()) ()
               ; Chart.bar
                   ~data_key:"desktop"
                   ~stack_id:"a"
                   ~fill:"var(--color-desktop)"
                   ~radius:(`Corners (0., 0., 4., 4.))
                   ()
               ; Chart.bar
                   ~data_key:"mobile"
                   ~stack_id:"a"
                   ~fill:"var(--color-mobile)"
                   ~radius:(`Corners (4., 4., 0., 0.))
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Bar Chart - Label
    A bar chart with a label. *)
let label (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Bar Chart - Label"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.bar_chart
               ~data:chart_data
               ~margin:(Chart.margin ~top:20. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.bar
                   ~data_key:"desktop"
                   ~fill:"var(--color-desktop)"
                   ~radius:(`All 8.)
                   ~children:
                     [ Chart.label_list
                         ~position:Top
                         ~offset:12.
                         ~class_:"fill-foreground"
                         ~font_size:12.
                         ()
                     ]
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Bar Chart - Custom Label
    A bar chart with a custom label. *)
let label_custom (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let config : Chart.Config.t =
    [ "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--chart-2)" ()
    ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"var(--chart-2)" ()
    ; "label", Chart.Config.item ~color:"var(--background)" ()
    ]
  in
  Card.root
    [ header ~title:"Bar Chart - Custom Label"
    ; Card.content
        [ Chart.container
            ~config
            chart
            (Chart.bar_chart
               ~data:chart_data
               ~layout:Vertical
               ~margin:(Chart.margin ~right:16. ())
               [ Chart.cartesian_grid ~horizontal:false ()
               ; Chart.y_axis
                   ~data_key:"month"
                   ~type_:Category
                   ~tick_line:false
                   ~tick_margin:10.
                   ~axis_line:false
                   ~tick_formatter:(fun value -> String.prefix value 3)
                   ~hide:true
                   ()
               ; Chart.x_axis ~data_key:"desktop" ~type_:Number ~hide:true ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~indicator:Line ())
                   ()
               ; Chart.bar
                   ~data_key:"desktop"
                   ~fill:"var(--color-desktop)"
                   ~radius:(`All 4.)
                   ~children:
                     [ Chart.label_list
                         ~data_key:"month"
                         ~position:Inside_left
                         ~offset:8.
                         ~class_:"fill-(--color-label)"
                         ~font_size:12.
                         ()
                     ; Chart.label_list
                         ~data_key:"desktop"
                         ~position:Right
                         ~offset:8.
                         ~class_:"fill-foreground"
                         ~font_size:12.
                         ()
                     ]
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Bar Chart - Mixed
    A mixed bar chart. *)
let mixed (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Bar Chart - Mixed"
    ; Card.content
        [ Chart.container
            ~config:browser_config
            chart
            (Chart.bar_chart
               ~data:(browser_data [ 275.; 200.; 187.; 173.; 90. ])
               ~layout:Vertical
               ~margin:(Chart.margin ~left:0. ())
               [ Chart.y_axis
                   ~data_key:"browser"
                   ~type_:Category
                   ~tick_line:false
                   ~tick_margin:10.
                   ~axis_line:false
                   ~tick_formatter:(fun value -> config_label browser_config value)
                   ()
               ; Chart.x_axis ~data_key:"visitors" ~type_:Number ~hide:true ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.bar ~data_key:"visitors" ~radius:(`All 5.) ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Bar Chart - Active
    A bar chart with an active bar. *)
let active (local_ graph) =
  let active_index = 2 in
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Bar Chart - Active"
    ; Card.content
        [ Chart.container
            ~config:browser_config
            chart
            (Chart.bar_chart
               ~data:(browser_data [ 187.; 200.; 275.; 173.; 90. ])
               [ Chart.cartesian_grid ~vertical:false ()
               ; Chart.x_axis
                   ~data_key:"browser"
                   ~tick_line:false
                   ~tick_margin:10.
                   ~axis_line:false
                   ~tick_formatter:(fun value -> config_label browser_config value)
                   ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.bar
                   ~data_key:"visitors"
                   ~stroke_width:2.
                   ~radius:(`All 8.)
                   ~shape:(fun props ->
                     if props.index = active_index
                     then
                       Chart.rectangle
                         ~attrs:
                           [ Attr.create "fill-opacity" "0.8"
                           ; Attr.create
                               "stroke"
                               (Option.value (Chart.Row.text props.row "fill") ~default:"")
                           ; Attr.create "stroke-dasharray" "4"
                           ; Attr.create "stroke-dashoffset" "4"
                           ]
                         props
                     else Chart.rectangle props)
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Bar Chart - Negative
    A bar chart with negative values. *)
let negative (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let data =
    List.map
      [ "January", 186.
      ; "February", 205.
      ; "March", -207.
      ; "April", 173.
      ; "May", -209.
      ; "June", 214.
      ]
      ~f:(fun (month, visitors) -> [ "month", `Text month; "visitors", `Num visitors ])
  in
  let config : Chart.Config.t = [ "visitors", Chart.Config.item ~label:"Visitors" () ] in
  Card.root
    [ header ~title:"Bar Chart - Negative"
    ; Card.content
        [ Chart.container
            ~config
            chart
            (Chart.bar_chart
               ~data
               [ Chart.cartesian_grid ~vertical:false ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ~hide_indicator:true ())
                   ()
               ; Chart.bar
                   ~data_key:"visitors"
                   ~children:
                     (Chart.label_list ~position:Top ~data_key:"month" ~fill_opacity:1. ()
                      :: List.map data ~f:(fun item ->
                        Chart.cell
                          ~fill:
                            (match Chart.Row.num item "visitors" with
                             | Some v when Float.(v > 0.) -> "var(--chart-1)"
                             | _ -> "var(--chart-2)")))
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:"chart-bar"
    ~title:"Bar Charts"
    ~group:Charts
    ~order:2
    ~description:
      "Bar charts: grouped, stacked, horizontal, with labels, active bars, negative \
       values and an interactive one."
    [ Doc.example
        ~page
        "Bar Chart - Interactive"
        (Chart_data.frame ~wide:true interactive)
    ; Doc.example ~page "Bar Chart" (Chart_data.frame default)
    ; Doc.example ~page "Bar Chart - Horizontal" (Chart_data.frame horizontal)
    ; Doc.example ~page "Bar Chart - Multiple" (Chart_data.frame multiple)
    ; Doc.example ~page "Bar Chart - Stacked + Legend" (Chart_data.frame stacked)
    ; Doc.example ~page "Bar Chart - Label" (Chart_data.frame label)
    ; Doc.example ~page "Bar Chart - Custom Label" (Chart_data.frame label_custom)
    ; Doc.example ~page "Bar Chart - Mixed" (Chart_data.frame mixed)
    ; Doc.example ~page "Bar Chart - Active" (Chart_data.frame active)
    ; Doc.example ~page "Bar Chart - Negative" (Chart_data.frame negative)
    ]
;;
