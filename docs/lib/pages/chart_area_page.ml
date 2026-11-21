open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "chart_area"

(* The data and footer most of the examples share, as shadcn's do. *)
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

let footer ?(text = "January - June 2024") () =
  Card.footer
    [ Node.div
        ~attrs:[ Attr.class_ "flex w-full items-start gap-2 text-sm" ]
        [ Node.div
            ~attrs:[ Attr.class_ "grid gap-2" ]
            [ Node.div
                ~attrs:[ Attr.class_ "flex items-center gap-2 leading-none font-medium" ]
                [ Node.text "Trending up by 5.2% this month"
                ; Icon.view ~class_:"h-4 w-4" Trending_up
                ]
            ; Node.div
                ~attrs:
                  [ Attr.class_ "flex items-center gap-2 leading-none text-muted-foreground"
                  ]
                [ Node.text text ]
            ]
        ]
    ]
;;

let header ~title =
  Card.header
    [ Card.title [ Node.text title ]
    ; Card.description [ Node.text "Showing total visitors for the last 6 months" ]
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

let stacked_areas =
  [ Chart.area
      ~data_key:"mobile"
      ~type_:Natural
      ~fill:"var(--color-mobile)"
      ~fill_opacity:0.4
      ~stroke:"var(--color-mobile)"
      ~stack_id:"a"
      ()
  ; Chart.area
      ~data_key:"desktop"
      ~type_:Natural
      ~fill:"var(--color-desktop)"
      ~fill_opacity:0.4
      ~stroke:"var(--color-desktop)"
      ~stack_id:"a"
      ()
  ]
;;

(*$ Area Chart - Interactive
    An interactive area chart. *)
let interactive (local_ graph) =
  let select =
    Select.component
      ~default_value:"90d"
      (Bonsai.return
         (Select.trigger
            ~attrs:[ Attr.create "aria-label" "Select a value" ]
            ~class_:"hidden w-[160px] rounded-lg sm:ml-auto sm:flex"
            ~placeholder:"Last 3 months"
            ()))
      (Bonsai.return
         (Select.content
            ~class_:"rounded-xl"
            [ Select.item ~class_:"rounded-lg" ~value:"90d" [ Node.text "Last 3 months" ]
            ; Select.item ~class_:"rounded-lg" ~value:"30d" [ Node.text "Last 30 days" ]
            ; Select.item ~class_:"rounded-lg" ~value:"7d" [ Node.text "Last 7 days" ]
            ]))
      graph
  in
  let chart = Chart.component graph in
  let%arr time_range, select = select
  and chart in
  let days =
    match time_range with
    | Some "30d" -> 30
    | Some "7d" -> 7
    | _ -> 90
  in
  let config : Chart.Config.t =
    [ "visitors", Chart.Config.item ~label:"Visitors" ()
    ; "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--chart-1)" ()
    ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"var(--chart-2)" ()
    ]
  in
  Card.root
    ~class_:"pt-0"
    [ Card.header
        ~class_:"flex items-center gap-2 space-y-0 border-b py-5 sm:flex-row"
        [ Node.div
            ~attrs:[ Attr.class_ "grid flex-1 gap-1" ]
            [ Card.title [ Node.text "Area Chart - Interactive" ]
            ; Card.description [ Node.text "Showing total visitors for the last 3 months" ]
            ]
        ; select
        ]
    ; Card.content
        ~class_:"px-2 pt-4 sm:px-6 sm:pt-6"
        [ Chart.container
            ~config
            ~class_:"aspect-auto h-[250px] w-full"
            chart
            (Chart.area_chart
               ~data:(Chart_data.last_days days)
               [ Chart.defs
                   [ Chart.linear_gradient
                       ~id:"fillDesktop"
                       [ Chart.stop ~offset:"5%" ~color:"var(--color-desktop)" ~opacity:0.8 ()
                       ; Chart.stop ~offset:"95%" ~color:"var(--color-desktop)" ~opacity:0.1 ()
                       ]
                   ; Chart.linear_gradient
                       ~id:"fillMobile"
                       [ Chart.stop ~offset:"5%" ~color:"var(--color-mobile)" ~opacity:0.8 ()
                       ; Chart.stop ~offset:"95%" ~color:"var(--color-mobile)" ~opacity:0.1 ()
                       ]
                   ]
               ; Chart.cartesian_grid ~vertical:false ()
               ; Chart.x_axis
                   ~data_key:"date"
                   ~tick_line:false
                   ~axis_line:false
                   ~tick_margin:8.
                   ~min_tick_gap:32.
                   ~tick_formatter:(fun value -> Chart_data.short_date value)
                   ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:
                     (Chart.tooltip_content
                        ~label_formatter:(fun value _ ->
                          [ Node.text (Chart_data.short_date value) ])
                        ~indicator:Dot
                        ())
                   ()
               ; Chart.area
                   ~data_key:"mobile"
                   ~type_:Natural
                   ~fill:"url(#fillMobile)"
                   ~stroke:"var(--color-mobile)"
                   ~stack_id:"a"
                   ()
               ; Chart.area
                   ~data_key:"desktop"
                   ~type_:Natural
                   ~fill:"url(#fillDesktop)"
                   ~stroke:"var(--color-desktop)"
                   ~stack_id:"a"
                   ()
               ; Chart.legend ~content:(Chart.legend_content ()) ()
               ])
        ]
    ]
;;

(*$*)

(*$ Area Chart
    A simple area chart. *)
let default (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Area Chart"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.area_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; Chart.x_axis
                   ~data_key:"month"
                   ~tick_line:false
                   ~axis_line:false
                   ~tick_margin:8.
                   ~tick_formatter:(fun value -> String.prefix value 3)
                   ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~indicator:Line ())
                   ()
               ; Chart.area
                   ~data_key:"desktop"
                   ~type_:Natural
                   ~fill:"var(--color-desktop)"
                   ~fill_opacity:0.4
                   ~stroke:"var(--color-desktop)"
                   ()
               ])
        ]
    ; footer ()
    ]
;;

(*$*)

(*$ Area Chart - Linear
    A linear area chart. *)
let linear (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Area Chart - Linear"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.area_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~indicator:Dot ~hide_label:true ())
                   ()
               ; Chart.area
                   ~data_key:"desktop"
                   ~type_:Linear
                   ~fill:"var(--color-desktop)"
                   ~fill_opacity:0.4
                   ~stroke:"var(--color-desktop)"
                   ()
               ])
        ]
    ; footer ()
    ]
;;

(*$*)

(*$ Area Chart - Step
    A step area chart. *)
let step (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let config : Chart.Config.t =
    [ ( "desktop"
      , Chart.Config.item
          ~label:"Desktop"
          ~color:"var(--chart-1)"
          ~icon:(fun () -> Icon.view Activity)
          () )
    ]
  in
  Card.root
    [ header ~title:"Area Chart - Step"
    ; Card.content
        [ Chart.container
            ~config
            chart
            (Chart.area_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.area
                   ~data_key:"desktop"
                   ~type_:Step
                   ~fill:"var(--color-desktop)"
                   ~fill_opacity:0.4
                   ~stroke:"var(--color-desktop)"
                   ()
               ])
        ]
    ; footer ()
    ]
;;

(*$*)

(*$ Area Chart - Stacked
    A stacked area chart. *)
let stacked (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Area Chart - Stacked"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.area_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               ([ Chart.cartesian_grid ~vertical:false ()
                ; month_axis
                ; Chart.tooltip
                    ~cursor:false
                    ~content:(Chart.tooltip_content ~indicator:Dot ())
                    ()
                ]
                @ stacked_areas))
        ]
    ; footer ()
    ]
;;

(*$*)

(*$ Area Chart - Stacked Expanded
    A stacked area chart with expand stacking. *)
let stacked_expand (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let data =
    List.map
      [ "January", 186., 80., 45.
      ; "February", 305., 200., 100.
      ; "March", 237., 120., 150.
      ; "April", 73., 190., 50.
      ; "May", 209., 130., 100.
      ; "June", 214., 140., 160.
      ]
      ~f:(fun (month, desktop, mobile, other) ->
        [ "month", `Text month
        ; "desktop", `Num desktop
        ; "mobile", `Num mobile
        ; "other", `Num other
        ])
  in
  let config : Chart.Config.t =
    [ "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--chart-1)" ()
    ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"var(--chart-2)" ()
    ; "other", Chart.Config.item ~label:"Other" ~color:"var(--chart-3)" ()
    ]
  in
  Card.root
    [ header ~title:"Area Chart - Stacked Expanded"
    ; Card.content
        [ Chart.container
            ~config
            chart
            (Chart.area_chart
               ~data
               ~margin:(Chart.margin ~left:12. ~right:12. ~top:12. ())
               ~stack_offset:Expand
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~indicator:Line ())
                   ()
               ; Chart.area
                   ~data_key:"other"
                   ~type_:Natural
                   ~fill:"var(--color-other)"
                   ~fill_opacity:0.1
                   ~stroke:"var(--color-other)"
                   ~stack_id:"a"
                   ()
               ; Chart.area
                   ~data_key:"mobile"
                   ~type_:Natural
                   ~fill:"var(--color-mobile)"
                   ~fill_opacity:0.4
                   ~stroke:"var(--color-mobile)"
                   ~stack_id:"a"
                   ()
               ; Chart.area
                   ~data_key:"desktop"
                   ~type_:Natural
                   ~fill:"var(--color-desktop)"
                   ~fill_opacity:0.4
                   ~stroke:"var(--color-desktop)"
                   ~stack_id:"a"
                   ()
               ])
        ]
    ; footer ()
    ]
;;

(*$*)

(*$ Area Chart - Legend
    An area chart with a legend. *)
let legend (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Area Chart - Legend"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.area_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               ([ Chart.cartesian_grid ~vertical:false ()
                ; month_axis
                ; Chart.tooltip
                    ~cursor:false
                    ~content:(Chart.tooltip_content ~indicator:Line ())
                    ()
                ]
                @ stacked_areas
                @ [ Chart.legend ~content:(Chart.legend_content ()) () ]))
        ]
    ; footer ()
    ]
;;

(*$*)

(*$ Area Chart - Icons
    An area chart with icons. *)
let icons (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  let config : Chart.Config.t =
    [ ( "desktop"
      , Chart.Config.item
          ~label:"Desktop"
          ~color:"var(--chart-1)"
          ~icon:(fun () -> Icon.view Trending_down)
          () )
    ; ( "mobile"
      , Chart.Config.item
          ~label:"Mobile"
          ~color:"var(--chart-2)"
          ~icon:(fun () -> Icon.view Trending_up)
          () )
    ]
  in
  Card.root
    [ header ~title:"Area Chart - Icons"
    ; Card.content
        [ Chart.container
            ~config
            chart
            (Chart.area_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               ([ Chart.cartesian_grid ~vertical:false ()
                ; month_axis
                ; Chart.tooltip
                    ~cursor:false
                    ~content:(Chart.tooltip_content ~indicator:Line ())
                    ()
                ]
                @ stacked_areas
                @ [ Chart.legend ~content:(Chart.legend_content ()) () ]))
        ]
    ; footer ()
    ]
;;

(*$*)

(*$ Area Chart - Gradient
    An area chart with gradient fill. *)
let gradient (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Area Chart - Gradient"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.area_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:12. ~right:12. ())
               [ Chart.cartesian_grid ~vertical:false ()
               ; month_axis
               ; Chart.tooltip ~cursor:false ~content:(Chart.tooltip_content ()) ()
               ; Chart.defs
                   [ Chart.linear_gradient
                       ~id:"fillDesktop"
                       [ Chart.stop ~offset:"5%" ~color:"var(--color-desktop)" ~opacity:0.8 ()
                       ; Chart.stop ~offset:"95%" ~color:"var(--color-desktop)" ~opacity:0.1 ()
                       ]
                   ; Chart.linear_gradient
                       ~id:"fillMobile"
                       [ Chart.stop ~offset:"5%" ~color:"var(--color-mobile)" ~opacity:0.8 ()
                       ; Chart.stop ~offset:"95%" ~color:"var(--color-mobile)" ~opacity:0.1 ()
                       ]
                   ]
               ; Chart.area
                   ~data_key:"mobile"
                   ~type_:Natural
                   ~fill:"url(#fillMobile)"
                   ~fill_opacity:0.4
                   ~stroke:"var(--color-mobile)"
                   ~stack_id:"a"
                   ()
               ; Chart.area
                   ~data_key:"desktop"
                   ~type_:Natural
                   ~fill:"url(#fillDesktop)"
                   ~fill_opacity:0.4
                   ~stroke:"var(--color-desktop)"
                   ~stack_id:"a"
                   ()
               ])
        ]
    ; footer ()
    ]
;;

(*$*)

(*$ Area Chart - Axes
    An area chart with axes. *)
let axes (local_ graph) =
  let chart = Chart.component graph in
  let%arr chart in
  Card.root
    [ header ~title:"Area Chart - Axes"
    ; Card.content
        [ Chart.container
            ~config:chart_config
            chart
            (Chart.area_chart
               ~data:chart_data
               ~margin:(Chart.margin ~left:(-20.) ~right:12. ())
               ([ Chart.cartesian_grid ~vertical:false ()
                ; month_axis
                ; Chart.y_axis ~tick_line:false ~axis_line:false ~tick_margin:8. ~tick_count:3 ()
                ; Chart.tooltip ~cursor:false ~content:(Chart.tooltip_content ()) ()
                ]
                @ stacked_areas))
        ]
    ; footer ()
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:"chart-area"
    ~title:"Area Charts"
    ~section:Charts
    ~order:1
    ~description:"Area charts: stacked, expanded, gradients, steps, legends and an interactive one."
    [ Doc.example ~page "Area Chart - Interactive" (Chart_data.frame ~wide:true interactive)
    ; Doc.example ~page "Area Chart" (Chart_data.frame default)
    ; Doc.example ~page "Area Chart - Linear" (Chart_data.frame linear)
    ; Doc.example ~page "Area Chart - Step" (Chart_data.frame step)
    ; Doc.example ~page "Area Chart - Legend" (Chart_data.frame legend)
    ; Doc.example ~page "Area Chart - Stacked" (Chart_data.frame stacked)
    ; Doc.example ~page "Area Chart - Stacked Expanded" (Chart_data.frame stacked_expand)
    ; Doc.example ~page "Area Chart - Icons" (Chart_data.frame icons)
    ; Doc.example ~page "Area Chart - Gradient" (Chart_data.frame gradient)
    ; Doc.example ~page "Area Chart - Axes" (Chart_data.frame axes)
    ]
;;
