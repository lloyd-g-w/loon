open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "chart_radial"

(* The data, config and footer most of the examples share, as shadcn's do. *)
let browser_data =
  List.map
    [ "chrome", 275.; "safari", 200.; "firefox", 187.; "edge", 173.; "other", 90. ]
    ~f:(fun (browser, visitors) ->
      [ "browser", `Text browser
      ; "visitors", `Num visitors
      ; "fill", `Text (sprintf "var(--color-%s)" browser)
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

let safari_config : Chart.Config.t =
  [ "visitors", Chart.Config.item ~label:"Visitors" ()
  ; "safari", Chart.Config.item ~label:"Safari" ~color:"var(--chart-2)" ()
  ]
;;

let header title =
  Card.header
    ~class_:"items-center pb-0"
    [ Card.title [ Node.text title ]
    ; Card.description [ Node.text "January - June 2024" ]
    ]
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

(* The centre text of the Text and Shape examples. *)
let centre_text value (vb : Chart.Polar_view_box.t) =
  let svg = Node.create_svg in
  let n = Chart.to_locale_string in
  svg
    "text"
    ~attrs:
      [ Attr.create_float "x" vb.cx
      ; Attr.create_float "y" vb.cy
      ; Attr.create "text-anchor" "middle"
      ; Attr.create "dominant-baseline" "middle"
      ]
    [ svg
        "tspan"
        ~attrs:
          [ Attr.create_float "x" vb.cx
          ; Attr.create_float "y" vb.cy
          ; Attr.class_ "fill-foreground text-4xl font-bold"
          ]
        [ Node.text (n value) ]
    ; svg
        "tspan"
        ~attrs:
          [ Attr.create_float "x" vb.cx
          ; Attr.create_float "y" (vb.cy +. 24.)
          ; Attr.class_ "fill-muted-foreground"
          ]
        [ Node.text "Visitors" ]
    ]
;;

(*$ Radial Chart
    A radial chart. *)
let simple (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    ~class_:"flex flex-col"
    [ header "Radial Chart"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:browser_config
            ~class_:"mx-auto aspect-square max-h-[250px]"
            chart
            (Chart.radial_bar_chart
               ~data:browser_data
               ~inner_radius:30.
               ~outer_radius:110.
               [ Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ~name_key:"browser" ())
                   ()
               ; Chart.radial_bar ~data_key:"visitors" ~background:true ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Radial Chart - Label
    A radial chart with a label. *)
let label (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    ~class_:"flex flex-col"
    [ header "Radial Chart - Label"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:browser_config
            ~class_:"mx-auto aspect-square max-h-[250px]"
            chart
            (Chart.radial_bar_chart
               ~data:browser_data
               ~start_angle:(-90.)
               ~end_angle:380.
               ~inner_radius:30.
               ~outer_radius:110.
               [ Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ~name_key:"browser" ())
                   ()
               ; Chart.radial_bar
                   ~data_key:"visitors"
                   ~background:true
                   ~children:
                     [ Chart.label_list
                         ~position:Inside_start
                         ~data_key:"browser"
                         ~class_:"fill-white capitalize mix-blend-luminosity"
                         ~font_size:11.
                         ()
                     ]
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Radial Chart - Grid
    A radial chart with a grid. *)
let grid (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    ~class_:"flex flex-col"
    [ header "Radial Chart - Grid"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:browser_config
            ~class_:"mx-auto aspect-square max-h-[250px]"
            chart
            (Chart.radial_bar_chart
               ~data:browser_data
               ~inner_radius:30.
               ~outer_radius:100.
               [ Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ~name_key:"browser" ())
                   ()
               ; Chart.polar_grid ~grid_type:`Circle ()
               ; Chart.radial_bar ~data_key:"visitors" ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Radial Chart - Text
    A radial chart with text. *)
let text (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let data =
    [ [ "browser", `Text "safari"; "visitors", `Num 200.; "fill", `Text "var(--color-safari)" ]
    ]
  in
  Card.root
    ~class_:"flex flex-col"
    [ header "Radial Chart - Text"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:safari_config
            ~class_:"mx-auto aspect-square max-h-[250px]"
            chart
            (Chart.radial_bar_chart
               ~data
               ~start_angle:0.
               ~end_angle:250.
               ~outer_radius:90.
               ~inner_radius:80.
               [ Chart.polar_grid
                   ~grid_type:`Circle
                   ~radial_lines:false
                   ~stroke:"none"
                   ~class_:"first:fill-muted last:fill-background"
                   ~polar_radius:[ 90.; 80. ]
                   ()
               ; Chart.radial_bar ~data_key:"visitors" ~background:true ~corner_radius:10. ()
               ; Chart.polar_radius_axis
                   ~tick:false
                   ~tick_line:false
                   ~axis_line:false
                   ~children:[ Chart.label ~content:(centre_text 200.) () ]
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Radial Chart - Shape
    A radial chart with a custom shape. *)
let shape (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let data =
    [ [ "browser", `Text "safari"; "visitors", `Num 1260.; "fill", `Text "var(--color-safari)" ]
    ]
  in
  Card.root
    ~class_:"flex flex-col"
    [ header "Radial Chart - Shape"
    ; Card.content
        ~class_:"flex-1 pb-0"
        [ Chart.container
            ~config:safari_config
            ~class_:"mx-auto aspect-square max-h-[250px]"
            chart
            (Chart.radial_bar_chart
               ~data
               ~end_angle:100.
               ~inner_radius:65.
               ~outer_radius:95.
               [ Chart.polar_grid
                   ~grid_type:`Circle
                   ~radial_lines:false
                   ~stroke:"none"
                   ~class_:"first:fill-muted last:fill-background"
                   ~polar_radius:[ 86.; 74. ]
                   ()
               ; Chart.radial_bar ~data_key:"visitors" ~background:true ()
               ; Chart.polar_radius_axis
                   ~tick:false
                   ~tick_line:false
                   ~axis_line:false
                   ~children:[ Chart.label ~content:(centre_text 1260.) () ]
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

(*$ Radial Chart - Stacked
    A radial chart with stacked sections. *)
let stacked (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let desktop = 1260.
  and mobile = 570. in
  let data = [ [ "month", `Text "january"; "mobile", `Num mobile; "desktop", `Num desktop ] ] in
  let config : Chart.Config.t =
    [ "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--chart-1)" ()
    ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"var(--chart-2)" ()
    ]
  in
  let total_visitors = desktop +. mobile in
  let centre (vb : Chart.Polar_view_box.t) =
    let svg = Node.create_svg in
    svg
      "text"
      ~attrs:
        [ Attr.create_float "x" vb.cx
        ; Attr.create_float "y" vb.cy
        ; Attr.create "text-anchor" "middle"
        ]
      [ svg
          "tspan"
          ~attrs:
            [ Attr.create_float "x" vb.cx
            ; Attr.create_float "y" (vb.cy -. 16.)
            ; Attr.class_ "fill-foreground text-2xl font-bold"
            ]
          [ Node.text (Chart.to_locale_string total_visitors) ]
      ; svg
          "tspan"
          ~attrs:
            [ Attr.create_float "x" vb.cx
            ; Attr.create_float "y" (vb.cy +. 4.)
            ; Attr.class_ "fill-muted-foreground"
            ]
          [ Node.text "Visitors" ]
      ]
  in
  Card.root
    ~class_:"flex flex-col"
    [ header "Radial Chart - Stacked"
    ; Card.content
        ~class_:"flex flex-1 items-center pb-0"
        [ Chart.container
            ~config
            ~class_:"mx-auto aspect-square w-full max-w-[250px]"
            chart
            (Chart.radial_bar_chart
               ~data
               ~end_angle:180.
               ~inner_radius:80.
               ~outer_radius:110.
               [ Chart.radial_bar
                   ~data_key:"mobile"
                   ~fill:"var(--color-mobile)"
                   ~stack_id:"a"
                   ~corner_radius:5.
                   ~class_:"stroke-transparent stroke-2"
                   ()
               ; Chart.radial_bar
                   ~data_key:"desktop"
                   ~stack_id:"a"
                   ~corner_radius:5.
                   ~fill:"var(--color-desktop)"
                   ~class_:"stroke-transparent stroke-2"
                   ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.polar_radius_axis
                   ~tick:false
                   ~tick_line:false
                   ~axis_line:false
                   ~children:[ Chart.label ~content:centre () ]
                   ()
               ])
        ]
    ; footer
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:"chart-radial"
    ~title:"Radial Charts"
    ~section:Charts
    ~order:6
    ~description:"Radial bar charts: labels, grids, centre text, custom shapes and stacking."
    [ Doc.example ~page "Radial Chart" (Chart_data.frame simple)
    ; Doc.example ~page "Radial Chart - Label" (Chart_data.frame label)
    ; Doc.example ~page "Radial Chart - Grid" (Chart_data.frame grid)
    ; Doc.example ~page "Radial Chart - Text" (Chart_data.frame text)
    ; Doc.example ~page "Radial Chart - Shape" (Chart_data.frame shape)
    ; Doc.example ~page "Radial Chart - Stacked" (Chart_data.frame stacked)
    ]
;;
