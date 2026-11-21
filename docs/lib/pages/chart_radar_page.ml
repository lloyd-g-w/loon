open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "chart_radar"

(* The data, configs and footer the examples share, as shadcn's do. *)
let months = [ "January"; "February"; "March"; "April"; "May"; "June" ]

let desktop_data values =
  List.map (List.zip_exn months values) ~f:(fun (month, desktop) ->
    [ "month", `Text month; "desktop", `Num desktop ])
;;

let both_data values =
  List.map (List.zip_exn months values) ~f:(fun (month, (desktop, mobile)) ->
    [ "month", `Text month; "desktop", `Num desktop; "mobile", `Num mobile ])
;;

let chart_data = desktop_data [ 186.; 305.; 237.; 273.; 209.; 214. ]

let multiple_data =
  both_data [ 186., 80.; 305., 200.; 237., 120.; 73., 190.; 209., 130.; 214., 140. ]
;;

let desktop_config : Chart.Config.t =
  [ "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--chart-1)" () ]
;;

let chart_config : Chart.Config.t =
  [ "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--chart-1)" ()
  ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"var(--chart-2)" ()
  ]
;;

let header ?(class_ = "items-center pb-4") ~title () =
  Card.header
    ~class_
    [ Card.title [ Node.text title ]
    ; Card.description [ Node.text "Showing total visitors for the last 6 months" ]
    ]
;;

let footer ?(class_ = "flex-col gap-2 text-sm") () =
  Card.footer
    ~class_
    [ Node.div
        ~attrs:[ Attr.class_ "flex items-center gap-2 leading-none font-medium" ]
        [ Node.text "Trending up by 5.2% this month "
        ; Icon.view ~class_:"h-4 w-4" Trending_up
        ]
    ; Node.div
        ~attrs:[ Attr.class_ "flex items-center gap-2 leading-none text-muted-foreground" ]
        [ Node.text "January - June 2024" ]
    ]
;;

(* Every example's card: a header, the chart and the footer. *)
let card ?header_class ?(content_class = "pb-0") ?footer_class ~title ~config chart spec =
  Card.root
    [ header ?class_:header_class ~title ()
    ; Card.content
        ~class_:content_class
        [ Chart.container
            ~config
            ~class_:"mx-auto aspect-square max-h-[250px]"
            chart
            spec
        ]
    ; footer ?class_:footer_class ()
    ]
;;

(*$ Radar Chart
    A radar chart. *)
let default (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Radar Chart"
    ~config:desktop_config
    chart
    (Chart.radar_chart
       ~data:chart_data
       [ Chart.tooltip ~cursor:false ~content:(Chart.tooltip_content ()) ()
       ; Chart.polar_angle_axis ~data_key:"month" ()
       ; Chart.polar_grid ()
       ; Chart.radar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~fill_opacity:0.6 ()
       ])
;;

(*$*)

(*$ Radar Chart - Dots
    A radar chart with dots. *)
let with_dots (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~header_class:"items-center"
    ~title:"Radar Chart - Dots"
    ~config:desktop_config
    chart
    (Chart.radar_chart
       ~data:chart_data
       [ Chart.tooltip ~cursor:false ~content:(Chart.tooltip_content ()) ()
       ; Chart.polar_angle_axis ~data_key:"month" ()
       ; Chart.polar_grid ()
       ; Chart.radar
           ~data_key:"desktop"
           ~fill:"var(--color-desktop)"
           ~fill_opacity:0.6
           ~dot:(Chart.Dot.style ~r:4. ~fill_opacity:1. ())
           ()
       ])
;;

(*$*)

(*$ Radar Chart - Lines Only
    A radar chart with lines only. *)
let lines_only (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Radar Chart - Lines Only"
    ~config:chart_config
    chart
    (Chart.radar_chart
       ~data:
         (both_data
            [ 186., 160.; 185., 170.; 207., 180.; 173., 160.; 160., 190.; 174., 204. ])
       [ Chart.tooltip ~cursor:false ~content:(Chart.tooltip_content ~indicator:Line ()) ()
       ; Chart.polar_angle_axis ~data_key:"month" ()
       ; Chart.polar_grid ~radial_lines:false ()
       ; Chart.radar
           ~data_key:"desktop"
           ~fill:"var(--color-desktop)"
           ~fill_opacity:0.
           ~stroke:"var(--color-desktop)"
           ~stroke_width:2.
           ()
       ; Chart.radar
           ~data_key:"mobile"
           ~fill:"var(--color-mobile)"
           ~fill_opacity:0.
           ~stroke:"var(--color-mobile)"
           ~stroke_width:2.
           ()
       ])
;;

(*$*)

(*$ Radar Chart - Custom Label
    A radar chart with a custom label. *)
let label_custom (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let tick (props : Chart.Tick_props.t) =
    let row = List.nth_exn multiple_data props.index in
    let field key =
      Option.value_map (Chart.Row.find row key) ~default:"" ~f:Chart.Value.to_string
    in
    let y = props.y +. if props.index = 0 then -10. else 0. in
    let svg = Node.create_svg in
    svg
      "text"
      ~attrs:
        [ Attr.create "x" (sprintf "%g" props.x)
        ; Attr.create "y" (sprintf "%g" y)
        ; Attr.create "text-anchor" props.text_anchor
        ; Attr.create "font-size" "13"
        ; Attr.create "font-weight" "500"
        ; Attr.create "fill" "#808080"
        ]
      [ svg "tspan" [ Node.text (field "desktop") ]
      ; svg "tspan" ~attrs:[ Attr.class_ "fill-muted-foreground" ] [ Node.text "/" ]
      ; svg "tspan" [ Node.text (field "mobile") ]
      ; svg
          "tspan"
          ~attrs:
            [ Attr.create "x" (sprintf "%g" props.x)
            ; Attr.create "dy" "1rem"
            ; Attr.create "font-size" "12"
            ; Attr.class_ "fill-muted-foreground"
            ]
          [ Node.text (field "month") ]
      ]
  in
  card
    ~title:"Radar Chart - Custom Label"
    ~config:chart_config
    chart
    (Chart.radar_chart
       ~data:multiple_data
       ~margin:(Chart.margin ~top:10. ~right:10. ~bottom:10. ~left:10. ())
       [ Chart.tooltip ~cursor:false ~content:(Chart.tooltip_content ~indicator:Line ()) ()
       ; Chart.polar_angle_axis ~data_key:"month" ~tick:(`Custom tick) ()
       ; Chart.polar_grid ()
       ; Chart.radar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~fill_opacity:0.6 ()
       ; Chart.radar ~data_key:"mobile" ~fill:"var(--color-mobile)" ()
       ])
;;

(*$*)

(*$ Radar Chart - Grid Custom
    A radar chart with a custom grid. *)
let grid_custom (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Radar Chart - Grid Custom"
    ~config:desktop_config
    chart
    (Chart.radar_chart
       ~data:chart_data
       [ Chart.tooltip
           ~cursor:false
           ~content:(Chart.tooltip_content ~hide_label:true ())
           ()
       ; Chart.polar_grid ~radial_lines:false ~polar_radius:[ 90. ] ~stroke_width:1. ()
       ; Chart.polar_angle_axis ~data_key:"month" ()
       ; Chart.radar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~fill_opacity:0.6 ()
       ])
;;

(*$*)

(*$ Radar Chart - Grid None
    A radar chart with no grid. *)
let grid_none (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Radar Chart - Grid None"
    ~config:desktop_config
    chart
    (Chart.radar_chart
       ~data:chart_data
       [ Chart.tooltip
           ~cursor:false
           ~content:(Chart.tooltip_content ~hide_label:true ())
           ()
       ; Chart.polar_angle_axis ~data_key:"month" ()
       ; Chart.radar
           ~data_key:"desktop"
           ~fill:"var(--color-desktop)"
           ~fill_opacity:0.6
           ~dot:(Chart.Dot.style ~r:4. ~fill_opacity:1. ())
           ()
       ])
;;

(*$*)

(*$ Radar Chart - Grid Circle
    A radar chart with a grid and circle. *)
let grid_circle (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Radar Chart - Grid Circle"
    ~config:desktop_config
    chart
    (Chart.radar_chart
       ~data:chart_data
       [ Chart.tooltip
           ~cursor:false
           ~content:(Chart.tooltip_content ~hide_label:true ())
           ()
       ; Chart.polar_grid ~grid_type:`Circle ()
       ; Chart.polar_angle_axis ~data_key:"month" ()
       ; Chart.radar
           ~data_key:"desktop"
           ~fill:"var(--color-desktop)"
           ~fill_opacity:0.6
           ~dot:(Chart.Dot.style ~r:4. ~fill_opacity:1. ())
           ()
       ])
;;

(*$*)

(*$ Radar Chart - Grid Circle - No lines
    A radar chart with a grid and circle fill. *)
let grid_circle_no_lines (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Radar Chart - Grid Circle - No lines"
    ~config:desktop_config
    chart
    (Chart.radar_chart
       ~data:(desktop_data [ 186.; 305.; 237.; 203.; 209.; 214. ])
       [ Chart.tooltip
           ~cursor:false
           ~content:(Chart.tooltip_content ~hide_label:true ())
           ()
       ; Chart.polar_grid ~grid_type:`Circle ~radial_lines:false ()
       ; Chart.polar_angle_axis ~data_key:"month" ()
       ; Chart.radar
           ~data_key:"desktop"
           ~fill:"var(--color-desktop)"
           ~fill_opacity:0.6
           ~dot:(Chart.Dot.style ~r:4. ~fill_opacity:1. ())
           ()
       ])
;;

(*$*)

(*$ Radar Chart - Grid Circle Filled
    A radar chart with a grid and circle fill. *)
let grid_circle_fill (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Radar Chart - Grid Circle Filled"
    ~config:desktop_config
    chart
    (Chart.radar_chart
       ~data:(desktop_data [ 186.; 285.; 237.; 203.; 209.; 264. ])
       [ Chart.tooltip ~cursor:false ~content:(Chart.tooltip_content ()) ()
       ; Chart.polar_grid ~class_:"fill-(--color-desktop) opacity-20" ~grid_type:`Circle ()
       ; Chart.polar_angle_axis ~data_key:"month" ()
       ; Chart.radar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~fill_opacity:0.5 ()
       ])
;;

(*$*)

(*$ Radar Chart - Grid Filled
    A radar chart with a grid filled. *)
let grid_fill (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Radar Chart - Grid Filled"
    ~config:desktop_config
    chart
    (Chart.radar_chart
       ~data:(desktop_data [ 186.; 285.; 237.; 203.; 209.; 264. ])
       [ Chart.tooltip
           ~cursor:false
           ~content:(Chart.tooltip_content ~hide_label:true ())
           ()
       ; Chart.polar_grid ~class_:"fill-(--color-desktop) opacity-20" ()
       ; Chart.polar_angle_axis ~data_key:"month" ()
       ; Chart.radar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~fill_opacity:0.5 ()
       ])
;;

(*$*)

(*$ Radar Chart - Multiple
    A radar chart with multiple data. *)
let multiple (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Radar Chart - Multiple"
    ~config:chart_config
    chart
    (Chart.radar_chart
       ~data:multiple_data
       [ Chart.tooltip ~cursor:false ~content:(Chart.tooltip_content ~indicator:Line ()) ()
       ; Chart.polar_angle_axis ~data_key:"month" ()
       ; Chart.polar_grid ()
       ; Chart.radar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~fill_opacity:0.6 ()
       ; Chart.radar ~data_key:"mobile" ~fill:"var(--color-mobile)" ()
       ])
;;

(*$*)

(*$ Radar Chart - Legend
    A radar chart with a legend. *)
let legend (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~header_class:"items-center"
    ~content_class:""
    ~footer_class:"flex-col gap-2 pt-4 text-sm"
    ~title:"Radar Chart - Legend"
    ~config:chart_config
    chart
    (Chart.radar_chart
       ~data:multiple_data
       ~margin:(Chart.margin ~top:(-40.) ~bottom:(-10.) ~left:0. ~right:0. ())
       [ Chart.tooltip ~cursor:false ~content:(Chart.tooltip_content ~indicator:Line ()) ()
       ; Chart.polar_angle_axis ~data_key:"month" ()
       ; Chart.polar_grid ()
       ; Chart.radar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~fill_opacity:0.6 ()
       ; Chart.radar ~data_key:"mobile" ~fill:"var(--color-mobile)" ()
       ; Chart.legend ~class_:"mt-8" ~content:(Chart.legend_content ()) ()
       ])
;;

(*$*)

(*$ Radar Chart - Icons
    A radar chart with icons. *)
let icons (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let config : Chart.Config.t =
    [ ( "desktop"
      , Chart.Config.item
          ~label:"Desktop"
          ~color:"var(--chart-1)"
          ~icon:(fun () -> Icon.view Arrow_down_from_line)
          () )
    ; ( "mobile"
      , Chart.Config.item
          ~label:"Mobile"
          ~color:"var(--chart-2)"
          ~icon:(fun () -> Icon.view Arrow_up_from_line)
          () )
    ]
  in
  card
    ~content_class:""
    ~footer_class:"flex-col gap-2 pt-4 text-sm"
    ~title:"Radar Chart - Icons"
    ~config
    chart
    (Chart.radar_chart
       ~data:multiple_data
       ~margin:(Chart.margin ~top:(-40.) ~bottom:(-10.) ~left:0. ~right:0. ())
       [ Chart.tooltip ~cursor:false ~content:(Chart.tooltip_content ~indicator:Line ()) ()
       ; Chart.polar_angle_axis ~data_key:"month" ()
       ; Chart.polar_grid ()
       ; Chart.radar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~fill_opacity:0.6 ()
       ; Chart.radar ~data_key:"mobile" ~fill:"var(--color-mobile)" ()
       ; Chart.legend ~class_:"mt-8" ~content:(Chart.legend_content ()) ()
       ])
;;

(*$*)

(*$ Radar Chart - Radius Axis
    A radar chart with a radius axis. *)
let radius (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  card
    ~title:"Radar Chart - Radius Axis"
    ~config:chart_config
    chart
    (Chart.radar_chart
       ~data:multiple_data
       [ Chart.tooltip
           ~cursor:false
           ~content:(Chart.tooltip_content ~indicator:Line ~label_key:"month" ())
           ()
       ; Chart.polar_grid ()
       ; Chart.radar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~fill_opacity:0.6 ()
       ; Chart.radar ~data_key:"mobile" ~fill:"var(--color-mobile)" ()
       ; Chart.polar_radius_axis
           ~angle:60.
           ~stroke:"var(--foreground)"
           ~orientation:`Middle
           ~axis_line:false
           ()
       ])
;;

(*$*)

let page =
  Doc.page
    ~slug:"chart-radar"
    ~title:"Radar Charts"
    ~group:Charts
    ~order:5
    ~description:"Radar charts: dots, lines, grids (polygon, circle, filled), legends and axes."
    [ Doc.example ~page "Radar Chart" (Chart_data.frame default)
    ; Doc.example ~page "Radar Chart - Dots" (Chart_data.frame with_dots)
    ; Doc.example ~page "Radar Chart - Lines Only" (Chart_data.frame lines_only)
    ; Doc.example ~page "Radar Chart - Custom Label" (Chart_data.frame label_custom)
    ; Doc.example ~page "Radar Chart - Grid Custom" (Chart_data.frame grid_custom)
    ; Doc.example ~page "Radar Chart - Grid None" (Chart_data.frame grid_none)
    ; Doc.example ~page "Radar Chart - Grid Circle" (Chart_data.frame grid_circle)
    ; Doc.example
        ~page
        "Radar Chart - Grid Circle - No lines"
        (Chart_data.frame grid_circle_no_lines)
    ; Doc.example ~page "Radar Chart - Grid Circle Filled" (Chart_data.frame grid_circle_fill)
    ; Doc.example ~page "Radar Chart - Grid Filled" (Chart_data.frame grid_fill)
    ; Doc.example ~page "Radar Chart - Multiple" (Chart_data.frame multiple)
    ; Doc.example ~page "Radar Chart - Legend" (Chart_data.frame legend)
    ; Doc.example ~page "Radar Chart - Icons" (Chart_data.frame icons)
    ; Doc.example ~page "Radar Chart - Radius Axis" (Chart_data.frame radius)
    ]
;;
