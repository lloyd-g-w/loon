open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

(* This is sample data. *)
let versions = [ "1.0.1"; "1.1.0-alpha"; "2.0.0-beta1" ]

(* Each parent's title and its items (title, is_active). *)
let nav_main =
  [ "Getting Started", [ "Installation", false; "Project Structure", false ]
  ; ( "Build Your Application"
    , [ "Routing", false
      ; "Data Fetching", true
      ; "Rendering", false
      ; "Caching", false
      ; "Styling", false
      ; "Optimizing", false
      ; "Configuring", false
      ; "Testing", false
      ; "Authentication", false
      ; "Deploying", false
      ; "Upgrading", false
      ; "Examples", false
      ] )
  ; ( "API Reference"
    , [ "Components", false
      ; "File Conventions", false
      ; "Functions", false
      ; "next.config.js Options", false
      ; "CLI", false
      ; "Edge Runtime", false
      ] )
  ; ( "Architecture"
    , [ "Accessibility", false
      ; "Fast Refresh", false
      ; "Next.js Compiler", false
      ; "Supported Browsers", false
      ; "Turbopack", false
      ] )
  ; "Community", [ "Contribution Guide", false ]
  ]
;;

let version_switcher ~versions ~default_version (local_ graph) =
  let selected_version, set_selected_version =
    Bonsai.state default_version graph
  in
  let menu =
    Dropdown_menu.component
      (let%arr selected_version and set_selected_version in
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
                    [ Icon.view ~class_:"size-4" Gallery_vertical_end ]
                ; Node.div
                    ~attrs:[ Attr.class_ "flex flex-col gap-0.5 leading-none" ]
                    [ Node.span
                        ~attrs:[ Attr.class_ "font-medium" ]
                        [ Node.text "Documentation" ]
                    ; Node.span
                        ~attrs:[ Attr.class_ "" ]
                        [ Node.text ("v" ^ selected_version) ]
                    ]
                ; Icon.view ~class_:"ml-auto" Chevrons_up_down
                ])
         ; Dropdown_menu.content
             menu
             ~class_:"w-(--radix-dropdown-menu-trigger-width)"
             ~align:Start
             (List.map versions ~f:(fun version ->
                Dropdown_menu.item
                  ~on_select:(set_selected_version version)
                  [ Node.text ("v" ^ version ^ " ")
                  ; (if String.equal version selected_version
                     then Icon.view ~class_:"ml-auto" Check
                     else Node.none)
                  ]))
         ])
      graph
  in
  let%arr menu in
  Sidebar.menu [ Sidebar.menu_item [ menu ] ]
;;

let search_form () =
  Node.form
    ~attrs:[ Attr.on_submit Dom_util.prevent_default ]
    [ Sidebar.group
        ~class_:"py-0"
        [ Sidebar.group_content
            ~class_:"relative"
            [ Label.view
                ~for_:"search"
                ~class_:"sr-only"
                [ Node.text "Search" ]
            ; Sidebar.input
                ~id:"search"
                ~placeholder:"Search the docs..."
                ~class_:"pl-8"
                ()
            ; Icon.view
                ~class_:
                  "pointer-events-none absolute top-1/2 left-2 size-4 \
                   -translate-y-1/2 opacity-50 select-none"
                Search
            ]
        ]
    ]
;;

(* A collapsible group for a parent, open at first. *)
let nav_group (title, items) (local_ graph) =
  Collapsible.component
    ~default_open:true
    ~class_:"group/collapsible"
    ~attrs:[ Attr.title title ]
    (Bonsai.return (fun collapsible ->
       [ Sidebar.group
           [ Node.button
               ~attrs:
                 ([ Attr.type_ "button"
                  ; Attr.create "data-slot" "sidebar-group-label"
                  ; Attr.create "data-sidebar" "group-label"
                  ; Attr.class_
                      (Sidebar.group_label_classes
                         ~class_:
                           "group/label text-sm text-sidebar-foreground \
                            hover:bg-sidebar-accent \
                            hover:text-sidebar-accent-foreground"
                         ())
                  ]
                  @ Collapsible.trigger_attrs collapsible)
               [ Node.text (title ^ " ")
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
                       (List.map items ~f:(fun (title, is_active) ->
                          Sidebar.menu_item
                            [ Sidebar.menu_button
                                ~is_active
                                ~href:"#"
                                [ Node.text title ]
                            ]))
                   ]
               ]
           ]
       ]))
    graph
;;

let app_sidebar (local_ graph) =
  let version_switcher =
    version_switcher ~versions ~default_version:(List.hd_exn versions) graph
  in
  (* We create a collapsible SidebarGroup for each parent. *)
  let groups =
    Bonsai.all (List.map nav_main ~f:(fun item -> nav_group item graph))
  in
  let%arr version_switcher and groups in
  fun sidebar ->
    Sidebar.root
      sidebar
      [ Sidebar.header [ version_switcher; search_form () ]
      ; Sidebar.content ~class_:"gap-0" groups
      ; Sidebar.rail sidebar
      ]
;;

let view (local_ graph) =
  let sidebar = Sidebar.component graph in
  let app_sidebar = app_sidebar graph in
  let%arr sidebar and app_sidebar in
  Sidebar.provider
    sidebar
    [ app_sidebar sidebar
    ; Sidebar.inset
        [ Node.header
            ~attrs:
              [ Attr.class_
                  "sticky top-0 flex h-16 shrink-0 items-center gap-2 border-b \
                   bg-background px-4"
              ]
            [ Sidebar.trigger ~class_:"-ml-1" sidebar
            ; Separator.view
                ~orientation:Vertical
                ~class_:"mr-2 data-vertical:h-4 data-vertical:self-auto"
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
        ; Node.div
            ~attrs:[ Attr.class_ "flex flex-1 flex-col gap-4 p-4" ]
            (List.init 24 ~f:(fun _ ->
               Node.div
                 ~attrs:
                   [ Attr.class_ "aspect-video h-12 w-full rounded-lg bg-muted/50" ]
                 []))
        ]
    ]
;;
