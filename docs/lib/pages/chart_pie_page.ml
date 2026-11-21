open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "chart_pie"

(* The data, config and footer most of the examples share, as shadcn's do. *)
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
  [ "visitors", Chart.Config.item ~label:"Visitors" ()
  ; "chrome", Chart.Config.item ~label:"Chrome" ~color:"var(--chart-1)" ()
  ; "safari", Chart.Config.item ~label:"Safari" ~color:"var(--chart-2)" ()
  ; "firefox", Chart.Config.item ~label:"Firefox" ~color:"var(--chart-3)" ()
  ; "edge", Chart.Config.item ~label:"Edge" ~color:"var(--chart-4)" ()
  ; "other", Chart.Config.item ~label:"Other" ~color:"var(--chart-5)" ()
  ]
;;

let month_config : Chart.Config.t =
  [ "visitors", Chart.Config.item ~label:"Visitors" ()
  ; "desktop", Chart.Config.item ~label:"Desktop" ()
  ; "mobile", Chart.Config.item ~label:"Mobile" ()
  ; "january", Chart.Config.item ~label:"January" ~color:"var(--chart-1)" ()
  ; "february", Chart.Config.item ~label:"February" ~color:"var(--chart-2)" ()
  ; "march", Chart.Config.item ~label:"March" ~color:"var(--chart-3)" ()
  ; "april", Chart.Config.item ~label:"April" ~color:"var(--chart-4)" ()
  ; "may", Chart.Config.item ~label:"May" ~color:"var(--chart-5)" ()
  ]
;;

let month_data key values =
  List.map
    (List.zip_exn [ "january"; "february"; "march"; "april"; "may" ] values)
    ~f:(fun (month, v) ->
      [ "month", `Text month; key, `Num v; "fill", `Text ("var(--color-" ^ month ^ ")") ])
;;

let desktop_data = month_data "desktop" [ 186.; 305.; 237.; 173.; 209. ]
let mobile_data = month_data "mobile" [ 80.; 200.; 120.; 190.; 130. ]

let header ~title =
  Card.header
    ~class_:"items-center pb-0"
    [ Card.title [ Node.text title ]; Card.description [ Node.text "January - June 2024" ] ]
;;

let footer =
  Card.footer
    ~class_:"flex-col gap-2 text-sm"
    [ Node.div
        ~attrs:[ Attr.class_ "flex items-center gap-2 leading-none font-medium" ]
        [ Node.text "Trending up by 5.2% this month "
        ; Icon.view ~class_:"h-4 w-4" Trending_up
        ]
    ; Node.div
        ~attrs:[ Attr.class_ "leading-none text-muted-foreground" ]
        [ Node.text "Showing total visitors for the last 6 months" ]
    ]
;;

(* The centre text of the donut examples: a number over "Visitors". *)
let centre_text value (vb : Chart.Polar_view_box.t) =
  let svg = Node.create_svg in
  let f = sprintf "%g" in
  svg
    "text"
    ~attrs:
      [ Attr.create "x" (f vb.cx)
      ; Attr.create "y" (f vb.cy)
      ; Attr.create "text-anchor" "middle"
      ; Attr.create "dominant-baseline" "middle"
      ]
    [ svg
        "tspan"
        ~attrs:
          [ Attr.create "x" (f vb.cx)
          ; Attr.create "y" (f vb.cy)
          ; Attr.class_ "fill-foreground text-3xl font-bold"
          ]
        [ Node.text value ]
    ; svg
        "tspan"
        ~attrs:
          [ Attr.create "x" (f vb.cx)
          ; Attr.create "y" (f (vb.cy +. 24.))
          ; Attr.class_ "fill-muted-foreground"
          ]
        [ Node.text "Visitors" ]
    ]
;;

(*$ Pie Chart - Interactive
    An interactive pie chart. *)
let interactive (local_ graph) =
  let id = "pie-interactive" in
  let select =
    Select.component
      ~default_value:"january"
      (Bonsai.return
         (Select.trigger
            ~attrs:[ Attr.create "aria-label" "Select a value" ]
            ~class_:"ml-auto h-7 w-[130px] rounded-lg pl-2.5"
            ~placeholder:"Select month"
            ()))
      (Bonsai.return
         (Select.content
            ~align:End
            ~class_:"rounded-xl"
            (List.map
               [ "january", "January"
               ; "february", "February"
               ; "march", "March"
               ; "april", "April"
               ; "may", "May"
               ]
               ~f:(fun (key, label) ->
                 Select.item
                   ~class_:"rounded-lg [&_span]:flex"
                   ~text_value:label
                   ~value:key
                   [ Node.div
                       ~attrs:[ Attr.class_ "flex items-center gap-2 text-xs" ]
                       [ Node.span
                           ~attrs:
                             [ Attr.class_ "flex h-3 w-3 shrink-0 rounded-xs"
                             ; Attr.style
                                 (Css_gen.background_color
                                    (`Var ("--color-" ^ key)))
                             ]
                           []
                       ; Node.text label
                       ]
                   ]))))
      graph
  in
  let chart = Chart.component graph in
  let%arr active_month, select = select
  and chart in
  let active_index =
    List.findi desktop_data ~f:(fun _ row ->
      Option.equal String.equal (Chart.Row.text row "month") active_month)
    |> Option.value_map ~default:0 ~f:fst
  in
  let active_shape (props : Chart.Sector_props.t) =
    Node.create_svg
      "g"
      [ Chart.sector { props with outer_radius = props.outer_radius +. 10. }
      ; Chart.sector
          { props with
            outer_radius = props.outer_radius +. 25.
          ; inner_radius = props.outer_radius +. 12.
          }
      ]
  in
  let active_value =
    Option.value
      (Chart.Row.num (List.nth_exn desktop_data active_index) "desktop")
      ~default:0.
  in
  Card.root
    ~attrs:[ Attr.create "data-chart" id ]
    ~class_:"flex flex-col"
    [ Card.header
        ~class_:"flex-row items-start space-y-0 pb-0"
        [ Node.div
            ~attrs:[ Attr.class_ "grid gap-1" ]
            [ Card.title [ Node.text "Pie Chart - Interactive" ]
            ; Card.description [ Node.text "January - June 2024" ]
            ]
        ; select
        ]
    ; Card.content
        ~class_:"flex flex-1 justify-center pb-0"
        [ Chart.container
            ~id
            ~config:month_config
            ~class_:"mx-auto aspect-square w-full max-w-[300px]"
            chart
            (Chart.pie_chart
               [ Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.pie
                   ~data:desktop_data
                   ~data_key:"desktop"
                   ~name_key:"month"
                   ~inner_radius:60.
                   ~stroke_width:5.
                   ~active_index
                   ~active_shape
                   ~children:
                     [ Chart.label
                         ~content:(centre_text (Chart.to_locale_string active_value))
                         ()
                     ]
                   ()
               ])
        ]
    ]
;;

(*$*)

(*$ Pie Chart
    A simple pie chart. *)
let simple (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    ~class_:"flex flex-col"
    [ header ~title:"Pie Chart"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:browser_config
            ~class_:"mx-auto aspect-square max-h-[250px]"
            chart
            (Chart.pie_chart
               [ Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.pie ~data:browser_data ~data_key:"visitors" ~name_key:"browser" ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Pie Chart - Separator None
    A pie chart with no separator. *)
let separator_none (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    ~class_:"flex flex-col"
    [ header ~title:"Pie Chart - Separator None"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:browser_config
            ~class_:"mx-auto aspect-square max-h-[250px]"
            chart
            (Chart.pie_chart
               [ Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.pie
                   ~data:browser_data
                   ~data_key:"visitors"
                   ~name_key:"browser"
                   ~stroke:"0"
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Pie Chart - Label
    A pie chart with a label. *)
let label (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    ~class_:"flex flex-col"
    [ header ~title:"Pie Chart - Label"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:browser_config
            ~class_:
              "mx-auto aspect-square max-h-[250px] pb-0 \
               [&_.recharts-pie-label-text]:fill-foreground"
            chart
            (Chart.pie_chart
               [ Chart.tooltip ~content:(Chart.tooltip_content ~hide_label:true ()) ()
               ; Chart.pie
                   ~data:browser_data
                   ~data_key:"visitors"
                   ~label:`Show
                   ~name_key:"browser"
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Pie Chart - Custom Label
    A pie chart with a custom label. *)
let label_custom (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let custom_label (props : Chart.Pie_label_props.t) =
    let f = sprintf "%g" in
    Node.create_svg
      "text"
      ~attrs:
        [ Attr.create "cx" (f props.cx)
        ; Attr.create "cy" (f props.cy)
        ; Attr.create "x" (f props.x)
        ; Attr.create "y" (f props.y)
        ; Attr.create "text-anchor" props.text_anchor
        ; Attr.create "dominant-baseline" "central"
        ; Attr.create "fill" "var(--foreground)"
        ]
      [ Node.text
          (Option.value_map
             (Chart.Row.find props.row "visitors")
             ~default:""
             ~f:Chart.Value.to_string)
      ]
  in
  Card.root
    ~class_:"flex flex-col"
    [ header ~title:"Pie Chart - Custom Label"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:browser_config
            ~class_:"mx-auto aspect-square max-h-[250px] px-0"
            chart
            (Chart.pie_chart
               [ Chart.tooltip
                   ~content:(Chart.tooltip_content ~name_key:"visitors" ~hide_label:true ())
                   ()
               ; Chart.pie
                   ~data:browser_data
                   ~data_key:"visitors"
                   ~label_line:false
                   ~label:(`Custom custom_label)
                   ~name_key:"browser"
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Pie Chart - Label List
    A pie chart with a label list. *)
let label_list (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    ~class_:"flex flex-col"
    [ header ~title:"Pie Chart - Label List"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:browser_config
            ~class_:"mx-auto aspect-square max-h-[250px] [&_.recharts-text]:fill-background"
            chart
            (Chart.pie_chart
               [ Chart.tooltip
                   ~content:(Chart.tooltip_content ~name_key:"visitors" ~hide_label:true ())
                   ()
               ; Chart.pie
                   ~data:browser_data
                   ~data_key:"visitors"
                   ~children:
                     [ Chart.label_list
                         ~data_key:"browser"
                         ~class_:"fill-background"
                         ~stroke:"none"
                         ~font_size:12.
                         ~formatter:(fun value ->
                           List.Assoc.find browser_config ~equal:String.equal value
                           |> Option.bind ~f:(fun (c : Chart.Config.item) -> c.label)
                           |> Option.value ~default:"")
                         ()
                     ]
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Pie Chart - Legend
    A pie chart with a legend. *)
let legend (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    ~class_:"flex flex-col"
    [ header ~title:"Pie Chart - Legend"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:browser_config
            ~class_:"mx-auto aspect-square max-h-[300px]"
            chart
            (Chart.pie_chart
               [ Chart.pie ~data:browser_data ~data_key:"visitors" ()
               ; Chart.legend
                   ~content:(Chart.legend_content ~name_key:"browser" ())
                   ~class_:"-translate-y-2 flex-wrap gap-2 *:basis-1/4 *:justify-center"
                   ()
               ])
        ]
    ]
;;

(*$*)

(*$ Pie Chart - Donut
    A donut chart. *)
let donut (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    ~class_:"flex flex-col"
    [ header ~title:"Pie Chart - Donut"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:browser_config
            ~class_:"mx-auto aspect-square max-h-[250px]"
            chart
            (Chart.pie_chart
               [ Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.pie
                   ~data:browser_data
                   ~data_key:"visitors"
                   ~name_key:"browser"
                   ~inner_radius:60.
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Pie Chart - Donut Active
    A donut chart with an active sector. *)
let donut_active (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    ~class_:"flex flex-col"
    [ header ~title:"Pie Chart - Donut Active"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:browser_config
            ~class_:"mx-auto aspect-square max-h-[250px]"
            chart
            (Chart.pie_chart
               [ Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.pie
                   ~data:browser_data
                   ~data_key:"visitors"
                   ~name_key:"browser"
                   ~inner_radius:60.
                   ~stroke_width:5.
                   ~active_index:0
                   ~active_shape:(fun props ->
                     Chart.sector { props with outer_radius = props.outer_radius +. 10. })
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Pie Chart - Donut with Text
    A donut chart with text. *)
let donut_text (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let data =
    List.map
      [ "chrome", 275.; "safari", 200.; "firefox", 287.; "edge", 173.; "other", 190. ]
      ~f:(fun (browser, visitors) ->
        [ "browser", `Text browser
        ; "visitors", `Num visitors
        ; "fill", `Text ("var(--color-" ^ browser ^ ")")
        ])
  in
  let total_visitors =
    List.sum (module Float) data ~f:(fun row ->
      Option.value (Chart.Row.num row "visitors") ~default:0.)
  in
  Card.root
    ~class_:"flex flex-col"
    [ header ~title:"Pie Chart - Donut with Text"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:browser_config
            ~class_:"mx-auto aspect-square max-h-[250px]"
            chart
            (Chart.pie_chart
               [ Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.pie
                   ~data
                   ~data_key:"visitors"
                   ~name_key:"browser"
                   ~inner_radius:60.
                   ~stroke_width:5.
                   ~children:
                     [ Chart.label
                         ~content:(centre_text (Chart.to_locale_string total_visitors))
                         ()
                     ]
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Pie Chart - Stacked
    A pie chart with stacked sections. *)
let stacked (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    ~class_:"flex flex-col"
    [ header ~title:"Pie Chart - Stacked"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:month_config
            ~class_:"mx-auto aspect-square max-h-[250px]"
            chart
            (Chart.pie_chart
               [ Chart.tooltip
                   ~content:
                     (Chart.tooltip_content
                        ~label_key:"visitors"
                        ~name_key:"month"
                        ~indicator:Line
                        ~label_formatter:(fun _ payload ->
                          match payload with
                          | item :: _ ->
                            (match
                               List.Assoc.find month_config ~equal:String.equal item.data_key
                             with
                             | Some { label = Some label; _ } -> [ Node.text label ]
                             | _ -> [])
                          | [] -> [])
                        ())
                   ()
               ; Chart.pie ~data:desktop_data ~data_key:"desktop" ~outer_radius:60. ()
               ; Chart.pie
                   ~data:mobile_data
                   ~data_key:"mobile"
                   ~inner_radius:70.
                   ~outer_radius:90.
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:"chart-pie"
    ~title:"Pie Charts"
    ~section:Charts
    ~order:4
    ~description:"Pie and donut charts: labels, legends, centre text, active sectors and stacked rings."
    [ Doc.example ~page "Pie Chart - Interactive" (Chart_data.frame ~wide:true interactive)
    ; Doc.example ~page "Pie Chart" (Chart_data.frame simple)
    ; Doc.example ~page "Pie Chart - Separator None" (Chart_data.frame separator_none)
    ; Doc.example ~page "Pie Chart - Label" (Chart_data.frame label)
    ; Doc.example ~page "Pie Chart - Custom Label" (Chart_data.frame label_custom)
    ; Doc.example ~page "Pie Chart - Label List" (Chart_data.frame label_list)
    ; Doc.example ~page "Pie Chart - Legend" (Chart_data.frame legend)
    ; Doc.example ~page "Pie Chart - Donut" (Chart_data.frame donut)
    ; Doc.example ~page "Pie Chart - Donut Active" (Chart_data.frame donut_active)
    ; Doc.example ~page "Pie Chart - Donut with Text" (Chart_data.frame donut_text)
    ; Doc.example ~page "Pie Chart - Stacked" (Chart_data.frame stacked)
    ]
;;
