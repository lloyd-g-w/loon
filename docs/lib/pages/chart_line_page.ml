open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "chart_line"

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

let browser_data =
  List.map
    [ "chrome", 275.; "safari", 200.; "firefox", 187.; "edge", 173.; "other", 90. ]
    ~f:(fun (browser, visitors) ->
      [ "browser", `Text browser
      ; "visitors", `Num visitors
      ; "fill", `Text ("var(--color-" ^ browser ^ ")")
      ])
;;

let browser_config : Chart.Config.t =
  [ "visitors", Chart.Config.item ~label:"Visitors" ~color:"var(--chart-2)" ()
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
    ~axis_line:false
    ~tick_margin:8.
    ~tick_formatter:(fun value -> String.prefix value 3)
    ()
;;

(*$ Line Chart - Interactive
    An interactive line chart. *)
let interactive (local_ graph) =
  let active_chart, set_active_chart = Bonsai.state "desktop" graph in
  let chart = Chart.component graph in
  let%arr active_chart and set_active_chart and chart in
  let config : Chart.Config.t =
    [ "views", Chart.Config.item ~label:"Page Views" ()
    ; "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--chart-1)" ()
    ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"var(--chart-2)" ()
    ]
  in
  let total key =
    List.sum
      (module Float)
      Chart_data.visitors_by_day
      ~f:(fun row -> Option.value (Chart.Row.num row key) ~default:0.)
  in
  Card.root
    ~class_:"py-4 sm:py-0"
    [ Card.header
        ~class_:"flex flex-col items-stretch border-b p-0! sm:flex-row"
        [ Node.div
            ~attrs:
              [ Attr.class_ "flex flex-1 flex-col justify-center gap-1 px-6 pb-3 sm:pb-0" ]
            [ Card.title [ Node.text "Line Chart - Interactive" ]
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
                       "flex flex-1 flex-col justify-center gap-1 border-t px-6 py-4 \
                        text-left even:border-l data-[active=true]:bg-muted/50 \
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
            (Chart.line_chart
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
               ; Chart.line
                   ~data_key:active_chart
                   ~type_:Monotone
                   ~stroke:("var(--color-" ^ active_chart ^ ")")
                   ~stroke_width:2.
                   ~dot:Hide
                   ()
               ])
        ]
    ]
;;

(*$*)

(*$ Line Chart
    A line chart. *)
let default (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Line Chart"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.line_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.line
                   ~data_key:"desktop"
                   ~type_:Natural
                   ~stroke:"var(--color-desktop)"
                   ~stroke_width:2.
                   ~dot:Hide
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Line Chart - Linear
    A linear line chart. *)
let linear (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Line Chart - Linear"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.line_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.line
                   ~data_key:"desktop"
                   ~type_:Linear
                   ~stroke:"var(--color-desktop)"
                   ~stroke_width:2.
                   ~dot:Hide
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Line Chart - Step
    A line chart with step. *)
let step (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Line Chart - Step"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.line_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.line
                   ~data_key:"desktop"
                   ~type_:Step
                   ~stroke:"var(--color-desktop)"
                   ~stroke_width:2.
                   ~dot:Hide
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Line Chart - Multiple
    A multiple line chart. *)
let multiple (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Line Chart - Multiple"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.line_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip ~cursor:false ~content:(Chart.tooltip_content ()) ()
               ; Chart.line
                   ~data_key:"desktop"
                   ~type_:Monotone
                   ~stroke:"var(--color-desktop)"
                   ~stroke_width:2.
                   ~dot:Hide
                   ()
               ; Chart.line
                   ~data_key:"mobile"
                   ~type_:Monotone
                   ~stroke:"var(--color-mobile)"
                   ~stroke_width:2.
                   ~dot:Hide
                   ()
               ])
        ]
    ; Card.footer
        [ Node.div
            ~attrs:[ Attr.class_ "flex w-full items-start gap-2 text-sm" ]
            [ Node.div
                ~attrs:[ Attr.class_ "grid gap-2" ]
                [ Node.div
                    ~attrs:[ Attr.class_ "flex items-center gap-2 leading-none font-medium" ]
                    [ Node.text "Trending up by 5.2% this month "
                    ; Icon.view ~class_:"h-4 w-4" Trending_up
                    ]
                ; Node.div
                    ~attrs:
                      [ Attr.class_
                          "flex items-center gap-2 leading-none text-muted-foreground"
                      ]
                    [ Node.text "Showing total visitors for the last 6 months" ]
                ]
            ]
        ]
    ]
;;

(*$*)

(*$ Line Chart - Dots
    A line chart with dots. *)
let dots (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Line Chart - Dots"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.line_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.line
                   ~data_key:"desktop"
                   ~type_:Natural
                   ~stroke:"var(--color-desktop)"
                   ~stroke_width:2.
                   ~dot:(Chart.Dot.style ~fill:"var(--color-desktop)" ())
                   ~active_dot:(Chart.Dot.style ~r:6. ())
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Line Chart - Custom Dots
    A line chart with custom dots. *)
let dots_custom (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Line Chart - Custom Dots"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.line_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.line
                   ~data_key:"desktop"
                   ~type_:Natural
                   ~stroke:"var(--color-desktop)"
                   ~stroke_width:2.
                   ~dot:
                     (Custom
                        (fun { cx; cy; _ } ->
                          let r = 24. in
                          Icon.view
                            ~attrs:
                              [ Attr.create_float "x" (cx -. (r /. 2.))
                              ; Attr.create_float "y" (cy -. (r /. 2.))
                              ; Attr.style
                                  (Css_gen.concat
                                     [ Css_gen.create ~field:"fill" ~value:"hsl(var(--background))"
                                     ; Css_gen.create ~field:"stroke" ~value:"var(--color-desktop)"
                                     ])
                              ]
                            Git_commit_vertical))
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Line Chart - Dots Colors
    A line chart with dots and colors. *)
let dots_colors (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Line Chart - Dots Colors"
    ; Card.content
        [ Chart.container
            ~config:browser_config
            chart
            (Chart.line_chart
               ~data:browser_data
               ~margin:(Chart.margin ~top:24. ~left:24. ~right:24. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:
                     (Chart.tooltip_content
                        ~indicator:Line
                        ~name_key:"visitors"
                        ~hide_label:true
                        ())
                   ()
               ; Chart.line
                   ~data_key:"visitors"
                   ~type_:Natural
                   ~stroke:"var(--color-visitors)"
                   ~stroke_width:2.
                   ~dot:
                     (Custom
                        (fun props ->
                          let fill =
                            Option.value (Chart.Row.text props.row "fill") ~default:""
                          in
                          Chart.Dot.view { props with r = 5.; fill; stroke = fill }))
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Line Chart - Label
    A line chart with a label. *)
let label (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Line Chart - Label"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.line_chart
               ~data:chart_data
               ~margin:(Chart.margin ~top:20. ~left:12. ~right:12. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~indicator:Line ())
                   ()
               ; Chart.line
                   ~data_key:"desktop"
                   ~type_:Natural
                   ~stroke:"var(--color-desktop)"
                   ~stroke_width:2.
                   ~dot:(Chart.Dot.style ~fill:"var(--color-desktop)" ())
                   ~active_dot:(Chart.Dot.style ~r:6. ())
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

(*$ Line Chart - Custom Label
    A line chart with a custom label. *)
let label_custom (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Line Chart - Custom Label"
    ; Card.content
        [ Chart.container
            ~config:browser_config
            chart
            (Chart.line_chart
               ~data:browser_data
               ~margin:(Chart.margin ~top:24. ~left:24. ~right:24. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:
                     (Chart.tooltip_content
                        ~indicator:Line
                        ~name_key:"visitors"
                        ~hide_label:true
                        ())
                   ()
               ; Chart.line
                   ~data_key:"visitors"
                   ~type_:Natural
                   ~stroke:"var(--color-visitors)"
                   ~stroke_width:2.
                   ~dot:(Chart.Dot.style ~fill:"var(--color-visitors)" ())
                   ~active_dot:(Chart.Dot.style ~r:6. ())
                   ~children:
                     [ Chart.label_list
                         ~position:Top
                         ~offset:12.
                         ~class_:"fill-foreground"
                         ~font_size:12.
                         ~data_key:"browser"
                         ~formatter:(fun value -> config_label browser_config value)
                         ()
                     ]
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:"chart-line"
    ~title:"Line Charts"
    ~group:Charts
    ~order:3
    ~description:
      "Line charts: natural, linear and step curves, multiple lines, dots, labels and \
       an interactive one."
    [ Doc.example
        ~page
        "Line Chart - Interactive"
        (Chart_data.frame ~wide:true interactive)
    ; Doc.example ~page "Line Chart" (Chart_data.frame default)
    ; Doc.example ~page "Line Chart - Linear" (Chart_data.frame linear)
    ; Doc.example ~page "Line Chart - Step" (Chart_data.frame step)
    ; Doc.example ~page "Line Chart - Multiple" (Chart_data.frame multiple)
    ; Doc.example ~page "Line Chart - Dots" (Chart_data.frame dots)
    ; Doc.example ~page "Line Chart - Custom Dots" (Chart_data.frame dots_custom)
    ; Doc.example ~page "Line Chart - Dots Colors" (Chart_data.frame dots_colors)
    ; Doc.example ~page "Line Chart - Label" (Chart_data.frame label)
    ; Doc.example ~page "Line Chart - Custom Label" (Chart_data.frame label_custom)
    ]
;;
