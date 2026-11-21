open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr
module Data = Dashboard_01_data
open Js_of_ocaml

let sr_only text = Node.span ~attrs:[ Attr.class_ "sr-only" ] [ Node.text text ]
let div class_ children = Node.div ~attrs:[ Attr.class_ class_ ] children
let span class_ children = Node.span ~attrs:[ Attr.class_ class_ ] children

(* A select keeping its own value (shadcn's uncontrolled [<Select
   defaultValue>]): its id prefix (its trigger's id is [id ^ "-trigger"])
   and [view ?default_value trigger content]. *)
let select (local_ graph) =
  let value, set_value = Bonsai.state_opt graph in
  let state, set_state = Bonsai.state Select.State.closed graph in
  let id = Bonsai.path_id graph in
  let%arr value and set_value and state and set_state and id in
  ( id
  , fun ?default_value trigger content ->
      Select.view
        ~id
        ~value:(Option.first_some value default_value)
        ~on_value_change:(fun v -> set_value (Some v))
        ~state
        ~on_state_change:set_state
        trigger
        content )
;;

(* {1 app-sidebar.tsx} *)

module App_data = struct
  let user_name = "shadcn"
  let user_email = "m@example.com"
  let user_avatar = "avatars/shadcn.jpg"

  let nav_main =
    [ "Dashboard", "#", Icon.Gauge
    ; "Lifecycle", "#", Layout_list
    ; "Analytics", "#", Chart_column
    ; "Projects", "#", Folder
    ; "Team", "#", Users
    ]
  ;;

  let nav_secondary =
    [ "Settings", "#", Icon.Settings
    ; "Get Help", "#", Circle_question_mark
    ; "Search", "#", Search
    ]
  ;;

  let documents =
    [ "Data Library", "#", Icon.Database
    ; "Reports", "#", Clipboard_list
    ; "Word Assistant", "#", File_type
    ]
  ;;
end

(* {2 nav-main.tsx} *)

let nav_main items =
  Sidebar.group
    [ Sidebar.group_content
        ~class_:"flex flex-col gap-2"
        [ Sidebar.menu
            [ Sidebar.menu_item
                ~class_:"flex items-center gap-2"
                [ Sidebar.menu_button
                    ~tooltip:"Quick Create"
                    ~class_:
                      "min-w-8 bg-primary text-primary-foreground duration-200 \
                       ease-linear hover:bg-primary/90 \
                       hover:text-primary-foreground active:bg-primary/90 \
                       active:text-primary-foreground"
                    [ Icon.view Circle_plus; Node.span [ Node.text "Quick Create" ] ]
                ; Button.view
                    ~size:Icon
                    ~class_:"size-8 group-data-[collapsible=icon]:opacity-0"
                    ~variant:Outline
                    [ Icon.view Mail; sr_only "Inbox" ]
                ]
            ]
        ; Sidebar.menu
            (List.map items ~f:(fun (title, _url, icon) ->
               Sidebar.menu_item
                 [ Sidebar.menu_button
                     ~tooltip:title
                     [ Icon.view icon; Node.span [ Node.text title ] ]
                 ]))
        ]
    ]
;;

(* {2 nav-documents.tsx} *)

let nav_documents ~sidebar items (local_ graph) =
  let item (name, url, icon) =
    let menu =
      Dropdown_menu.component
        (let%arr sidebar in
         let is_mobile = Sidebar.is_mobile sidebar in
         fun menu ->
           [ Dropdown_menu.trigger
               menu
               (Sidebar.menu_action
                  ~show_on_hover:true
                  ~class_:"rounded-sm data-[state=open]:bg-accent"
                  [ Icon.view Ellipsis; sr_only "More" ])
           ; Dropdown_menu.content
               menu
               ~class_:"w-24 rounded-lg"
               ~side:(if is_mobile then Bottom else Right)
               ~align:(if is_mobile then End else Start)
               [ Dropdown_menu.item [ Icon.view Folder; Node.span [ Node.text "Open" ] ]
               ; Dropdown_menu.item [ Icon.view Share; Node.span [ Node.text "Share" ] ]
               ; Dropdown_menu.separator ()
               ; Dropdown_menu.item
                   ~variant:Destructive
                   [ Icon.view Trash; Node.span [ Node.text "Delete" ] ]
               ]
           ])
        graph
    in
    let%arr menu in
    Sidebar.menu_item
      [ Sidebar.menu_button ~href:url [ Icon.view icon; Node.span [ Node.text name ] ]
      ; menu
      ]
  in
  let%arr items = Bonsai.all (List.map items ~f:item) in
  Sidebar.group
    ~class_:"group-data-[collapsible=icon]:hidden"
    [ Sidebar.group_label [ Node.text "Documents" ]
    ; Sidebar.menu
        (items
         @ [ Sidebar.menu_item
               [ Sidebar.menu_button
                   ~class_:"text-sidebar-foreground/70"
                   [ Icon.view ~class_:"text-sidebar-foreground/70" Ellipsis
                   ; Node.span [ Node.text "More" ]
                   ]
               ]
           ])
    ]
;;

(* {2 nav-secondary.tsx} *)

let nav_secondary ?class_ items =
  Sidebar.group
    ?class_
    [ Sidebar.group_content
        [ Sidebar.menu
            (List.map items ~f:(fun (title, url, icon) ->
               Sidebar.menu_item
                 [ Sidebar.menu_button
                     ~href:url
                     [ Icon.view icon; Node.span [ Node.text title ] ]
                 ]))
        ]
    ]
;;

(* {2 nav-user.tsx} *)

let nav_user ~sidebar ~name ~email ~avatar (local_ graph) =
  let avatar ?class_ () =
    Avatar.component
      ~class_:(Cn.cn [ "h-8 w-8 rounded-lg"; Option.value class_ ~default:"" ])
      (Bonsai.return (fun a ->
         [ Avatar.image a ~src:avatar ~alt:name ()
         ; Avatar.fallback a ~class_:"rounded-lg" [ Node.text "CN" ]
         ]))
      graph
  in
  let in_button = avatar ~class_:"grayscale" () in
  let in_label = avatar () in
  let who =
    div
      "grid flex-1 text-left text-sm leading-tight"
      [ span "truncate font-medium" [ Node.text name ]
      ; span "truncate text-xs text-muted-foreground" [ Node.text email ]
      ]
  in
  let menu =
    Dropdown_menu.component
      (let%arr sidebar and in_button and in_label in
       fun menu ->
         [ Dropdown_menu.trigger
             menu
             (Sidebar.menu_button
                ~size:Lg
                ~class_:
                  "data-[state=open]:bg-sidebar-accent \
                   data-[state=open]:text-sidebar-accent-foreground"
                [ in_button; who; Icon.view ~class_:"ml-auto size-4" Ellipsis_vertical ])
         ; Dropdown_menu.content
             menu
             ~class_:"w-(--radix-dropdown-menu-trigger-width) min-w-56 rounded-lg"
             ~side:(if Sidebar.is_mobile sidebar then Bottom else Right)
             ~align:End
             ~side_offset:4.
             [ Dropdown_menu.label
                 ~class_:"p-0 font-normal"
                 [ div
                     "flex items-center gap-2 px-1 py-1.5 text-left text-sm"
                     [ in_label; who ]
                 ]
             ; Dropdown_menu.separator ()
             ; Dropdown_menu.group
                 [ Dropdown_menu.item [ Icon.view Circle_user; Node.text "Account" ]
                 ; Dropdown_menu.item [ Icon.view Credit_card; Node.text "Billing" ]
                 ; Dropdown_menu.item [ Icon.view Bell; Node.text "Notifications" ]
                 ]
             ; Dropdown_menu.separator ()
             ; Dropdown_menu.item [ Icon.view Log_out; Node.text "Log out" ]
             ]
         ])
      graph
  in
  let%arr menu in
  Sidebar.menu [ Sidebar.menu_item [ menu ] ]
;;

let app_sidebar ?variant ~sidebar (local_ graph) =
  let nav_documents = nav_documents ~sidebar App_data.documents graph in
  let nav_user =
    nav_user
      ~sidebar
      ~name:App_data.user_name
      ~email:App_data.user_email
      ~avatar:App_data.user_avatar
      graph
  in
  let%arr sidebar and nav_documents and nav_user in
  Sidebar.root
    ~collapsible:Offcanvas
    ?variant
    sidebar
    [ Sidebar.header
        [ Sidebar.menu
            [ Sidebar.menu_item
                [ Sidebar.menu_button
                    ~href:"#"
                    ~class_:"data-[slot=sidebar-menu-button]:p-1.5!"
                    [ Icon.view ~class_:"size-5!" Contrast
                    ; span "text-base font-semibold" [ Node.text "Acme Inc." ]
                    ]
                ]
            ]
        ]
    ; Sidebar.content
        [ nav_main App_data.nav_main
        ; nav_documents
        ; nav_secondary ~class_:"mt-auto" App_data.nav_secondary
        ]
    ; Sidebar.footer [ nav_user ]
    ]
;;

(* {1 site-header.tsx} *)

let site_header sidebar =
  Node.header
    ~attrs:
      [ Attr.class_
          "flex h-(--header-height) shrink-0 items-center gap-2 border-b \
           transition-[width,height] ease-linear \
           group-has-data-[collapsible=icon]/sidebar-wrapper:h-(--header-height)"
      ]
    [ div
        "flex w-full items-center gap-1 px-4 lg:gap-2 lg:px-6"
        [ Sidebar.trigger ~class_:"-ml-1" sidebar
        ; Separator.view
            ~orientation:Vertical
            ~class_:"mx-2 data-[orientation=vertical]:h-4"
            ()
        ; Node.h1 ~attrs:[ Attr.class_ "text-base font-medium" ] [ Node.text "Documents" ]
        ; div
            "ml-auto flex items-center gap-2"
            [ Button.link
                ~variant:Ghost
                ~size:Sm
                ~class_:"hidden sm:flex dark:text-foreground"
                ~attrs:
                  [ Attr.create "rel" "noopener noreferrer"
                  ; Attr.create "target" "_blank"
                  ]
                ~href:
                  "https://github.com/shadcn-ui/ui/tree/main/apps/v4/app/(examples)/dashboard"
                [ Node.text "GitHub" ]
            ]
        ]
    ]
;;

(* {1 section-cards.tsx} *)

let section_cards =
  let card ~description ~title ~(trend : Icon.t) ~badge ~footer ~muted =
    Card.root
      ~class_:"@container/card"
      [ Card.header
          [ Card.description [ Node.text description ]
          ; Card.title
              ~class_:"text-2xl font-semibold tabular-nums @[250px]/card:text-3xl"
              [ Node.text title ]
          ; Card.action
              [ Badge.view ~variant:Outline [ Icon.view trend; Node.text badge ] ]
          ]
      ; Card.footer
          ~class_:"flex-col items-start gap-1.5 text-sm"
          [ div
              "line-clamp-1 flex gap-2 font-medium"
              [ Node.text (footer ^ " "); Icon.view ~class_:"size-4" trend ]
          ; div "text-muted-foreground" [ Node.text muted ]
          ]
      ]
  in
  div
    "grid grid-cols-1 gap-4 px-4 *:data-[slot=card]:bg-gradient-to-t \
     *:data-[slot=card]:from-primary/5 *:data-[slot=card]:to-card \
     *:data-[slot=card]:shadow-xs lg:px-6 @xl/main:grid-cols-2 \
     @5xl/main:grid-cols-4 dark:*:data-[slot=card]:bg-card"
    [ card
        ~description:"Total Revenue"
        ~title:"$1,250.00"
        ~trend:Trending_up
        ~badge:"+12.5%"
        ~footer:"Trending up this month"
        ~muted:"Visitors for the last 6 months"
    ; card
        ~description:"New Customers"
        ~title:"1,234"
        ~trend:Trending_down
        ~badge:"-20%"
        ~footer:"Down 20% this period"
        ~muted:"Acquisition needs attention"
    ; card
        ~description:"Active Accounts"
        ~title:"45,678"
        ~trend:Trending_up
        ~badge:"+12.5%"
        ~footer:"Strong user retention"
        ~muted:"Engagement exceed targets"
    ; card
        ~description:"Growth Rate"
        ~title:"4.5%"
        ~trend:Trending_up
        ~badge:"+4.5%"
        ~footer:"Steady performance increase"
        ~muted:"Meets growth projections"
    ]
;;

(* {1 chart-area-interactive.tsx} *)

let chart_data =
  [ "2024-04-01", 222, 150
  ; "2024-04-02", 97, 180
  ; "2024-04-03", 167, 120
  ; "2024-04-04", 242, 260
  ; "2024-04-05", 373, 290
  ; "2024-04-06", 301, 340
  ; "2024-04-07", 245, 180
  ; "2024-04-08", 409, 320
  ; "2024-04-09", 59, 110
  ; "2024-04-10", 261, 190
  ; "2024-04-11", 327, 350
  ; "2024-04-12", 292, 210
  ; "2024-04-13", 342, 380
  ; "2024-04-14", 137, 220
  ; "2024-04-15", 120, 170
  ; "2024-04-16", 138, 190
  ; "2024-04-17", 446, 360
  ; "2024-04-18", 364, 410
  ; "2024-04-19", 243, 180
  ; "2024-04-20", 89, 150
  ; "2024-04-21", 137, 200
  ; "2024-04-22", 224, 170
  ; "2024-04-23", 138, 230
  ; "2024-04-24", 387, 290
  ; "2024-04-25", 215, 250
  ; "2024-04-26", 75, 130
  ; "2024-04-27", 383, 420
  ; "2024-04-28", 122, 180
  ; "2024-04-29", 315, 240
  ; "2024-04-30", 454, 380
  ; "2024-05-01", 165, 220
  ; "2024-05-02", 293, 310
  ; "2024-05-03", 247, 190
  ; "2024-05-04", 385, 420
  ; "2024-05-05", 481, 390
  ; "2024-05-06", 498, 520
  ; "2024-05-07", 388, 300
  ; "2024-05-08", 149, 210
  ; "2024-05-09", 227, 180
  ; "2024-05-10", 293, 330
  ; "2024-05-11", 335, 270
  ; "2024-05-12", 197, 240
  ; "2024-05-13", 197, 160
  ; "2024-05-14", 448, 490
  ; "2024-05-15", 473, 380
  ; "2024-05-16", 338, 400
  ; "2024-05-17", 499, 420
  ; "2024-05-18", 315, 350
  ; "2024-05-19", 235, 180
  ; "2024-05-20", 177, 230
  ; "2024-05-21", 82, 140
  ; "2024-05-22", 81, 120
  ; "2024-05-23", 252, 290
  ; "2024-05-24", 294, 220
  ; "2024-05-25", 201, 250
  ; "2024-05-26", 213, 170
  ; "2024-05-27", 420, 460
  ; "2024-05-28", 233, 190
  ; "2024-05-29", 78, 130
  ; "2024-05-30", 340, 280
  ; "2024-05-31", 178, 230
  ; "2024-06-01", 178, 200
  ; "2024-06-02", 470, 410
  ; "2024-06-03", 103, 160
  ; "2024-06-04", 439, 380
  ; "2024-06-05", 88, 140
  ; "2024-06-06", 294, 250
  ; "2024-06-07", 323, 370
  ; "2024-06-08", 385, 320
  ; "2024-06-09", 438, 480
  ; "2024-06-10", 155, 200
  ; "2024-06-11", 92, 150
  ; "2024-06-12", 492, 420
  ; "2024-06-13", 81, 130
  ; "2024-06-14", 426, 380
  ; "2024-06-15", 307, 350
  ; "2024-06-16", 371, 310
  ; "2024-06-17", 475, 520
  ; "2024-06-18", 107, 170
  ; "2024-06-19", 341, 290
  ; "2024-06-20", 408, 450
  ; "2024-06-21", 169, 210
  ; "2024-06-22", 317, 270
  ; "2024-06-23", 480, 530
  ; "2024-06-24", 132, 180
  ; "2024-06-25", 141, 190
  ; "2024-06-26", 434, 380
  ; "2024-06-27", 448, 490
  ; "2024-06-28", 149, 200
  ; "2024-06-29", 103, 160
  ; "2024-06-30", 446, 400
  ]
;;

let chart_config : Chart.Config.t =
  [ "visitors", Chart.Config.item ~label:"Visitors" ()
  ; "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--primary)" ()
  ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"var(--primary)" ()
  ]
;;

(* [toLocaleDateString("en-US", { month: "short", day: "numeric" })]. *)
let short_date value =
  match Date.of_string value with
  | date ->
    sprintf
      "%s %d"
      (Month.to_string (Date.month date) |> String.capitalize)
      (Date.day date)
  | exception _ -> value
;;

let chart_area_interactive (local_ graph) =
  let is_mobile = Use_mobile.component graph in
  let time_range, set_time_range = Bonsai.state "90d" graph in
  Bonsai.Edge.on_change
    ~equal:Bool.equal
    is_mobile
    ~callback:
      (let%arr set_time_range in
       fun is_mobile -> if is_mobile then set_time_range "7d" else Effect.Ignore)
    graph;
  let chart = Chart.component graph in
  let select_state, set_select_state = Bonsai.state Select.State.closed graph in
  let select_id = Bonsai.path_id graph in
  let%arr time_range
  and set_time_range
  and chart
  and select_state
  and set_select_state
  and select_id in
  let filtered_data =
    let reference_date = Date.of_string "2024-06-30" in
    let days_to_subtract =
      match time_range with
      | "30d" -> 30
      | "7d" -> 7
      | _ -> 90
    in
    let start_date = Date.add_days reference_date (-days_to_subtract) in
    List.filter_map chart_data ~f:(fun (date, desktop, mobile) ->
      if Date.( >= ) (Date.of_string date) start_date
      then
        Some
          [ "date", `Text date
          ; "desktop", `Num (Float.of_int desktop)
          ; "mobile", `Num (Float.of_int mobile)
          ]
      else None)
  in
  let range_item value label =
    Select.item ~class_:"rounded-lg" ~value [ Node.text label ]
  in
  Card.root
    ~class_:"@container/card"
    [ Card.header
        [ Card.title [ Node.text "Total Visitors" ]
        ; Card.description
            [ span "hidden @[540px]/card:block" [ Node.text "Total for the last 3 months" ]
            ; span "@[540px]/card:hidden" [ Node.text "Last 3 months" ]
            ]
        ; Card.action
            [ Toggle_group.single
                ~value:(Some time_range)
                ~on_change:(function
                  | Some v -> set_time_range v
                  | None -> set_time_range "")
                ~variant:Outline
                ~class_:
                  "hidden *:data-[slot=toggle-group-item]:px-4! @[767px]/card:flex"
                (fun group ->
                   [ Toggle_group.item group ~value:"90d" [ Node.text "Last 3 months" ]
                   ; Toggle_group.item group ~value:"30d" [ Node.text "Last 30 days" ]
                   ; Toggle_group.item group ~value:"7d" [ Node.text "Last 7 days" ]
                   ])
            ; Select.view
                ~id:select_id
                ~value:(Some time_range)
                ~on_value_change:set_time_range
                ~state:select_state
                ~on_state_change:set_select_state
                (Select.trigger
                   ~class_:
                     "flex w-40 **:data-[slot=select-value]:block \
                      **:data-[slot=select-value]:truncate @[767px]/card:hidden"
                   ~size:Sm
                   ~attrs:[ Attr.create "aria-label" "Select a value" ]
                   ~placeholder:"Last 3 months"
                   ())
                (Select.content
                   ~class_:"rounded-xl"
                   [ range_item "90d" "Last 3 months"
                   ; range_item "30d" "Last 30 days"
                   ; range_item "7d" "Last 7 days"
                   ])
            ]
        ]
    ; Card.content
        ~class_:"px-2 pt-4 sm:px-6 sm:pt-6"
        [ Chart.container
            ~config:chart_config
            ~class_:"aspect-auto h-[250px] w-full"
            chart
            (Chart.area_chart
               ~data:filtered_data
               [ Chart.defs
                   [ Chart.linear_gradient
                       ~id:"fillDesktop"
                       ~x1:"0"
                       ~y1:"0"
                       ~x2:"0"
                       ~y2:"1"
                       [ Chart.stop
                           ~offset:"5%"
                           ~color:"var(--color-desktop)"
                           ~opacity:1.0
                           ()
                       ; Chart.stop
                           ~offset:"95%"
                           ~color:"var(--color-desktop)"
                           ~opacity:0.1
                           ()
                       ]
                   ; Chart.linear_gradient
                       ~id:"fillMobile"
                       ~x1:"0"
                       ~y1:"0"
                       ~x2:"0"
                       ~y2:"1"
                       [ Chart.stop
                           ~offset:"5%"
                           ~color:"var(--color-mobile)"
                           ~opacity:0.8
                           ()
                       ; Chart.stop
                           ~offset:"95%"
                           ~color:"var(--color-mobile)"
                           ~opacity:0.1
                           ()
                       ]
                   ]
               ; Chart.cartesian_grid ~vertical:false ()
               ; Chart.x_axis
                   ~data_key:"date"
                   ~tick_line:false
                   ~axis_line:false
                   ~tick_margin:8.
                   ~min_tick_gap:32.
                   ~tick_formatter:short_date
                   ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:
                     (Chart.tooltip_content
                        ~label_formatter:(fun value _ -> [ Node.text (short_date value) ])
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
               ])
        ]
    ]
;;

(* {1 data-table.tsx} *)

(* The drawer's chart. *)
let viewer_chart_data =
  List.map
    [ "January", 186, 80
    ; "February", 305, 200
    ; "March", 237, 120
    ; "April", 73, 190
    ; "May", 209, 130
    ; "June", 214, 140
    ]
    ~f:(fun (month, desktop, mobile) ->
      [ "month", `Text month
      ; "desktop", `Num (Float.of_int desktop)
      ; "mobile", `Num (Float.of_int mobile)
      ])
;;

let viewer_chart_config : Chart.Config.t =
  [ "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--primary)" ()
  ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"var(--primary)" ()
  ]
;;

let table_cell_viewer (item : Data.t Bonsai.t) ~is_mobile (local_ graph) =
  let open_, set_open = Bonsai.state false graph in
  let id = Bonsai.path_id graph in
  let chart = Chart.component graph in
  let type_select = select graph in
  let status_select = select graph in
  let reviewer_select = select graph in
  let%arr item
  and is_mobile
  and open_
  and set_open
  and id
  and chart
  and type_id, type_select = type_select
  and status_id, status_select = status_select
  and reviewer_id, reviewer_select = reviewer_select in
  let field ?(class_ = "flex flex-col gap-3") ~for_ label control =
    div class_ [ Label.view ~for_ [ Node.text label ]; control ]
  in
  let items values = List.map values ~f:(fun v -> Select.item ~value:v [ Node.text v ]) in
  Drawer.view
    ~id
    ~direction:(if is_mobile then Bottom else Right)
    ~open_
    ~on_open_change:set_open
    (fun drawer ->
       [ Drawer.trigger
           drawer
           (Button.view
              ~variant:Link
              ~class_:"w-fit px-0 text-left text-foreground"
              [ Node.text item.header ])
       ; Drawer.content
           drawer
           [ Drawer.header
               ~class_:"gap-1"
               [ Drawer.title drawer [ Node.text item.header ]
               ; Drawer.description
                   drawer
                   [ Node.text "Showing total visitors for the last 6 months" ]
               ]
           ; div
               "flex flex-col gap-4 overflow-y-auto px-4 text-sm"
               ((if is_mobile
                 then []
                 else
                   [ Chart.container
                       ~config:viewer_chart_config
                       chart
                       (Chart.area_chart
                          ~data:viewer_chart_data
                          ~margin:(Chart.margin ~left:0. ~right:10. ())
                          [ Chart.cartesian_grid ~vertical:false ()
                          ; Chart.x_axis
                              ~data_key:"month"
                              ~tick_line:false
                              ~axis_line:false
                              ~tick_margin:8.
                              ~tick_formatter:(fun value -> String.prefix value 3)
                              ~hide:true
                              ()
                          ; Chart.tooltip
                              ~cursor:false
                              ~content:(Chart.tooltip_content ~indicator:Dot ())
                              ()
                          ; Chart.area
                              ~data_key:"mobile"
                              ~type_:Natural
                              ~fill:"var(--color-mobile)"
                              ~fill_opacity:0.6
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
                   ; Separator.view ()
                   ; div
                       "grid gap-2"
                       [ div
                           "flex gap-2 leading-none font-medium"
                           [ Node.text "Trending up by 5.2% this month "
                           ; Icon.view ~class_:"size-4" Trending_up
                           ]
                       ; div
                           "text-muted-foreground"
                           [ Node.text
                               "Showing total visitors for the last 6 months. This \
                                is just some random text to test the layout. It \
                                spans multiple lines and should wrap around."
                           ]
                       ]
                   ; Separator.view ()
                   ])
                @ [ Node.form
                      ~attrs:[ Attr.class_ "flex flex-col gap-4" ]
                      [ field
                          ~for_:"header"
                          "Header"
                          (Input.view ~id:"header" ~value:item.header ())
                      ; div
                          "grid grid-cols-2 gap-4"
                          [ field
                              ~for_:(type_id ^ "-trigger")
                              "Type"
                              (type_select
                                 ~default_value:item.type_
                                 (Select.trigger
                                    ~class_:"w-full"
                                    ~placeholder:"Select a type"
                                    ())
                                 (Select.content
                                    (items
                                       [ "Table of Contents"
                                       ; "Executive Summary"
                                       ; "Technical Approach"
                                       ; "Design"
                                       ; "Capabilities"
                                       ; "Focus Documents"
                                       ; "Narrative"
                                       ; "Cover Page"
                                       ])))
                          ; field
                              ~for_:(status_id ^ "-trigger")
                              "Status"
                              (status_select
                                 ~default_value:item.status
                                 (Select.trigger
                                    ~class_:"w-full"
                                    ~placeholder:"Select a status"
                                    ())
                                 (Select.content
                                    (items [ "Done"; "In Progress"; "Not Started" ])))
                          ]
                      ; div
                          "grid grid-cols-2 gap-4"
                          [ field
                              ~for_:"target"
                              "Target"
                              (Input.view ~id:"target" ~value:item.target ())
                          ; field
                              ~for_:"limit"
                              "Limit"
                              (Input.view ~id:"limit" ~value:item.limit ())
                          ]
                      ; field
                          ~for_:(reviewer_id ^ "-trigger")
                          "Reviewer"
                          (reviewer_select
                             ~default_value:item.reviewer
                             (Select.trigger
                                ~class_:"w-full"
                                ~placeholder:"Select a reviewer"
                                ())
                             (Select.content
                                (items
                                   [ "Eddie Lake"; "Jamik Tashpulatov"; "Emily Whalen" ])))
                      ]
                  ])
           ; Drawer.footer
               [ Button.view [ Node.text "Submit" ]
               ; Drawer.close drawer (Button.view ~variant:Outline [ Node.text "Done" ])
               ]
           ]
       ])
;;

(* A row's cells that keep state: [TableCellViewer], the reviewer's select
   and the actions' menu. *)
module Row_cells = struct
  type t =
    { header : Node.t
    ; reviewer : Node.t
    ; actions : Node.t
    }
end

let saving_toast ~sleep (item : Data.t) =
  Sonner.promise
    ~loading:("Saving " ^ item.header)
    ~success:(fun () -> "Done")
    ~error:(fun _ -> "Error")
    (let%map.Effect () = sleep (Time_ns.Span.of_sec 1.) in
     Ok ())
;;

let row_cells ~is_mobile (item : Data.t Bonsai.t) (local_ graph) =
  let header = table_cell_viewer item ~is_mobile graph in
  let reviewer_select = select graph in
  let actions =
    Dropdown_menu.component
      (Bonsai.return (fun menu ->
         [ Dropdown_menu.trigger
             menu
             (Button.view
                ~variant:Ghost
                ~class_:"flex size-8 text-muted-foreground data-[state=open]:bg-muted"
                ~size:Icon
                [ Icon.view Ellipsis_vertical; sr_only "Open menu" ])
         ; Dropdown_menu.content
             menu
             ~align:End
             ~class_:"w-32"
             [ Dropdown_menu.item [ Node.text "Edit" ]
             ; Dropdown_menu.item [ Node.text "Make a copy" ]
             ; Dropdown_menu.item [ Node.text "Favorite" ]
             ; Dropdown_menu.separator ()
             ; Dropdown_menu.item ~variant:Destructive [ Node.text "Delete" ]
             ]
         ]))
      graph
  in
  let%arr item and header and reviewer_id, reviewer_select = reviewer_select and actions in
  let reviewer =
    if not (String.equal item.reviewer "Assign reviewer")
    then Node.text item.reviewer
    else (
      Node.fragment
        [ Label.view ~for_:(reviewer_id ^ "-trigger") ~class_:"sr-only" [ Node.text "Reviewer" ]
        ; reviewer_select
            (Select.trigger
               ~class_:
                 "w-38 **:data-[slot=select-value]:block \
                  **:data-[slot=select-value]:truncate"
               ~size:Sm
               ~placeholder:"Assign reviewer"
               ())
            (Select.content
               ~align:End
               [ Select.item ~value:"Eddie Lake" [ Node.text "Eddie Lake" ]
               ; Select.item
                   ~value:"Jamik Tashpulatov"
                   [ Node.text "Jamik Tashpulatov" ]
               ])
        ])
  in
  { Row_cells.header; reviewer; actions }
;;

(* dnd-kit's sortable rows, by pointer (the handle captures it) or keyboard
   (Space or Enter picks the row up, the arrows move it, Space or Enter drops
   it and Esc puts it back). *)
module Drag = struct
  type t =
    { id : int
    ; start_y : float
    ; dy : float
    ; height : float
    ; keyboard : bool
    ; ids : int list (** the page's rows, when the drag started *)
    }
  [@@deriving sexp_of, equal]

  (* Where the dragged row would land on its page: (from, to). *)
  let target t =
    let ids = t.ids in
    match List.findi ids ~f:(fun _ id -> id = t.id) with
    | None -> None
    | Some (from, _) ->
      let by = Float.iround_nearest_exn (t.dy /. t.height) in
      Some (from, Int.clamp_exn (from + by) ~min:0 ~max:(List.length ids - 1))
  ;;

  (* The transform of the row at [index] of the page while [t] is dragged. *)
  let offset t index id =
    if id = t.id
    then Some t.dy
    else (
      match target t with
      | None -> None
      | Some (from, to_) ->
        if from < index && index <= to_
        then Some (-.t.height)
        else if to_ <= index && index < from
        then Some t.height
        else None)
  ;;

  (* The dragged row's height, from the handle the event is on. *)
  let row_height (ev : #Dom_html.event Js.t) =
    try
      let target : Js.Unsafe.any = Js.Unsafe.get ev "currentTarget" in
      let tr : Js.Unsafe.any =
        Js.Unsafe.meth_call target "closest" [| Js.Unsafe.inject (Js.string "tr") |]
      in
      let h : float = Js.float_of_number (Js.Unsafe.get tr "offsetHeight") in
      if Float.( > ) h 0. then h else 53.
    with
    | _ -> 53.
  ;;

  let capture (ev : Dom_html.pointerEvent Js.t) =
    Effect.of_thunk (fun () ->
      try
        let target : Js.Unsafe.any = Js.Unsafe.get ev "currentTarget" in
        ignore
          (Js.Unsafe.meth_call
             target
             "setPointerCapture"
             [| Js.Unsafe.inject (Js.Unsafe.get ev "pointerId") |]
           : Js.Unsafe.any)
      with
      | _ -> ())
  ;;

  (* Applied by a state machine, so that events between renders see the
     drag as it is (not as the last render saw it). *)
  module Action = struct
    type nonrec t =
      | Start of t (** pointer down *)
      | Move of float (** the pointer's y *)
      | Release (** pointer up *)
      | Toggle of t (** Space or Enter: pick up, or drop *)
      | Step of int (** the arrows *)
      | Cancel
    [@@deriving sexp_of]
  end
end

let dnd_instructions_id = "DndDescribedBy-0"

let drag_handle ~(drag : Drag.t option) ~(inject : Drag.Action.t -> unit Effect.t) ~ids id =
  let active =
    match drag with
    | Some d -> d.id = id
    | None -> false
  in
  let pointer_y (ev : Dom_html.pointerEvent Js.t) = Js.to_float ev##.clientY in
  Button.view
    ~variant:Ghost
    ~size:Icon
    ~class_:"size-7 text-muted-foreground hover:bg-transparent"
    ~attrs:
      [ Attr.create "aria-roledescription" "sortable"
      ; Attr.create "aria-describedby" dnd_instructions_id
      ; Attr.create "aria-pressed" (Bool.to_string active)
      ; Attr.on_pointerdown (fun ev ->
          if ev##.button <> 0
          then Effect.Ignore
          else
            Effect.Many
              [ Drag.capture ev
              ; inject
                  (Start
                     { Drag.id
                     ; start_y = pointer_y ev
                     ; dy = 0.
                     ; height = Drag.row_height ev
                     ; keyboard = false
                     ; ids
                     })
              ])
      ; Attr.on_pointermove (fun ev -> inject (Move (pointer_y ev)))
      ; Attr.on_pointerup (fun _ -> inject Release)
      ; Attr.on_keydown (fun ev ->
          let stop = Dom_util.prevent_default ev in
          match Dom_util.key ev with
          | Space | Enter ->
            Effect.Many
              [ stop
              ; inject
                  (Toggle
                     { Drag.id
                     ; start_y = 0.
                     ; dy = 0.
                     ; height = Drag.row_height ev
                     ; keyboard = true
                     ; ids
                     })
              ]
          | Escape when active -> Effect.Many [ stop; inject Cancel ]
          | ArrowDown when active -> Effect.Many [ stop; inject (Step 1) ]
          | ArrowUp when active -> Effect.Many [ stop; inject (Step (-1)) ]
          | _ -> Effect.Ignore)
      ]
    [ Icon.view ~class_:"size-3 text-muted-foreground" Grip_vertical
    ; sr_only "Drag to reorder"
    ]
;;

let editable_cell ~sleep ~(item : Data.t) ~field ~label value =
  let id = sprintf "%d-%s" item.id field in
  Node.form
    ~attrs:
      [ Attr.on_submit (fun ev ->
          Effect.Many [ Dom_util.prevent_default ev; saving_toast ~sleep item ])
      ]
    [ Label.view ~for_:id ~class_:"sr-only" [ Node.text label ]
    ; Input.view
        ~class_:
          "h-8 w-16 border-transparent bg-transparent text-right shadow-none \
           hover:bg-input/30 focus-visible:border focus-visible:bg-background \
           dark:bg-transparent dark:hover:bg-input/30 \
           dark:focus-visible:bg-input/30"
        ~value
        ~id
        ()
    ]
;;

let columns ~sleep ~(cells : Row_cells.t Int.Map.t) ~drag ~inject =
  let cells_of (row : Data.t Data_table.Row.t) = Map.find_exn cells row.original.id in
  let outline_badge children =
    Badge.view ~variant:Outline ~class_:"px-1.5 text-muted-foreground" children
  in
  let right text = [ div "w-full text-right" [ Node.text text ] ] in
  [ Data_table.Column.create
      ~id:"drag"
      ~hideable:false
      ~header:(fun _ -> [])
      ~cell:(fun table row ->
        let ids =
          List.map (Data_table.rows table) ~f:(fun (r : Data.t Data_table.Row.t) ->
            r.original.id)
        in
        [ drag_handle ~drag ~inject ~ids row.original.id ])
      ()
  ; Data_table.Column.create
      ~id:"select"
      ~hideable:false
      ~header:(fun table ->
        [ div
            "flex items-center justify-center"
            [ Checkbox.view
                ~checked:
                  (if Data_table.is_all_page_rows_selected table
                   then Checked
                   else if Data_table.is_some_page_rows_selected table
                   then Indeterminate
                   else Unchecked)
                ~on_change:(Data_table.toggle_all_page_rows_selected table)
                ~attrs:[ Attr.create "aria-label" "Select all" ]
                ()
            ]
        ])
      ~cell:(fun table row ->
        [ div
            "flex items-center justify-center"
            [ Checkbox.view
                ~checked:(if Data_table.is_selected table row then Checked else Unchecked)
                ~on_change:(Data_table.toggle_selected table row)
                ~attrs:[ Attr.create "aria-label" "Select row" ]
                ()
            ]
        ])
      ()
  ; Data_table.Column.create
      ~id:"header"
      ~hideable:false
      ~header:(fun _ -> [ Node.text "Header" ])
      ~cell:(fun _ row -> [ (cells_of row).header ])
      ()
  ; Data_table.Column.create
      ~id:"type"
      ~header:(fun _ -> [ Node.text "Section Type" ])
      ~cell:(fun _ (row : Data.t Data_table.Row.t) -> [ div "w-32" [ outline_badge [ Node.text row.original.type_ ] ] ])
      ()
  ; Data_table.Column.create
      ~id:"status"
      ~header:(fun _ -> [ Node.text "Status" ])
      ~cell:(fun _ (row : Data.t Data_table.Row.t) ->
        [ outline_badge
            [ (if String.equal row.original.status "Done"
               then Icon.view ~class_:"fill-green-500 dark:fill-green-400" Circle_check
               else Icon.view Loader)
            ; Node.text row.original.status
            ]
        ])
      ()
  ; Data_table.Column.create
      ~id:"target"
      ~header:(fun _ -> right "Target")
      ~cell:(fun _ (row : Data.t Data_table.Row.t) ->
        [ editable_cell
            ~sleep
            ~item:row.original
            ~field:"target"
            ~label:"Target"
            row.original.target
        ])
      ()
  ; Data_table.Column.create
      ~id:"limit"
      ~header:(fun _ -> right "Limit")
      ~cell:(fun _ (row : Data.t Data_table.Row.t) ->
        [ editable_cell
            ~sleep
            ~item:row.original
            ~field:"limit"
            ~label:"Limit"
            row.original.limit
        ])
      ()
  ; Data_table.Column.create
      ~id:"reviewer"
      ~header:(fun _ -> [ Node.text "Reviewer" ])
      ~cell:(fun _ row -> [ (cells_of row).reviewer ])
      ()
  ; Data_table.Column.create
      ~id:"actions"
      ~hideable:false
      ~header:(fun _ -> [])
      ~cell:(fun _ row -> [ (cells_of row).actions ])
      ()
  ]
;;

let array_move list ~from ~to_ =
  let x = List.nth_exn list from in
  let rest = List.filteri list ~f:(fun i _ -> i <> from) in
  List.take rest to_ @ [ x ] @ List.drop rest to_
;;

let data_table (initial_data : Data.t list) (local_ graph) =
  let is_mobile = Use_mobile.component graph in
  let sleep = Bonsai.Clock.sleep graph in
  let model, inject =
    Bonsai.state_machine
      ~default_model:(initial_data, None)
      ~apply_action:(fun _ (data, drag) (action : Drag.Action.t) ->
        (* [arrayMove] over the whole data, from the dragged row's index to
           the one it is dropped on. *)
        let drop (d : Drag.t) =
          match Drag.target d with
          | Some (from, to_) when from <> to_ ->
            let index id = fst (List.findi_exn data ~f:(fun _ (r : Data.t) -> r.id = id)) in
            array_move data ~from:(index d.id) ~to_:(index (List.nth_exn d.ids to_))
          | _ -> data
        in
        match action, drag with
        | Start d, _ -> data, Some d
        | Move y, Some d when not d.keyboard -> data, Some { d with dy = y -. d.start_y }
        | Release, Some d when not d.keyboard -> drop d, None
        | Toggle d, None -> data, Some d
        | Toggle d', Some d when d.id = d'.id -> drop d, None
        | Step n, Some d when d.keyboard ->
          data, Some { d with dy = d.dy +. (Float.of_int n *. d.height) }
        | Cancel, _ -> data, None
        | _ -> data, drag)
      graph
  in
  let data = Bonsai.map model ~f:fst in
  let drag = Bonsai.map model ~f:snd in
  let cells =
    Bonsai.assoc
      (module Int)
      (Bonsai.return
         (Int.Map.of_alist_exn (List.map initial_data ~f:(fun (d : Data.t) -> d.id, d))))
      ~f:(fun _ item (local_ graph) -> row_cells ~is_mobile item graph)
      graph
  in
  let columns =
    let%arr sleep and cells and drag and inject in
    columns ~sleep ~cells ~drag ~inject
  in
  let table =
    Data_table.component
      ~get_row_id:(fun (r : Data.t) -> Int.to_string r.id)
      ~columns
      data
      graph
  in
  let column_menu =
    Dropdown_menu.component
      (let%arr table in
       fun menu ->
         [ Dropdown_menu.trigger
             menu
             (Button.view
                ~variant:Outline
                ~size:Sm
                [ Icon.view Columns_2
                ; span "hidden lg:inline" [ Node.text "Customize Columns" ]
                ; span "lg:hidden" [ Node.text "Columns" ]
                ; Icon.view Chevron_down
                ])
         ; Dropdown_menu.content
             menu
             ~align:End
             ~class_:"w-56"
             (Data_table.all_columns table
              |> List.filter ~f:Data_table.can_hide
              |> List.map ~f:(fun column ->
                let id = Data_table.Column.id column in
                Dropdown_menu.checkbox_item
                  ~class_:"capitalize"
                  ~checked:(Data_table.is_visible table id)
                  ~on_checked_change:(Data_table.toggle_visibility table id)
                  [ Node.text id ]))
         ])
      graph
  in
  let view_selector = select graph in
  let rows_state, set_rows_state = Bonsai.state Select.State.closed graph in
  let tabs_content =
    let%arr table
    and drag
    and column_menu
    and view_selector_id, view_selector = view_selector
    and rows_state and set_rows_state in
    let visible = Data_table.visible_columns table in
    let state = Data_table.state table in
    let rows =
      match Data_table.rows table with
      | [] ->
        [ Table.row
            [ Table.cell
                ~col_span:(List.length (Data_table.all_columns table))
                ~class_:"h-24 text-center"
                [ Node.text "No results." ]
            ]
        ]
      | rows ->
        List.mapi rows ~f:(fun index row ->
          let offset = Option.bind drag ~f:(fun d -> Drag.offset d index row.original.id) in
          let dragging =
            match drag with
            | Some d -> d.id = row.original.id
            | None -> false
          in
          let style =
            match drag, offset with
            | None, _ -> []
            | Some _, offset ->
              [ Attr.style
                  (Css_gen.concat
                     [ Css_gen.create
                         ~field:"transform"
                         ~value:
                           (match offset with
                            | Some y -> sprintf "translate3d(0px, %gpx, 0) scaleX(1) scaleY(1)" y
                            | None -> "none")
                     ; (if dragging
                        then Css_gen.empty
                        else Css_gen.create ~field:"transition" ~value:"transform 250ms ease")
                     ])
              ]
          in
          Table.row
            ~selected:(Data_table.is_selected table row)
            ~attrs:(Attr.create "data-dragging" (Bool.to_string dragging) :: style)
            ~class_:"relative z-0 data-[dragging=true]:z-10 data-[dragging=true]:opacity-80"
            (List.map visible ~f:(fun column ->
               Table.cell (Data_table.cell table column row))))
    in
    let placeholder tabs value =
      Tabs.content
        tabs
        ~value
        ~class_:"flex flex-col px-4 lg:px-6"
        [ div "aspect-video w-full flex-1 rounded-lg border border-dashed" [] ]
    in
    let page_button ~class_ ?size ~label ~on_click ~disabled icon =
      Button.view
        ~variant:Outline
        ~class_
        ?size
        ~on_click
        ~disabled
        [ sr_only label; Icon.view icon ]
    in
    fun tabs ->
      [ div
          "flex items-center justify-between px-4 lg:px-6"
          [ Label.view
              ~for_:(view_selector_id ^ "-trigger")
              ~class_:"sr-only"
              [ Node.text "View" ]
          ; view_selector
              ~default_value:"outline"
              (Select.trigger
                 ~class_:"flex w-fit @4xl/main:hidden"
                 ~size:Sm
                 ~placeholder:"Select a view"
                 ())
              (Select.content
                 [ Select.item ~value:"outline" [ Node.text "Outline" ]
                 ; Select.item ~value:"past-performance" [ Node.text "Past Performance" ]
                 ; Select.item ~value:"key-personnel" [ Node.text "Key Personnel" ]
                 ; Select.item ~value:"focus-documents" [ Node.text "Focus Documents" ]
                 ])
          ; Tabs.list
              tabs
              ~class_:
                "hidden **:data-[slot=badge]:size-5 **:data-[slot=badge]:rounded-full \
                 **:data-[slot=badge]:bg-muted-foreground/30 **:data-[slot=badge]:px-1 \
                 @4xl/main:flex"
              [ Tabs.trigger ~value:"outline" [ Node.text "Outline" ]
              ; Tabs.trigger
                  ~value:"past-performance"
                  [ Node.text "Past Performance "
                  ; Badge.view ~variant:Secondary [ Node.text "3" ]
                  ]
              ; Tabs.trigger
                  ~value:"key-personnel"
                  [ Node.text "Key Personnel "; Badge.view ~variant:Secondary [ Node.text "2" ] ]
              ; Tabs.trigger ~value:"focus-documents" [ Node.text "Focus Documents" ]
              ]
          ; div
              "flex items-center gap-2"
              [ column_menu
              ; Button.view
                  ~variant:Outline
                  ~size:Sm
                  [ Icon.view Plus; span "hidden lg:inline" [ Node.text "Add Section" ] ]
              ]
          ]
      ; Tabs.content
          tabs
          ~value:"outline"
          ~class_:"relative flex flex-col gap-4 overflow-auto px-4 lg:px-6"
          [ div
              "overflow-hidden rounded-lg border"
              [ Node.div
                  ~attrs:[ Attr.id dnd_instructions_id; Attr.style (Css_gen.display `None) ]
                  [ Node.text
                      "To pick up a draggable item, press the space bar. While \
                       dragging, use the arrow keys to move the item. Press space \
                       again to drop the item in its new position, or press escape \
                       to cancel."
                  ]
              ; Table.root
                  [ Table.header
                      ~class_:"sticky top-0 z-10 bg-muted"
                      [ Table.row
                          (List.map visible ~f:(fun column ->
                             Table.head
                               ~attrs:[ Attr.create "colspan" "1" ]
                               (Data_table.header table column)))
                      ]
                  ; Table.body ~class_:"**:data-[slot=table-cell]:first:w-8" rows
                  ]
              ]
          ; div
              "flex items-center justify-between px-4"
              [ div
                  "hidden flex-1 text-sm text-muted-foreground lg:flex"
                  [ Node.text
                      (sprintf
                         "%d of %d row(s) selected."
                         (List.length (Data_table.filtered_selected_rows table))
                         (List.length (Data_table.filtered_rows table)))
                  ]
              ; div
                  "flex w-full items-center gap-8 lg:w-fit"
                  [ div
                      "hidden items-center gap-2 lg:flex"
                      [ Label.view
                          ~for_:"rows-per-page-trigger"
                          ~class_:"text-sm font-medium"
                          [ Node.text "Rows per page" ]
                      ; Select.view
                          ~id:"rows-per-page"
                          ~value:(Some (Int.to_string state.page_size))
                          ~on_value_change:(fun v ->
                            Data_table.set_page_size table (Int.of_string v))
                          ~state:rows_state
                          ~on_state_change:set_rows_state
                          (Select.trigger
                             ~size:Sm
                             ~class_:"w-20"
                             ~placeholder:(Int.to_string state.page_size)
                             ())
                          (Select.content
                             ~side:Top
                             (List.map [ 10; 20; 30; 40; 50 ] ~f:(fun n ->
                                Select.item
                                  ~value:(Int.to_string n)
                                  [ Node.text (Int.to_string n) ])))
                      ]
                  ; div
                      "flex w-fit items-center justify-center text-sm font-medium"
                      [ Node.text
                          (sprintf
                             "Page %d of %d"
                             (state.page_index + 1)
                             (Data_table.page_count table))
                      ]
                  ; div
                      "ml-auto flex items-center gap-2 lg:ml-0"
                      [ page_button
                          ~class_:"hidden h-8 w-8 p-0 lg:flex"
                          ~label:"Go to first page"
                          ~on_click:(Data_table.set_page_index table 0)
                          ~disabled:(not (Data_table.can_previous_page table))
                          Chevrons_left
                      ; page_button
                          ~class_:"size-8"
                          ~size:Icon
                          ~label:"Go to previous page"
                          ~on_click:(Data_table.previous_page table)
                          ~disabled:(not (Data_table.can_previous_page table))
                          Chevron_left
                      ; page_button
                          ~class_:"size-8"
                          ~size:Icon
                          ~label:"Go to next page"
                          ~on_click:(Data_table.next_page table)
                          ~disabled:(not (Data_table.can_next_page table))
                          Chevron_right
                      ; page_button
                          ~class_:"hidden size-8 lg:flex"
                          ~size:Icon
                          ~label:"Go to last page"
                          ~on_click:
                            (Data_table.set_page_index
                               table
                               (Data_table.page_count table - 1))
                          ~disabled:(not (Data_table.can_next_page table))
                          Chevrons_right
                      ]
                  ]
              ]
          ]
      ; placeholder tabs "past-performance"
      ; placeholder tabs "key-personnel"
      ; placeholder tabs "focus-documents"
      ]
  in
  Tabs.component
    ~class_:"w-full flex-col justify-start gap-6"
    ~default_value:"outline"
    tabs_content
    graph
;;

(* {1 page.tsx} *)

let view (local_ graph) =
  let sidebar = Sidebar.component ~persist:false graph in
  let app_sidebar = app_sidebar ~variant:Inset ~sidebar graph in
  let chart = chart_area_interactive graph in
  let data_table = data_table Data.all graph in
  let toaster = Sonner.toaster graph in
  let%arr sidebar and app_sidebar and chart and data_table and toaster in
  Node.fragment
    [ Sidebar.provider
        ~attrs:
          [ Attr.__css_vars_no_kebabs
              [ "--sidebar-width", "calc(var(--spacing) * 72)"
              ; "--header-height", "calc(var(--spacing) * 12)"
              ]
          ]
        sidebar
        [ app_sidebar
        ; Sidebar.inset
            [ site_header sidebar
            ; div
                "flex flex-1 flex-col"
                [ div
                    "@container/main flex flex-1 flex-col gap-2"
                    [ div
                        "flex flex-col gap-4 py-4 md:gap-6 md:py-6"
                        [ section_cards
                        ; div "px-4 lg:px-6" [ chart ]
                        ; data_table
                        ]
                    ]
                ]
            ]
        ]
    ; toaster
    ]
;;
