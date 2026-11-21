open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "chart"

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
  [ "desktop", Chart.Config.item ~label:"Desktop" ~color:"#2563eb" ()
  ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"#60a5fa" ()
  ]
;;

(*$ Your First Chart
    A bar chart of the data, coloured by the chart config. Remember to set
    a [min-h-[VALUE]] (or a height or aspect ratio) on the container: the
    chart is drawn at the size it measures. *)
let first_chart (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Chart.container
    ~config:chart_config
    ~class_:"min-h-[200px] w-full"
    chart
    (Chart.bar_chart
       ~data:chart_data
       [ Chart.bar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~radius:(`All 4.) ()
       ; Chart.bar ~data_key:"mobile" ~fill:"var(--color-mobile)" ~radius:(`All 4.) ()
       ])
;;

(*$*)

(*$ Add a Grid
    [Chart.cartesian_grid] draws the grid behind the bars. *)
let grid (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Chart.container
    ~config:chart_config
    ~class_:"min-h-[200px] w-full"
    chart
    (Chart.bar_chart
       ~data:chart_data
       [ Chart.cartesian_grid ~vertical:false ()
       ; Chart.bar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~radius:(`All 4.) ()
       ; Chart.bar ~data_key:"mobile" ~fill:"var(--color-mobile)" ~radius:(`All 4.) ()
       ])
;;

(*$*)

(*$ Add an Axis
    [Chart.x_axis] labels the categories. *)
let axis (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Chart.container
    ~config:chart_config
    ~class_:"h-[200px] w-full"
    chart
    (Chart.bar_chart
       ~data:chart_data
       [ Chart.cartesian_grid ~vertical:false ()
       ; Chart.x_axis
           ~data_key:"month"
           ~tick_line:false
           ~tick_margin:10.
           ~axis_line:false
           ~tick_formatter:(fun value -> String.prefix value 3)
           ()
       ; Chart.bar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~radius:(`All 4.) ()
       ; Chart.bar ~data_key:"mobile" ~fill:"var(--color-mobile)" ~radius:(`All 4.) ()
       ])
;;

(*$*)

(*$ Add Tooltip
    [Chart.tooltip] with [Chart.tooltip_content]: hover to see the
    tooltips. *)
let tooltip (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Chart.container
    ~config:chart_config
    ~class_:"h-[200px] w-full"
    chart
    (Chart.bar_chart
       ~data:chart_data
       [ Chart.cartesian_grid ~vertical:false ()
       ; Chart.x_axis
           ~data_key:"month"
           ~tick_line:false
           ~tick_margin:10.
           ~axis_line:false
           ~tick_formatter:(fun value -> String.prefix value 3)
           ()
       ; Chart.tooltip ~content:(Chart.tooltip_content ()) ()
       ; Chart.bar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~radius:(`All 4.) ()
       ; Chart.bar ~data_key:"mobile" ~fill:"var(--color-mobile)" ~radius:(`All 4.) ()
       ])
;;

(*$*)

(*$ Add Legend
    [Chart.legend] with [Chart.legend_content]. *)
let legend (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Chart.container
    ~config:chart_config
    ~class_:"h-[200px] w-full"
    chart
    (Chart.bar_chart
       ~data:chart_data
       [ Chart.cartesian_grid ~vertical:false ()
       ; Chart.x_axis
           ~data_key:"month"
           ~tick_line:false
           ~tick_margin:10.
           ~axis_line:false
           ~tick_formatter:(fun value -> String.prefix value 3)
           ()
       ; Chart.tooltip ~content:(Chart.tooltip_content ()) ()
       ; Chart.legend ~content:(Chart.legend_content ()) ()
       ; Chart.bar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~radius:(`All 4.) ()
       ; Chart.bar ~data_key:"mobile" ~fill:"var(--color-mobile)" ~radius:(`All 4.) ()
       ])
;;

(*$*)

(*$ Tooltip
    A tooltip has a label, names, indicators and values: hide the label
    with [~hide_label:true], the indicator with [~hide_indicator:true], and
    choose the indicator's style with [~indicator]. *)
let tooltip_anatomy =
  let item name value fill : Chart.Item.t =
    { data_key = name; name; value = Some (`Num value); color = fill; row = [] }
  in
  let demo ?hide_label ?indicator ~class_ ~label payload =
    Chart.tooltip_content
      ?hide_label
      ?indicator
      ~class_
      ()
      ({ config = []; label = Some label; payload } : Chart.Tooltip_context.t)
  in
  let cell ?(class_ = "") children =
    Node.div ~attrs:[ Attr.class_ ("relative flex items-center justify-center p-4 " ^ class_) ] children
  in
  Node.div
    ~attrs:
      [ Attr.class_
          "grid w-full max-w-md justify-center gap-4 text-foreground md:grid-cols-2"
      ]
    [ cell
        [ demo
            ~class_:"w-[8rem]"
            ~label:"Page Views"
            [ item "Desktop" 186. "var(--chart-1)"; item "Mobile" 80. "var(--chart-2)" ]
        ]
    ; cell
        ~class_:"items-end"
        [ demo
            ~hide_label:true
            ~indicator:Dashed
            ~class_:"w-[8rem]"
            ~label:"Browser"
            [ item "Chrome" 1286. "var(--chart-3)"; item "Firefox" 1000. "var(--chart-4)" ]
        ]
    ; cell
        ~class_:"hidden! md:flex!"
        [ demo
            ~indicator:Line
            ~class_:"w-[9rem]"
            ~label:"Page Views"
            [ item "Desktop" 12486. "var(--chart-3)" ]
        ]
    ; cell
        ~class_:"items-start! justify-start!"
        [ demo
            ~hide_label:true
            ~indicator:Dot
            ~class_:"w-[8rem]"
            ~label:"Browser"
            [ item "Chrome" 1286. "var(--chart-1)" ]
        ]
    ]
;;

(*$*)

let body =
  [ Doc.h2 "Component"
  ; Doc.p
      "shadcn/ui's charts use Recharts; loon's draw the same SVG in OCaml, with the same \
       [recharts-*] classes, so shadcn's styling of them applies unchanged. A chart is a \
       [Chart.Spec.t] ([Chart.bar_chart], [Chart.area_chart], ...) of elements (series, \
       axes, grid, tooltip, legend), named after Recharts' components, drawn by \
       [Chart.container] (shadcn's [ChartContainer]). Bring in [Chart.tooltip_content] and \
       [Chart.legend_content] (shadcn's [ChartTooltipContent] and [ChartLegendContent]) where \
       you need them."
  ; Doc.pre
      {|let chart = Chart.component graph in
let%arr chart in
Chart.container ~config chart
  (Chart.bar_chart ~data
     [ Chart.bar ~data_key:"value" ()
     ; Chart.tooltip ~content:(Chart.tooltip_content ()) ()
     ])|}
  ; Doc.p
      "[Chart.component] keeps the chart's state in Bonsai: its size, measured by a \
       ResizeObserver (so give the container a height, [min-h-*] or [aspect-*]; it is \
       [aspect-video] by default), and the pointer, for the tooltip."
  ; Doc.h2 "Installation"
  ; Doc.pre ~lang:Shell "loon add chart"
  ; Doc.p
      "The chart colours are the theme's [--chart-1] to [--chart-5] variables. To use your \
       own, set them in your CSS:"
  ; Doc.pre
      ~lang:Css
      {|@layer base {
  :root {
    --chart-1: oklch(0.646 0.222 41.116);
    --chart-2: oklch(0.6 0.118 184.704);
    --chart-3: oklch(0.398 0.07 227.392);
    --chart-4: oklch(0.828 0.189 84.429);
    --chart-5: oklch(0.769 0.188 70.08);
  }

  .dark {
    --chart-1: oklch(0.488 0.243 264.376);
    --chart-2: oklch(0.696 0.17 162.48);
    --chart-3: oklch(0.769 0.188 70.08);
    --chart-4: oklch(0.627 0.265 303.9);
    --chart-5: oklch(0.645 0.246 16.439);
  }
}|}
  ; Doc.h2 "Your First Chart"
  ; Doc.p
      "The examples above build a bar chart step by step: the data, the chart config, the \
       chart, then a grid, an axis, a tooltip and a legend. The data can be in any shape: \
       rows of named fields, mapped to the chart by [~data_key]."
  ; Doc.pre
      {|let chart_data =
  [ [ "month", `Text "January"; "desktop", `Num 186.; "mobile", `Num 80. ]
  ; [ "month", `Text "February"; "desktop", `Num 305.; "mobile", `Num 200. ]
  ; ...
  ]|}
  ; Doc.h2 "Chart Config"
  ; Doc.p
      "The chart config is where you define the labels, icons and colours for a chart. It is \
       intentionally decoupled from chart data, so that charts can share config and colour \
       tokens, and it works when your data or colours live elsewhere or in a different format."
  ; Doc.pre
      {|let chart_config : Chart.Config.t =
  [ ( "desktop"
    , Chart.Config.item
        ~label:"Desktop"
        ~icon:(fun () -> Icon.view Monitor)
        (* A colour like "hsl(220, 98%, 61%)" or "var(--color-name)" *)
        ~color:"#2563eb"
        (* OR a colour per theme: ~theme:("#2563eb", "#dc2626") *)
        () )
  ]|}
  ; Doc.h2 "Theming"
  ; Doc.p
      "Charts have built-in support for theming. You can use CSS variables (recommended) or \
       colour values in any colour format, such as hex, hsl or oklch."
  ; Doc.h3 "CSS Variables"
  ; Doc.p "Define your colours in your CSS file (as above), then add them to the chart config:"
  ; Doc.pre
      {|let chart_config : Chart.Config.t =
  [ "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--chart-1)" ()
  ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"var(--chart-2)" ()
  ]|}
  ; Doc.h3 "hex, hsl or oklch"
  ; Doc.p "You can also define your colours directly in the chart config, in any format:"
  ; Doc.pre
      {|let chart_config : Chart.Config.t =
  [ "desktop", Chart.Config.item ~label:"Desktop" ~color:"#2563eb" ()
  ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"hsl(220, 98%, 61%)" ()
  ; "tablet", Chart.Config.item ~label:"Tablet" ~color:"oklch(0.5 0.2 240)" ()
  ; "laptop", Chart.Config.item ~label:"Laptop" ~color:"var(--chart-2)" ()
  ]|}
  ; Doc.h3 "Using Colors"
  ; Doc.p
      "The container sets each configured colour as the CSS variable [--color-KEY]: use it in \
       series, in your data and in Tailwind classes."
  ; Doc.pre {|Chart.bar ~data_key:"desktop" ~fill:"var(--color-desktop)" ()|}
  ; Doc.pre
      {|let chart_data =
  [ [ "browser", `Text "chrome"; "visitors", `Num 275.; "fill", `Text "var(--color-chrome)" ]
  ; [ "browser", `Text "safari"; "visitors", `Num 200.; "fill", `Text "var(--color-safari)" ]
  ]|}
  ; Doc.pre {|Chart.label_list ~class_:"fill-(--color-desktop)" ()|}
  ; Doc.h2 "Tooltip"
  ; Doc.p
      "A chart tooltip has a label, names, indicators and values (see the Tooltip example \
       above); turn them on and off with [~hide_label] and [~hide_indicator], and choose the \
       indicator with [~indicator]. Use [~label_key] and [~name_key] for a custom key for the \
       label and the names."
  ; Doc.pre {|Chart.tooltip ~content:(Chart.tooltip_content ()) ()|}
  ; Doc.h3 "Props"
  ; Doc.props
      [ "label_key", "string", "The config or data key to use for the label."
      ; "name_key", "string", "The config or data key to use for the name."
      ; "indicator", "Chart.Indicator.t", "[Dot] (the default), [Line] or [Dashed]."
      ; "hide_label", "bool", "Whether to hide the label."
      ; "hide_indicator", "bool", "Whether to hide the indicator."
      ; ( "label_formatter"
        , "string -> Chart.Item.t list -> Node.t list"
        , "Draws the label from its text and the items." )
      ; ( "formatter"
        , "Chart.Item.t -> int -> Node.t list"
        , "Draws an item's row (from the item and its index), in place of the indicator, \
           name and value." )
      ]
  ; Doc.p
      "[Chart.tooltip] itself takes [~cursor] (draw the cursor under the pointer; [true] by \
       default) and [~default_index] (show the tooltip for that datum before any hover)."
  ; Doc.h3 "Colors"
  ; Doc.p "Colours are automatically referenced from the chart config."
  ; Doc.h3 "Custom"
  ; Doc.p "To use a custom key for the tooltip's label and names, use [~label_key] and [~name_key]."
  ; Doc.pre
      {|let chart_data =
  [ [ "browser", `Text "chrome"; "visitors", `Num 187.; "fill", `Text "var(--color-chrome)" ]
  ; [ "browser", `Text "safari"; "visitors", `Num 200.; "fill", `Text "var(--color-safari)" ]
  ]

let chart_config : Chart.Config.t =
  [ "visitors", Chart.Config.item ~label:"Total Visitors" ()
  ; "chrome", Chart.Config.item ~label:"Chrome" ~color:"var(--chart-1)" ()
  ; "safari", Chart.Config.item ~label:"Safari" ~color:"var(--chart-2)" ()
  ]

Chart.tooltip
  ~content:(Chart.tooltip_content ~label_key:"visitors" ~name_key:"browser" ())
  ()|}
  ; Doc.p "This uses \"Total Visitors\" for the label and \"Chrome\" and \"Safari\" for the names."
  ; Doc.h2 "Legend"
  ; Doc.p "Use [Chart.legend] with [Chart.legend_content] to add a legend to your chart."
  ; Doc.pre {|Chart.legend ~content:(Chart.legend_content ()) ()|}
  ; Doc.h3 "Colors"
  ; Doc.p "Colours are automatically referenced from the chart config."
  ; Doc.h3 "Custom"
  ; Doc.p "To use a custom key for the legend's names, use [~name_key]."
  ; Doc.pre {|Chart.legend ~content:(Chart.legend_content ~name_key:"browser" ()) ()|}
  ; Doc.p "This uses \"Chrome\" and \"Safari\" for the legend's names."
  ; Doc.h2 "Accessibility"
  ; Doc.p
      "Charts always have Recharts' accessibility layer: the chart's SVG is focusable \
       ([role=\"application\"]), and the Left and Right arrow keys move the tooltip between \
       data points, for keyboard and screen reader users."
  ]
;;

let page =
  Doc.page
    ~slug:"chart"
    ~title:"Chart"
    ~description:
      "Beautiful charts. Built using Recharts. Copy and paste into your apps. Here, drawn in \
       OCaml: the same SVG, styled by shadcn's classes."
    ~usage:
      {|Chart.container ~config chart
  (Chart.bar_chart ~data
     [ Chart.bar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~radius:(`All 4.) ()
     ; Chart.tooltip ~content:(Chart.tooltip_content ()) ()
     ])|}
    ~body
    [ Doc.example ~page "Your First Chart" (Chart_data.frame ~wide:true first_chart)
    ; Doc.example ~page "Add a Grid" (Chart_data.frame ~wide:true grid)
    ; Doc.example ~page "Add an Axis" (Chart_data.frame ~wide:true axis)
    ; Doc.example ~page "Add Tooltip" (Chart_data.frame ~wide:true tooltip)
    ; Doc.example ~page "Add Legend" (Chart_data.frame ~wide:true legend)
    ; Doc.static ~page "Tooltip" tooltip_anatomy
    ]
;;
