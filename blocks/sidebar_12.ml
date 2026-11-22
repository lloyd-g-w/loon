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
      ~class_:"bg-transparent [--cell-size:2.1rem]"
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
                                                  rounded-sm border \
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

let app_sidebar ~sidebar (local_ graph) =
  let nav_user = nav_user ~sidebar ~user graph in
  let date_picker = date_picker graph in
  let calendars = calendars_view graph in
  let%arr sidebar and nav_user and date_picker and calendars in
  Sidebar.root
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
    ; Sidebar.rail sidebar
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
              [ Attr.class_
                  "sticky top-0 flex h-16 shrink-0 items-center gap-2 \
                   border-b bg-background px-4"
              ]
            [ Sidebar.trigger ~class_:"-ml-1" sidebar
            ; Separator.view
                ~orientation:Vertical
                ~class_:"mr-2 data-vertical:h-4 data-vertical:self-auto"
                ()
            ; Breadcrumb.root
                [ Breadcrumb.list
                    [ Breadcrumb.item
                        [ Breadcrumb.page [ Node.text "October 2024" ] ]
                    ]
                ]
            ]
        ; Node.div
            ~attrs:[ Attr.class_ "flex flex-1 flex-col gap-4 p-4" ]
            [ Node.div
                ~attrs:[ Attr.class_ "grid auto-rows-min gap-4 md:grid-cols-5" ]
                (List.init 20 ~f:(fun _ ->
                   Node.div
                     ~attrs:[ Attr.class_ "aspect-square rounded-xl bg-muted/50" ]
                     []))
            ]
        ]
    ]
;;
