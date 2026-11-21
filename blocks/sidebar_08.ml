open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

(* This is sample data. *)
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
    ; items : (string * string) list (** title, url *)
    }
end

module Nav_secondary_item = struct
  type t =
    { title : string
    ; url : string
    ; icon : Icon.t
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
  { User.name = "shadcn"; email = "m@example.com"; avatar = "avatars/shadcn.jpg" }
;;

let nav_main_data =
  [ { Nav_item.title = "Playground"
    ; url = "#"
    ; icon = Square_terminal
    ; is_active = true
    ; items = [ "History", "#"; "Starred", "#"; "Settings", "#" ]
    }
  ; { title = "Models"
    ; url = "#"
    ; icon = Bot
    ; is_active = false
    ; items = [ "Genesis", "#"; "Explorer", "#"; "Quantum", "#" ]
    }
  ; { title = "Documentation"
    ; url = "#"
    ; icon = Book_open
    ; is_active = false
    ; items =
        [ "Introduction", "#"
        ; "Get Started", "#"
        ; "Tutorials", "#"
        ; "Changelog", "#"
        ]
    }
  ; { title = "Settings"
    ; url = "#"
    ; icon = Settings_2
    ; is_active = false
    ; items = [ "General", "#"; "Team", "#"; "Billing", "#"; "Limits", "#" ]
    }
  ]
;;

let nav_secondary_data =
  [ { Nav_secondary_item.title = "Support"; url = "#"; icon = Life_buoy }
  ; { title = "Feedback"; url = "#"; icon = Send }
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
    ([ Sidebar.menu_button
         ~href:item.url
         ~tooltip:(Sidebar.menu_tooltip sidebar item.title)
         [ Icon.view item.icon; Node.span [ Node.text item.title ] ]
     ]
     @
     if List.is_empty item.items
     then []
     else
       [ Slot.merge
           ~defaults:
             [ "data-slot", Attr.create "data-slot" "collapsible-trigger" ]
           (Collapsible.trigger_attrs collapsible)
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
               (List.map item.items ~f:(fun (title, url) ->
                  Sidebar.menu_sub_item
                    [ Sidebar.menu_sub_button
                        ~href:url
                        [ Node.span [ Node.text title ] ]
                    ]))
           ]
       ])
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
                   [ Icon.view Ellipsis
                   ; Node.span [ Node.text "More" ]
                   ]
               ]
           ])
    ]
;;

let nav_secondary ?class_ ~items () =
  Sidebar.group
    ?class_
    [ Sidebar.group_content
        [ Sidebar.menu
            (List.map items ~f:(fun (item : Nav_secondary_item.t) ->
               Sidebar.menu_item
                 [ Sidebar.menu_button
                     ~size:Sm
                     ~href:item.url
                     [ Icon.view item.icon; Node.span [ Node.text item.title ] ]
                 ]))
        ]
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

let app_sidebar ~sidebar (local_ graph) =
  let nav_main = nav_main ~sidebar ~items:nav_main_data graph in
  let nav_projects = nav_projects ~sidebar ~projects graph in
  let nav_user = nav_user ~sidebar ~user graph in
  let%arr sidebar and nav_main and nav_projects and nav_user in
  Sidebar.root
    ~variant:Inset
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
        ; nav_secondary ~items:nav_secondary_data ~class_:"mt-auto" ()
        ]
    ; Sidebar.footer [ nav_user ]
    ]
;;

let view (local_ graph) =
  let sidebar = Sidebar.component graph in
  let app_sidebar = app_sidebar ~sidebar graph in
  let%arr sidebar and app_sidebar in
  Sidebar.provider
    sidebar
    [ app_sidebar
    ; Sidebar.inset
        [ Node.header
            ~attrs:
              [ Attr.class_ "flex h-16 shrink-0 items-center gap-2" ]
            [ Node.div
                ~attrs:[ Attr.class_ "flex items-center gap-2 px-4" ]
                [ Sidebar.trigger ~class_:"-ml-1" sidebar
                ; Separator.view
                    ~orientation:Vertical
                    ~class_:"mr-2 data-[orientation=vertical]:h-4"
                    ()
                ; Breadcrumb.root
                    [ Breadcrumb.list
                        [ Breadcrumb.item
                            ~class_:"hidden md:block"
                            [ Breadcrumb.link
                                ~href:"#"
                                [ Node.text "Build Your Application" ]
                            ]
                        ; Breadcrumb.separator ~class_:"hidden md:block" ()
                        ; Breadcrumb.item
                            [ Breadcrumb.page [ Node.text "Data Fetching" ] ]
                        ]
                    ]
                ]
            ]
        ; Node.div
            ~attrs:[ Attr.class_ "flex flex-1 flex-col gap-4 p-4 pt-0" ]
            [ Node.div
                ~attrs:
                  [ Attr.class_ "grid auto-rows-min gap-4 md:grid-cols-3" ]
                [ Node.div
                    ~attrs:[ Attr.class_ "aspect-video rounded-xl bg-muted/50" ]
                    []
                ; Node.div
                    ~attrs:[ Attr.class_ "aspect-video rounded-xl bg-muted/50" ]
                    []
                ; Node.div
                    ~attrs:[ Attr.class_ "aspect-video rounded-xl bg-muted/50" ]
                    []
                ]
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
;;
