open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

module User = struct
  type t =
    { name : string
    ; email : string
    ; avatar : string
    }
end

module Team = struct
  type t =
    { name : string
    ; logo : Icon.t
    }
end

module Nav_item = struct
  type t =
    { title : string
    ; url : string
    ; icon : Icon.t
    ; is_active : bool
    ; badge : string option
    }

  let make ?(is_active = false) ?badge title icon =
    { title; url = "#"; icon; is_active; badge }
  ;;
end

module Page = struct
  type t =
    { name : string
    ; url : string
    ; emoji : string
    }

  let make name emoji = { name; url = "#"; emoji }
end

module Workspace = struct
  type t =
    { name : string
    ; emoji : string
    ; pages : Page.t list
    }
end

(* This is sample data. *)
let user =
  { User.name = "shadcn"; email = "m@example.com"; avatar = "avatars/shadcn.jpg" }
;;

let calendars =
  [ "My Calendars", [ "Personal"; "Work"; "Family" ]
  ; "Favorites", [ "Holidays"; "Birthdays" ]
  ; "Other", [ "Travel"; "Reminders"; "Deadlines" ]
  ]
;;

let teams : Team.t list =
  [ { name = "Acme Inc"; logo = Command }
  ; { name = "Acme Corp."; logo = Audio_waveform }
  ; { name = "Evil Corp."; logo = Command }
  ]
;;

let nav_main_items =
  Nav_item.
    [ make "Search" Search
    ; make "Ask AI" Sparkles
    ; make ~is_active:true "Home" House
    ; make ~badge:"10" "Inbox" Inbox
    ]
;;

let nav_secondary_items =
  Nav_item.
    [ make "Calendar" Calendar
    ; make "Settings" Settings_2
    ; make "Templates" Blocks
    ; make "Trash" Trash
    ; make "Help" Message_circle_question_mark
    ]
;;

let favorites =
  Page.
    [ make "Project Management & Task Tracking" "📊"
    ; make "Family Recipe Collection & Meal Planning" "🍳"
    ; make "Fitness Tracker & Workout Routines" "💪"
    ; make "Book Notes & Reading List" "📚"
    ; make "Sustainable Gardening Tips & Plant Care" "🌱"
    ; make "Language Learning Progress & Resources" "🗣️"
    ; make "Home Renovation Ideas & Budget Tracker" "🏠"
    ; make "Personal Finance & Investment Portfolio" "💰"
    ; make "Movie & TV Show Watchlist with Reviews" "🎬"
    ; make "Daily Habit Tracker & Goal Setting" "✅"
    ]
;;

let workspaces : Workspace.t list =
  [ { name = "Personal Life Management"
    ; emoji = "🏠"
    ; pages =
        Page.
          [ make "Daily Journal & Reflection" "📔"
          ; make "Health & Wellness Tracker" "🍏"
          ; make "Personal Growth & Learning Goals" "🌟"
          ]
    }
  ; { name = "Professional Development"
    ; emoji = "💼"
    ; pages =
        Page.
          [ make "Career Objectives & Milestones" "🎯"
          ; make "Skill Acquisition & Training Log" "🧠"
          ; make "Networking Contacts & Events" "🤝"
          ]
    }
  ; { name = "Creative Projects"
    ; emoji = "🎨"
    ; pages =
        Page.
          [ make "Writing Ideas & Story Outlines" "✍️"
          ; make "Art & Design Portfolio" "🖼️"
          ; make "Music Composition & Practice Log" "🎵"
          ]
    }
  ; { name = "Home Management"
    ; emoji = "🏡"
    ; pages =
        Page.
          [ make "Household Budget & Expense Tracking" "💰"
          ; make "Home Maintenance Schedule & Tasks" "🔧"
          ; make "Family Calendar & Event Planning" "📅"
          ]
    }
  ; { name = "Travel & Adventure"
    ; emoji = "🧳"
    ; pages =
        Page.
          [ make "Trip Planning & Itineraries" "🗺️"
          ; make "Travel Bucket List & Inspiration" "🌎"
          ; make "Travel Journal & Photo Gallery" "📸"
          ]
    }
  ]
;;

let team_switcher (local_ graph) =
  let active_team, set_active_team = Bonsai.state (List.hd_exn teams) graph in
  let menu =
    Dropdown_menu.component
      (let%arr active_team and set_active_team in
       fun menu ->
         [ Dropdown_menu.trigger
             menu
             (Sidebar.menu_button
                ~class_:"w-fit px-1.5"
                [ Node.div
                    ~attrs:
                      [ Attr.class_
                          "flex aspect-square size-5 items-center \
                           justify-center rounded-md bg-sidebar-primary \
                           text-sidebar-primary-foreground"
                      ]
                    [ Icon.view ~class_:"size-3" active_team.Team.logo ]
                ; Node.span
                    ~attrs:[ Attr.class_ "truncate font-medium" ]
                    [ Node.text active_team.name ]
                ; Icon.view ~class_:"opacity-50" Chevron_down
                ])
         ; Dropdown_menu.content
             menu
             ~class_:"w-64 rounded-lg"
             ~align:Start
             ~side:Bottom
             ~side_offset:4.
             ([ Dropdown_menu.label
                  ~class_:"text-xs text-muted-foreground"
                  [ Node.text "Teams" ]
              ]
              @ List.mapi teams ~f:(fun index (team : Team.t) ->
                Dropdown_menu.item
                  ~on_select:(set_active_team team)
                  ~class_:"gap-2 p-2"
                  [ Node.div
                      ~attrs:
                        [ Attr.class_
                            "flex size-6 items-center justify-center \
                             rounded-xs border"
                        ]
                      [ Icon.view ~class_:"size-4 shrink-0" team.logo ]
                  ; Node.text team.name
                  ; Dropdown_menu.shortcut
                      [ Node.text (sprintf "⌘%d" (index + 1)) ]
                  ])
              @ [ Dropdown_menu.separator ()
                ; Dropdown_menu.item
                    ~class_:"gap-2 p-2"
                    [ Node.div
                        ~attrs:
                          [ Attr.class_
                              "flex size-6 items-center justify-center \
                               rounded-md border bg-background"
                          ]
                        [ Icon.view ~class_:"size-4" Plus ]
                    ; Node.div
                        ~attrs:
                          [ Attr.class_ "font-medium text-muted-foreground" ]
                        [ Node.text "Add team" ]
                    ]
                ])
         ])
      graph
  in
  let%arr menu in
  Sidebar.menu [ Sidebar.menu_item [ menu ] ]
;;

let nav_main items =
  Sidebar.menu
    (List.map items ~f:(fun (item : Nav_item.t) ->
       Sidebar.menu_item
         [ Sidebar.menu_button
             ~href:item.url
             ~is_active:item.is_active
             [ Icon.view item.icon; Node.span [ Node.text item.title ] ]
         ]))
;;

(* The rows' menus, one open at a time: [open_menu] is the open one's id
   and state. *)
let row_menu ~open_menu ~set_open_menu ~id f =
  Dropdown_menu.view
    ~id
    ~state:
      (match open_menu with
       | Some (open_id, state) when String.equal open_id id -> state
       | _ -> Dropdown_menu.State.Closed)
    ~on_change:(fun state ->
      set_open_menu
        (if Dropdown_menu.State.is_open state then Some (id, state) else None))
    f
;;

let nav_favorites ~sidebar (local_ graph) =
  let open_menu, set_open_menu = Bonsai.state None graph in
  let%arr sidebar and open_menu and set_open_menu in
  let is_mobile = Sidebar.is_mobile sidebar in
  Sidebar.group
    ~class_:"group-data-[collapsible=icon]:hidden"
    [ Sidebar.group_label [ Node.text "Favorites" ]
    ; Sidebar.menu
        (List.mapi favorites ~f:(fun index (item : Page.t) ->
           Sidebar.menu_item
             [ Sidebar.menu_button
                 ~href:item.url
                 ~attrs:[ Attr.title item.name ]
                 [ Node.span [ Node.text item.emoji ]
                 ; Node.span [ Node.text item.name ]
                 ]
             ; row_menu
                 ~open_menu
                 ~set_open_menu
                 ~id:(sprintf "favorite-%d" index)
                 (fun menu ->
                    [ Dropdown_menu.trigger
                        menu
                        (Sidebar.menu_action
                           ~show_on_hover:true
                           [ Icon.view Ellipsis
                           ; Node.span
                               ~attrs:[ Attr.class_ "sr-only" ]
                               [ Node.text "More" ]
                           ])
                    ; Dropdown_menu.content
                        menu
                        ~class_:"w-56 rounded-lg"
                        ~side:(if is_mobile then Bottom else Right)
                        ~align:(if is_mobile then End else Start)
                        [ Dropdown_menu.item
                            [ Icon.view ~class_:"text-muted-foreground" Star_off
                            ; Node.span [ Node.text "Remove from Favorites" ]
                            ]
                        ; Dropdown_menu.separator ()
                        ; Dropdown_menu.item
                            [ Icon.view ~class_:"text-muted-foreground" Link
                            ; Node.span [ Node.text "Copy Link" ]
                            ]
                        ; Dropdown_menu.item
                            [ Icon.view
                                ~class_:"text-muted-foreground"
                                Arrow_up_right
                            ; Node.span [ Node.text "Open in New Tab" ]
                            ]
                        ; Dropdown_menu.separator ()
                        ; Dropdown_menu.item
                            [ Icon.view ~class_:"text-muted-foreground" Trash
                            ; Node.span [ Node.text "Delete" ]
                            ]
                        ]
                    ])
             ])
         @ [ Sidebar.menu_item
               [ Sidebar.menu_button
                   ~class_:"text-sidebar-foreground/70"
                   [ Icon.view Ellipsis; Node.span [ Node.text "More" ] ]
               ]
           ])
    ]
;;

let nav_workspaces (local_ graph) =
  let expanded, set_expanded = Bonsai.state String.Set.empty graph in
  let%arr expanded and set_expanded in
  Sidebar.group
    [ Sidebar.group_label [ Node.text "Workspaces" ]
    ; Sidebar.group_content
        [ Sidebar.menu
            (List.mapi workspaces ~f:(fun index (workspace : Workspace.t) ->
               Collapsible.view
                 ~id:(sprintf "workspace-%d" index)
                 ~open_:(Set.mem expanded workspace.name)
                 ~on_change:(fun open_ ->
                   set_expanded
                     (if open_
                      then Set.add expanded workspace.name
                      else Set.remove expanded workspace.name))
                 (fun collapsible ->
                    [ Sidebar.menu_item
                        [ Sidebar.menu_button
                            ~href:"#"
                            [ Node.span [ Node.text workspace.emoji ]
                            ; Node.span [ Node.text workspace.name ]
                            ]
                        ; Collapsible.trigger_child
                            collapsible
                            (Sidebar.menu_action
                               ~class_:
                                 "left-2 bg-sidebar-accent \
                                  text-sidebar-accent-foreground \
                                  data-[state=open]:rotate-90"
                               ~show_on_hover:true
                               [ Icon.view Chevron_right ])
                        ; Sidebar.menu_action
                            ~show_on_hover:true
                            [ Icon.view Plus ]
                        ; Collapsible.content
                            collapsible
                            [ Sidebar.menu_sub
                                (List.map workspace.pages ~f:(fun page ->
                                   Sidebar.menu_sub_item
                                     [ Sidebar.menu_sub_button
                                         ~href:"#"
                                         [ Node.span [ Node.text page.emoji ]
                                         ; Node.span [ Node.text page.name ]
                                         ]
                                     ]))
                            ]
                        ]
                    ]))
             @ [ Sidebar.menu_item
                   [ Sidebar.menu_button
                       ~class_:"text-sidebar-foreground/70"
                       [ Icon.view Ellipsis; Node.span [ Node.text "More" ] ]
                   ]
               ])
        ]
    ]
;;

let nav_secondary ?class_ items =
  Sidebar.group
    ?class_
    [ Sidebar.group_content
        [ Sidebar.menu
            (List.map items ~f:(fun (item : Nav_item.t) ->
               Sidebar.menu_item
                 ([ Sidebar.menu_button
                      ~href:item.url
                      [ Icon.view item.icon; Node.span [ Node.text item.title ] ]
                  ]
                  @
                  match item.badge with
                  | Some badge -> [ Sidebar.menu_badge [ Node.text badge ] ]
                  | None -> [])))
        ]
    ]
;;

let avatar ~(user : User.t) (local_ graph) =
  Avatar.component
    ~class_:"h-8 w-8 rounded-lg"
    (Bonsai.return (fun avatar ->
       [ Avatar.image avatar ~src:user.avatar ~alt:user.name ()
       ; Avatar.fallback ~class_:"rounded-lg" avatar [ Node.text "CN" ]
       ]))
    graph
;;

let user_text (user : User.t) =
  Node.div
    ~attrs:[ Attr.class_ "grid flex-1 text-left text-sm leading-tight" ]
    [ Node.span
        ~attrs:[ Attr.class_ "truncate font-medium" ]
        [ Node.text user.name ]
    ; Node.span
        ~attrs:[ Attr.class_ "truncate text-xs" ]
        [ Node.text user.email ]
    ]
;;

let nav_user ~sidebar ~(user : User.t) (local_ graph) =
  let trigger_avatar = avatar ~user graph in
  let label_avatar = avatar ~user graph in
  let menu =
    Dropdown_menu.component
      (let%arr sidebar and trigger_avatar and label_avatar in
       fun menu ->
         [ Dropdown_menu.trigger
             menu
             (Sidebar.menu_button
                ~size:Lg
                ~class_:
                  "data-[state=open]:bg-sidebar-accent \
                   data-[state=open]:text-sidebar-accent-foreground"
                [ trigger_avatar
                ; user_text user
                ; Icon.view ~class_:"ml-auto size-4" Chevrons_up_down
                ])
         ; Dropdown_menu.content
             menu
             ~class_:
               "w-(--radix-dropdown-menu-trigger-width) min-w-56 rounded-lg"
             ~side:(if Sidebar.is_mobile sidebar then Bottom else Right)
             ~align:Start
             ~side_offset:4.
             [ Dropdown_menu.label
                 ~class_:"p-0 font-normal"
                 [ Node.div
                     ~attrs:
                       [ Attr.class_
                           "flex items-center gap-2 px-1 py-1.5 text-left \
                            text-sm"
                       ]
                     [ label_avatar; user_text user ]
                 ]
             ; Dropdown_menu.separator ()
             ; Dropdown_menu.group
                 [ Dropdown_menu.item
                     [ Icon.view Sparkles; Node.text "Upgrade to Pro" ]
                 ]
             ; Dropdown_menu.separator ()
             ; Dropdown_menu.group
                 [ Dropdown_menu.item
                     [ Icon.view Badge_check; Node.text "Account" ]
                 ; Dropdown_menu.item
                     [ Icon.view Credit_card; Node.text "Billing" ]
                 ; Dropdown_menu.item
                     [ Icon.view Bell; Node.text "Notifications" ]
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

let date_picker (local_ graph) =
  let calendar =
    Calendar.component
      ~class_:
        "[&_[role=gridcell]]:w-[33px] \
         [&_[role=gridcell].bg-accent]:bg-sidebar-primary \
         [&_[role=gridcell].bg-accent]:text-sidebar-primary-foreground"
      ~default:(Single None)
      graph
  in
  let%arr calendar in
  Sidebar.group
    ~class_:"px-0"
    [ Sidebar.group_content [ calendar.Calendar.view ] ]
;;

let calendars_view (local_ graph) =
  (* The groups opened or closed from their default (the first open). *)
  let toggled, set_toggled = Bonsai.state Int.Set.empty graph in
  let%arr toggled and set_toggled in
  Node.fragment
    (List.concat_mapi calendars ~f:(fun index (name, items) ->
       [ Sidebar.group
           ~class_:"py-0"
           [ Collapsible.view
               ~id:(sprintf "calendars-%d" index)
               ~class_:"group/collapsible"
               ~open_:(Bool.( <> ) (index = 0) (Set.mem toggled index))
               ~on_change:(fun _ ->
                 set_toggled
                   (if Set.mem toggled index
                    then Set.remove toggled index
                    else Set.add toggled index))
               (fun collapsible ->
                  [ Collapsible.trigger
                      ~attrs:[ Attr.create "data-sidebar" "group-label" ]
                      ~class_:
                        (Sidebar.group_label_classes
                           ~class_:
                             "group/label w-full text-sm \
                              text-sidebar-foreground hover:bg-sidebar-accent \
                              hover:text-sidebar-accent-foreground"
                           ())
                      collapsible
                      [ Node.text name
                      ; Node.text " "
                      ; Icon.view
                          ~class_:
                            "ml-auto transition-transform \
                             group-data-[state=open]/collapsible:rotate-90"
                          Chevron_right
                      ]
                  ; Collapsible.content
                      collapsible
                      [ Sidebar.group_content
                          [ Sidebar.menu
                              (List.mapi items ~f:(fun index item ->
                                 Sidebar.menu_item
                                   [ Sidebar.menu_button
                                       [ Node.div
                                           ~attrs:
                                             [ Attr.create
                                                 "data-active"
                                                 (Bool.to_string (index < 2))
                                             ; Attr.class_
                                                 "group/calendar-item flex \
                                                  aspect-square size-4 shrink-0 \
                                                  items-center justify-center \
                                                  rounded-xs border \
                                                  border-sidebar-border \
                                                  text-sidebar-primary-foreground \
                                                  data-[active=true]:border-sidebar-primary \
                                                  data-[active=true]:bg-sidebar-primary"
                                             ]
                                           [ Icon.view
                                               ~class_:
                                                 "hidden size-3 \
                                                  group-data-[active=true]/calendar-item:block"
                                               Check
                                           ]
                                       ; Node.text item
                                       ]
                                   ]))
                          ]
                      ]
                  ])
           ]
       ; Sidebar.separator ~class_:"mx-0" ()
       ]))
;;

let sidebar_left ~sidebar (local_ graph) =
  let team_switcher = team_switcher graph in
  let nav_favorites = nav_favorites ~sidebar graph in
  let nav_workspaces = nav_workspaces graph in
  let%arr sidebar and team_switcher and nav_favorites and nav_workspaces in
  Sidebar.root
    ~class_:"border-r-0"
    sidebar
    [ Sidebar.header [ team_switcher; nav_main nav_main_items ]
    ; Sidebar.content
        [ nav_favorites
        ; nav_workspaces
        ; nav_secondary ~class_:"mt-auto" nav_secondary_items
        ]
    ; Sidebar.rail sidebar
    ]
;;

let sidebar_right ~sidebar (local_ graph) =
  let nav_user = nav_user ~sidebar ~user graph in
  let date_picker = date_picker graph in
  let calendars = calendars_view graph in
  let%arr sidebar and nav_user and date_picker and calendars in
  Sidebar.root
    ~collapsible:None
    ~class_:"sticky top-0 hidden h-svh border-l lg:flex"
    sidebar
    [ Sidebar.header ~class_:"h-16 border-b border-sidebar-border" [ nav_user ]
    ; Sidebar.content
        [ date_picker; Sidebar.separator ~class_:"mx-0" (); calendars ]
    ; Sidebar.footer
        [ Sidebar.menu
            [ Sidebar.menu_item
                [ Sidebar.menu_button
                    [ Icon.view Plus; Node.span [ Node.text "New Calendar" ] ]
                ]
            ]
        ]
    ]
;;

let view (local_ graph) =
  let sidebar = Sidebar.component graph in
  let sidebar_left = sidebar_left ~sidebar graph in
  let sidebar_right = sidebar_right ~sidebar graph in
  let%arr sidebar and sidebar_left and sidebar_right in
  Sidebar.provider
    sidebar
    [ sidebar_left
    ; Sidebar.inset
        [ Node.header
            ~attrs:
              [ Attr.class_
                  "sticky top-0 flex h-14 shrink-0 items-center gap-2 \
                   bg-background"
              ]
            [ Node.div
                ~attrs:[ Attr.class_ "flex flex-1 items-center gap-2 px-3" ]
                [ Sidebar.trigger sidebar
                ; Separator.view
                    ~orientation:Vertical
                    ~class_:"mr-2 data-[orientation=vertical]:h-4"
                    ()
                ; Breadcrumb.root
                    [ Breadcrumb.list
                        [ Breadcrumb.item
                            [ Breadcrumb.page
                                ~class_:"line-clamp-1"
                                [ Node.text "Project Management & Task Tracking" ]
                            ]
                        ]
                    ]
                ]
            ]
        ; Node.div
            ~attrs:[ Attr.class_ "flex flex-1 flex-col gap-4 p-4" ]
            [ Node.div
                ~attrs:
                  [ Attr.class_
                      "mx-auto h-24 w-full max-w-3xl rounded-xl bg-muted/50"
                  ]
                []
            ; Node.div
                ~attrs:
                  [ Attr.class_
                      "mx-auto h-[100vh] w-full max-w-3xl rounded-xl bg-muted/50"
                  ]
                []
            ]
        ]
    ; sidebar_right
    ]
;;
