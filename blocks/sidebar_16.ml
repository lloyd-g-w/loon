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

module Nav_item = struct
  type t =
    { title : string
    ; url : string
    ; icon : Icon.t
    ; is_active : bool
    ; items : string list
    }

  let make ?(is_active = false) ?(items = []) title icon =
    { title; url = "#"; icon; is_active; items }
  ;;
end

(* This is sample data. *)
let user =
  { User.name = "shadcn"; email = "m@example.com"; avatar = "avatars/shadcn.jpg" }
;;

let nav_main_items =
  Nav_item.
    [ make
        ~is_active:true
        ~items:[ "History"; "Starred"; "Settings" ]
        "Playground"
        Square_terminal
    ; make ~items:[ "Genesis"; "Explorer"; "Quantum" ] "Models" Bot
    ; make
        ~items:[ "Introduction"; "Get Started"; "Tutorials"; "Changelog" ]
        "Documentation"
        Book_open
    ; make ~items:[ "General"; "Team"; "Billing"; "Limits" ] "Settings" Settings_2
    ]
;;

let nav_secondary_items =
  Nav_item.[ make "Support" Life_buoy; make "Feedback" Send ]
;;

let projects : (string * Icon.t) list =
  [ "Design Engineering", Frame; "Sales & Marketing", Chart_pie; "Travel", Map ]
;;

let nav_main ~sidebar (local_ graph) =
  (* The items opened or closed from their default ([is_active]). *)
  let toggled, set_toggled = Bonsai.state String.Set.empty graph in
  let%arr toggled and set_toggled and sidebar in
  Sidebar.group
    [ Sidebar.group_label [ Node.text "Platform" ]
    ; Sidebar.menu
        (List.mapi nav_main_items ~f:(fun index (item : Nav_item.t) ->
           let collapsible =
             Collapsible.create
               ~id:(sprintf "nav-main-%d" index)
               ~open_:(Bool.( <> ) item.is_active (Set.mem toggled item.title))
               ~on_change:(fun _ ->
                 set_toggled
                   (if Set.mem toggled item.title
                    then Set.remove toggled item.title
                    else Set.add toggled item.title))
               ()
           in
           Sidebar.menu_item
             ~attrs:(Collapsible.root_attrs collapsible)
             ([ Sidebar.menu_button
                  ~href:item.url
                  ~tooltip:(Sidebar.menu_tooltip sidebar item.title)
                  [ Icon.view item.icon; Node.span [ Node.text item.title ] ]
              ]
              @
              if List.is_empty item.items
              then []
              else
                [ Collapsible.trigger_child
                    collapsible
                    (Sidebar.menu_action
                       ~class_:"data-[state=open]:rotate-90"
                       [ Icon.view Chevron_right
                       ; Node.span
                           ~attrs:[ Attr.class_ "sr-only" ]
                           [ Node.text "Toggle" ]
                       ])
                ; Collapsible.content
                    collapsible
                    [ Sidebar.menu_sub
                        (List.map item.items ~f:(fun title ->
                           Sidebar.menu_sub_item
                             [ Sidebar.menu_sub_button
                                 ~href:"#"
                                 [ Node.span [ Node.text title ] ]
                             ]))
                    ]
                ])))
    ]
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

let nav_projects ~sidebar (local_ graph) =
  let open_menu, set_open_menu = Bonsai.state None graph in
  let%arr sidebar and open_menu and set_open_menu in
  let is_mobile = Sidebar.is_mobile sidebar in
  Sidebar.group
    ~class_:"group-data-[collapsible=icon]:hidden"
    [ Sidebar.group_label [ Node.text "Projects" ]
    ; Sidebar.menu
        (List.mapi projects ~f:(fun index (name, icon) ->
           Sidebar.menu_item
             [ Sidebar.menu_button
                 ~href:"#"
                 [ Icon.view icon; Node.span [ Node.text name ] ]
             ; row_menu
                 ~open_menu
                 ~set_open_menu
                 ~id:(sprintf "project-%d" index)
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
                        ~class_:"w-48"
                        ~side:(if is_mobile then Bottom else Right)
                        ~align:(if is_mobile then End else Start)
                        [ Dropdown_menu.item
                            [ Icon.view ~class_:"text-muted-foreground" Folder
                            ; Node.span [ Node.text "View Project" ]
                            ]
                        ; Dropdown_menu.item
                            [ Icon.view ~class_:"text-muted-foreground" Share
                            ; Node.span [ Node.text "Share Project" ]
                            ]
                        ; Dropdown_menu.separator ()
                        ; Dropdown_menu.item
                            [ Icon.view ~class_:"text-muted-foreground" Trash
                            ; Node.span [ Node.text "Delete Project" ]
                            ]
                        ]
                    ])
             ])
         @ [ Sidebar.menu_item
               [ Sidebar.menu_button
                   [ Icon.view Ellipsis; Node.span [ Node.text "More" ] ]
               ]
           ])
    ]
;;

let nav_secondary ?class_ items =
  Sidebar.group
    ?class_
    [ Sidebar.group_content
        [ Sidebar.menu
            (List.map items ~f:(fun (item : Nav_item.t) ->
               Sidebar.menu_item
                 [ Sidebar.menu_button
                     ~href:item.url
                     ~size:Sm
                     [ Icon.view item.icon; Node.span [ Node.text item.title ] ]
                 ]))
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

let search_form ?class_ ~value ~on_input () =
  Node.form
    ~attrs:
      ([ Attr.on_submit (fun ev -> Effect.of_thunk (fun () -> ev##preventDefault)) ]
       @ Option.value_map class_ ~default:[] ~f:(fun c -> [ Attr.class_ c ]))
    [ Node.div
        ~attrs:[ Attr.class_ "relative" ]
        [ Label.view ~for_:"search" ~class_:"sr-only" [ Node.text "Search" ]
        ; Sidebar.input
            ~attrs:[ Attr.id "search" ]
            ~placeholder:"Type to search..."
            ~class_:"h-8 pl-7"
            ~value
            ~on_input
            ()
        ; Icon.view
            ~class_:
              "pointer-events-none absolute top-1/2 left-2 size-4 \
               -translate-y-1/2 opacity-50 select-none"
            Search
        ]
    ]
;;

let site_header ~sidebar (local_ graph) =
  let search, set_search = Bonsai.state "" graph in
  let%arr sidebar and search and set_search in
  Node.header
    ~attrs:
      [ Attr.class_
          "sticky top-0 z-50 flex w-full items-center border-b bg-background"
      ]
    [ Node.div
        ~attrs:
          [ Attr.class_ "flex h-(--header-height) w-full items-center gap-2 px-4" ]
        [ Button.view
            ~class_:"h-8 w-8"
            ~variant:Ghost
            ~size:Icon
            ~on_click:(Sidebar.toggle sidebar)
            [ Icon.view Panel_left ]
        ; Separator.view ~orientation:Vertical ~class_:"mr-2 h-4" ()
        ; Breadcrumb.root
            ~class_:"hidden sm:block"
            [ Breadcrumb.list
                [ Breadcrumb.item
                    [ Breadcrumb.link
                        ~href:"#"
                        [ Node.text "Build Your Application" ]
                    ]
                ; Breadcrumb.separator ()
                ; Breadcrumb.item [ Breadcrumb.page [ Node.text "Data Fetching" ] ]
                ]
            ]
        ; search_form
            ~class_:"w-full sm:ml-auto sm:w-auto"
            ~value:search
            ~on_input:set_search
            ()
        ]
    ]
;;

let app_sidebar ~sidebar (local_ graph) =
  let nav_main = nav_main ~sidebar graph in
  let nav_projects = nav_projects ~sidebar graph in
  let nav_user = nav_user ~sidebar ~user graph in
  let%arr sidebar and nav_main and nav_projects and nav_user in
  Sidebar.root
    ~class_:"top-(--header-height) h-[calc(100svh-var(--header-height))]!"
    sidebar
    [ Sidebar.header
        [ Sidebar.menu
            [ Sidebar.menu_item
                [ Sidebar.menu_button
                    ~size:Lg
                    ~href:"#"
                    [ Node.div
                        ~attrs:
                          [ Attr.class_
                              "flex aspect-square size-8 items-center \
                               justify-center rounded-lg bg-sidebar-primary \
                               text-sidebar-primary-foreground"
                          ]
                        [ Icon.view ~class_:"size-4" Command ]
                    ; Node.div
                        ~attrs:
                          [ Attr.class_
                              "grid flex-1 text-left text-sm leading-tight"
                          ]
                        [ Node.span
                            ~attrs:[ Attr.class_ "truncate font-medium" ]
                            [ Node.text "Acme Inc" ]
                        ; Node.span
                            ~attrs:[ Attr.class_ "truncate text-xs" ]
                            [ Node.text "Enterprise" ]
                        ]
                    ]
                ]
            ]
        ]
    ; Sidebar.content
        [ nav_main
        ; nav_projects
        ; nav_secondary ~class_:"mt-auto" nav_secondary_items
        ]
    ; Sidebar.footer [ nav_user ]
    ]
;;

let view (local_ graph) =
  let sidebar = Sidebar.component graph in
  let site_header = site_header ~sidebar graph in
  let app_sidebar = app_sidebar ~sidebar graph in
  let%arr sidebar and site_header and app_sidebar in
  Node.div
    ~attrs:[ Attr.class_ "[--header-height:calc(--spacing(14))]" ]
    [ Sidebar.provider
        ~class_:"flex flex-col"
        sidebar
        [ site_header
        ; Node.div
            ~attrs:[ Attr.class_ "flex flex-1" ]
            [ app_sidebar
            ; Sidebar.inset
                [ Node.div
                    ~attrs:[ Attr.class_ "flex flex-1 flex-col gap-4 p-4" ]
                    [ Node.div
                        ~attrs:
                          [ Attr.class_ "grid auto-rows-min gap-4 md:grid-cols-3" ]
                        (List.init 3 ~f:(fun _ ->
                           Node.div
                             ~attrs:
                               [ Attr.class_ "aspect-video rounded-xl bg-muted/50" ]
                             []))
                    ; Node.div
                        ~attrs:
                          [ Attr.class_
                              "min-h-[100vh] flex-1 rounded-xl bg-muted/50 \
                               md:min-h-min"
                          ]
                        []
                    ]
                ]
            ]
        ]
    ]
;;
