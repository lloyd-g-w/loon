open! Core
open Bonsai_web
open Loon
open Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "sidebar"

(* The examples run in a frame on this page: their sidebars are [absolute]
   in it rather than [fixed] to the window. *)
let frame children =
  Node.div
    ~attrs:
      [ Attr.class_
          "relative flex h-[600px] w-full overflow-hidden rounded-lg border \
           [&_[data-slot=sidebar-container]]:absolute \
           [&_[data-slot=sidebar-container]]:h-full"
      ]
    children
;;

(*$ Demo
   A sidebar that collapses to icons. *)
(* This is sample data. *)
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
    ; plan : string
    }
end

module Nav_item = struct
  type t =
    { title : string
    ; icon : Icon.t option
    ; is_active : bool
    ; items : (string * string) list (** title, url *)
    }
end

module Project = struct
  type t =
    { name : string
    ; url : string
    ; icon : Icon.t
    }
end

let user =
  { User.name = "shadcn"; email = "m@example.com"; avatar = "https://github.com/shadcn.png" }
;;

let teams =
  [ { Team.name = "Acme Inc"; logo = Gallery_vertical_end; plan = "Enterprise" }
  ; { name = "Acme Corp."; logo = Audio_waveform; plan = "Startup" }
  ; { name = "Evil Corp."; logo = Command; plan = "Free" }
  ]
;;

let nav_main_data =
  [ { Nav_item.title = "Playground"
    ; icon = Some Square_terminal
    ; is_active = true
    ; items = [ "History", "#"; "Starred", "#"; "Settings", "#" ]
    }
  ; { title = "Models"
    ; icon = Some Bot
    ; is_active = false
    ; items = [ "Genesis", "#"; "Explorer", "#"; "Quantum", "#" ]
    }
  ; { title = "Documentation"
    ; icon = Some Book_open
    ; is_active = false
    ; items =
        [ "Introduction", "#"
        ; "Get Started", "#"
        ; "Tutorials", "#"
        ; "Changelog", "#"
        ]
    }
  ; { title = "Settings"
    ; icon = Some Settings_2
    ; is_active = false
    ; items = [ "General", "#"; "Team", "#"; "Billing", "#"; "Limits", "#" ]
    }
  ]
;;

let projects =
  [ { Project.name = "Design Engineering"; url = "#"; icon = Frame }
  ; { name = "Sales & Marketing"; url = "#"; icon = Chart_pie }
  ; { name = "Travel"; url = "#"; icon = Map }
  ]
;;

(* Each section is a collapsible menu item, open at first if active:
   shadcn's [<Collapsible asChild>] over the [SidebarMenuItem], whose
   [data-slot] the Collapsible's replaces, as in shadcn. *)
let nav_main_item ~sidebar (item : Nav_item.t) (local_ graph) =
  let open_, set_open = Bonsai.state item.is_active graph in
  let id = Bonsai.path_id graph in
  let%arr open_ and set_open and id and sidebar in
  let collapsible = Collapsible.create ~id ~open_ ~on_change:set_open () in
  Slot.merge
    ~defaults:[ "data-slot", Attr.create "data-slot" "collapsible" ]
    (Collapsible.root_attrs collapsible)
  @@ Sidebar.menu_item
    ~class_:"group/collapsible"
    [ Collapsible.trigger_child
        collapsible
        (Sidebar.menu_button
           ~tooltip:(Sidebar.menu_tooltip sidebar item.title)
           [ (match item.icon with
              | Some icon -> Icon.view icon
              | None -> Node.none)
           ; Node.span [ Node.text item.title ]
           ; Icon.view
               ~class_:
                 "ml-auto transition-transform duration-200 \
                  group-data-[state=open]/collapsible:rotate-90"
               Chevron_right
           ])
    ; Collapsible.content
        collapsible
        [ Sidebar.menu_sub
            (List.map item.items ~f:(fun (title, url) ->
               Sidebar.menu_sub_item
                 [ Sidebar.menu_sub_button
                     ~href:url
                     [ Node.span [ Node.text title ] ]
                 ]))
        ]
    ]
;;

let nav_main ~sidebar ~items (local_ graph) =
  let items =
    Bonsai.all (List.map items ~f:(fun item -> nav_main_item ~sidebar item graph))
  in
  let%arr items in
  Sidebar.group
    [ Sidebar.group_label [ Node.text "Platform" ]; Sidebar.menu items ]
;;

let nav_project ~sidebar (item : Project.t) (local_ graph) =
  let menu =
    Dropdown_menu.component
      (let%arr sidebar in
       fun menu ->
         let is_mobile = Sidebar.is_mobile sidebar in
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
             ~class_:"w-48 rounded-lg"
             ~side:(if is_mobile then Bottom else Right)
             ~align:(if is_mobile then End else Start)
             [ Dropdown_menu.item
                 [ Icon.view ~class_:"text-muted-foreground" Folder
                 ; Node.span [ Node.text "View Project" ]
                 ]
             ; Dropdown_menu.item
                 [ Icon.view ~class_:"text-muted-foreground" Forward
                 ; Node.span [ Node.text "Share Project" ]
                 ]
             ; Dropdown_menu.separator ()
             ; Dropdown_menu.item
                 [ Icon.view ~class_:"text-muted-foreground" Trash
                 ; Node.span [ Node.text "Delete Project" ]
                 ]
             ]
         ])
      graph
  in
  let%arr menu in
  Sidebar.menu_item
    [ Sidebar.menu_button
        ~href:item.url
        [ Icon.view item.icon; Node.span [ Node.text item.name ] ]
    ; menu
    ]
;;

let nav_projects ~sidebar ~projects (local_ graph) =
  let items =
    Bonsai.all
      (List.map projects ~f:(fun item -> nav_project ~sidebar item graph))
  in
  let%arr items in
  Sidebar.group
    ~class_:"group-data-[collapsible=icon]:hidden"
    [ Sidebar.group_label [ Node.text "Projects" ]
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

let user_avatar ~(user : User.t) (local_ graph) =
  Avatar.component
    ~class_:"h-8 w-8 rounded-lg"
    (Bonsai.return (fun avatar ->
       [ Avatar.image avatar ~src:user.avatar ~alt:user.name ()
       ; Avatar.fallback avatar ~class_:"rounded-lg" [ Node.text "CN" ]
       ]))
    graph
;;

let nav_user ~sidebar ~(user : User.t) (local_ graph) =
  let trigger_avatar = user_avatar ~user graph in
  let label_avatar = user_avatar ~user graph in
  let menu =
    Dropdown_menu.component
      (let%arr sidebar and trigger_avatar and label_avatar in
       fun menu ->
         let name_and_email =
           Node.div
             ~attrs:[ Attr.class_ "grid flex-1 text-left text-sm leading-tight" ]
             [ Node.span
                 ~attrs:[ Attr.class_ "truncate font-medium" ]
                 [ Node.text user.name ]
             ; Node.span
                 ~attrs:[ Attr.class_ "truncate text-xs" ]
                 [ Node.text user.email ]
             ]
         in
         [ Dropdown_menu.trigger
             menu
             (Sidebar.menu_button
                ~size:Lg
                ~class_:
                  "data-[state=open]:bg-sidebar-accent \
                   data-[state=open]:text-sidebar-accent-foreground"
                [ trigger_avatar
                ; name_and_email
                ; Icon.view ~class_:"ml-auto size-4" Chevrons_up_down
                ])
         ; Dropdown_menu.content
             menu
             ~class_:
               "w-(--radix-dropdown-menu-trigger-width) min-w-56 rounded-lg"
             ~side:(if Sidebar.is_mobile sidebar then Bottom else Right)
             ~align:End
             ~side_offset:4.
             [ Dropdown_menu.label
                 ~class_:"p-0 font-normal"
                 [ Node.div
                     ~attrs:
                       [ Attr.class_
                           "flex items-center gap-2 px-1 py-1.5 text-left \
                            text-sm"
                       ]
                     [ label_avatar; name_and_email ]
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

let team_switcher ~sidebar ~teams (local_ graph) =
  let active_team, set_active_team =
    Bonsai.state (List.hd_exn teams) graph
  in
  let menu =
    Dropdown_menu.component
      (let%arr sidebar and active_team and set_active_team in
       fun menu ->
         [ Dropdown_menu.trigger
             menu
             (Sidebar.menu_button
                ~size:Lg
                ~class_:
                  "data-[state=open]:bg-sidebar-accent \
                   data-[state=open]:text-sidebar-accent-foreground"
                [ Node.div
                    ~attrs:
                      [ Attr.class_
                          "flex aspect-square size-8 items-center \
                           justify-center rounded-lg bg-sidebar-primary \
                           text-sidebar-primary-foreground"
                      ]
                    [ Icon.view ~class_:"size-4" active_team.Team.logo ]
                ; Node.div
                    ~attrs:
                      [ Attr.class_ "grid flex-1 text-left text-sm leading-tight" ]
                    [ Node.span
                        ~attrs:[ Attr.class_ "truncate font-medium" ]
                        [ Node.text active_team.name ]
                    ; Node.span
                        ~attrs:[ Attr.class_ "truncate text-xs" ]
                        [ Node.text active_team.plan ]
                    ]
                ; Icon.view ~class_:"ml-auto" Chevrons_up_down
                ])
         ; Dropdown_menu.content
             menu
             ~class_:
               "w-(--radix-dropdown-menu-trigger-width) min-w-56 rounded-lg"
             ~align:Start
             ~side:(if Sidebar.is_mobile sidebar then Bottom else Right)
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
                             rounded-md border"
                        ]
                      [ Icon.view ~class_:"size-3.5 shrink-0" team.logo ]
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
                               rounded-md border bg-transparent"
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

let app_sidebar ~sidebar (local_ graph) =
  let team_switcher = team_switcher ~sidebar ~teams graph in
  let nav_main = nav_main ~sidebar ~items:nav_main_data graph in
  let nav_projects = nav_projects ~sidebar ~projects graph in
  let nav_user = nav_user ~sidebar ~user graph in
  let%arr sidebar
  and team_switcher
  and nav_main
  and nav_projects
  and nav_user in
  Sidebar.root
    ~collapsible:Icon
    sidebar
    [ Sidebar.header [ team_switcher ]
    ; Sidebar.content [ nav_main; nav_projects ]
    ; Sidebar.footer [ nav_user ]
    ; Sidebar.rail sidebar
    ]
;;

let demo (local_ graph) =
  let sidebar = Sidebar.component graph in
  let app_sidebar = app_sidebar ~sidebar graph in
  let%arr sidebar and app_sidebar in
  frame
    [ Sidebar.provider
        ~class_:"min-h-0"
        sidebar
        [ app_sidebar
        ; Sidebar.inset
            [ Node.header
                ~attrs:
                  [ Attr.class_
                      "flex h-16 shrink-0 items-center gap-2 \
                       transition-[width,height] ease-linear \
                       group-has-data-[collapsible=icon]/sidebar-wrapper:h-12"
                  ]
                [ Node.div
                    ~attrs:[ Attr.class_ "flex items-center gap-2 px-4" ]
                    [ Sidebar.trigger ~class_:"-ml-1" sidebar ]
                ]
            ]
        ]
    ]
;;

(*$*)

(*$ Variants
   [variant], [collapsible] and [side]: pick them, then collapse the
   sidebar with its trigger (or Ctrl+B). *)
let variants (local_ graph) =
  let sidebar = Sidebar.component ~persist:false graph in
  let variant, set_variant = Bonsai.state Sidebar.Variant.Inset graph in
  let collapsible, set_collapsible =
    Bonsai.state Sidebar.Collapsible.Icon graph
  in
  let side, set_side = Bonsai.state Sidebar.Side.Left graph in
  let%arr sidebar
  and variant
  and set_variant
  and collapsible
  and set_collapsible
  and side
  and set_side in
  let choices name all current set to_string =
    Node.div
      ~attrs:[ Attr.class_ "flex flex-wrap items-center gap-2" ]
      (Node.span
         ~attrs:[ Attr.class_ "w-20 text-sm text-muted-foreground" ]
         [ Node.text name ]
       :: List.map all ~f:(fun x ->
         Button.view
           ~size:Sm
           ~variant:(if phys_equal x current then Default else Outline)
           ~on_click:(set x)
           [ Node.text (to_string x) ]))
  in
  let items =
    [ "Home", Icon.House, 0
    ; "Inbox", Inbox, 128
    ; "Calendar", Calendar, 0
    ; "Search", Search, 0
    ; "Settings", Settings, 0
    ]
  in
  frame
    [ Sidebar.provider
        ~class_:"min-h-0"
        ~keyboard_shortcut:false
        sidebar
        [ Sidebar.root
            ~variant
            ~collapsible
            ~side
            sidebar
            [ Sidebar.header
                [ Sidebar.input
                    ~placeholder:"Search…"
                    ~value:""
                    ~on_input:(fun _ -> Effect.Ignore)
                    ()
                ]
            ; Sidebar.separator ()
            ; Sidebar.content
                [ Sidebar.group
                    [ Sidebar.group_label [ Node.text "Application" ]
                    ; Sidebar.group_action
                        [ Icon.view Plus
                        ; Node.span
                            ~attrs:[ Attr.class_ "sr-only" ]
                            [ Node.text "Add Project" ]
                        ]
                    ; Sidebar.group_content
                        [ Sidebar.menu
                            (List.map items ~f:(fun (title, icon, count) ->
                               Sidebar.menu_item
                                 ([ Sidebar.menu_button
                                      ~href:"#"
                                      ~tooltip:(Sidebar.menu_tooltip sidebar title)
                                      ~is_active:(String.equal title "Home")
                                      [ Icon.view icon
                                      ; Node.span [ Node.text title ]
                                      ]
                                  ]
                                  @
                                  if count > 0
                                  then
                                    [ Sidebar.menu_badge
                                        [ Node.text (Int.to_string count) ]
                                    ]
                                  else [])))
                        ]
                    ]
                ; Sidebar.group
                    [ Sidebar.group_label [ Node.text "Loading" ]
                    ; Sidebar.menu
                        (List.map [ "70%"; "55%"; "85%" ] ~f:(fun width ->
                           Sidebar.menu_item
                             [ Sidebar.menu_skeleton ~show_icon:true ~width () ]))
                    ]
                ]
            ; Sidebar.rail sidebar
            ]
        ; Sidebar.inset
            [ Node.header
                ~attrs:
                  [ Attr.class_
                      "flex h-12 shrink-0 items-center gap-2 border-b px-4"
                  ]
                [ Sidebar.trigger ~class_:"-ml-1" sidebar
                ; Node.span
                    ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ]
                    [ Node.text (Sidebar.State.name (Sidebar.state sidebar)) ]
                ]
            ; Node.div
                ~attrs:[ Attr.class_ "flex flex-1 flex-col gap-3 p-4" ]
                [ choices
                    "variant"
                    Sidebar.Variant.all
                    variant
                    set_variant
                    Sidebar.Variant.name
                ; choices
                    "collapsible"
                    Sidebar.Collapsible.all
                    collapsible
                    set_collapsible
                    Sidebar.Collapsible.name
                ; choices
                    "side"
                    Sidebar.Side.all
                    side
                    set_side
                    Sidebar.Side.name
                ; Node.div
                    ~attrs:
                      [ Attr.class_ "grid auto-rows-min gap-4 md:grid-cols-3" ]
                    (List.init 3 ~f:(fun _ ->
                       Node.div
                         ~attrs:
                           [ Attr.class_ "aspect-video rounded-xl bg-muted/50" ]
                         []))
                ]
            ]
        ]
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Sidebar"
    ~description:"A composable, themeable and customizable sidebar component."
    ~body:
      [ Doc.h2 "Structure"
      ; Doc.p
          "[Sidebar.provider] holds the sidebar and the page beside it \
           ([Sidebar.inset]); [Sidebar.root] is the sidebar, with a header, a \
           scrolling content of groups and a footer. [Sidebar.component] keeps \
           whether it is open (in the cookie [sidebar_state]), or \
           [Sidebar.create] takes it from the caller. Below 768px the sidebar \
           is a sheet over the page, opened by [Sidebar.trigger]. Ctrl+B \
           (Cmd+B) toggles it."
      ; Doc.h2 "Sidebar.root"
      ; Doc.props
          [ "side", "Left | Right", "Left"
          ; "variant", "Sidebar | Floating | Inset", "Sidebar"
          ; "collapsible", "Offcanvas | Icon | None", "Offcanvas"
          ]
      ; Doc.h2 "Sidebar.menu_button"
      ; Doc.props
          [ "is_active", "bool", "false"
          ; "variant", "Default | Outline", "Default"
          ; "size", "Default | Sm | Lg", "Default"
          ; "tooltip", "Sidebar.menu_tooltip sidebar text (shown when collapsed to icons)", "none"
          ; "href", "string (an <a> rather than a <button>)", "none"
          ]
      ]
    [ Doc.example ~page "Demo" demo; Doc.example ~page "Variants" variants ]
;;
