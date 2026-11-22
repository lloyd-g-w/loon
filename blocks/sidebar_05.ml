open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

(* This is sample data. *)
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

let logo () =
  Sidebar.menu
    [ Sidebar.menu_item
        [ Sidebar.menu_button
            ~size:Lg
            ~href:"#"
            [ Node.div
                ~attrs:
                  [ Attr.class_
                      "flex aspect-square size-8 items-center justify-center \
                       rounded-lg bg-sidebar-primary \
                       text-sidebar-primary-foreground"
                  ]
                [ Icon.view ~class_:"size-4" Gallery_vertical_end ]
            ; Node.div
                ~attrs:[ Attr.class_ "flex flex-col gap-0.5 leading-none" ]
                [ Node.span
                    ~attrs:[ Attr.class_ "font-medium" ]
                    [ Node.text "Documentation" ]
                ; Node.span ~attrs:[ Attr.class_ "" ] [ Node.text "v1.0.0" ]
                ]
            ]
        ]
    ]
;;

(* A parent's collapsible menu item; the second is open at first. *)
let nav_item ~index (title, items) (local_ graph) =
  Collapsible.component
    ~default_open:(index = 1)
    ~class_:"group/collapsible"
    (Bonsai.return (fun collapsible ->
       [ Sidebar.menu_item
           [ Collapsible.trigger_child
               collapsible
               (Sidebar.menu_button
                  [ Node.text (title ^ " ")
                  ; Icon.view
                      ~class_:"ml-auto group-data-[state=open]/collapsible:hidden"
                      Plus
                  ; Icon.view
                      ~class_:
                        "ml-auto group-data-[state=closed]/collapsible:hidden"
                      Minus
                  ])
           ; (if List.is_empty items
              then Node.none
              else
                Collapsible.content
                  collapsible
                  [ Sidebar.menu_sub
                      (List.map items ~f:(fun (title, is_active) ->
                         Sidebar.menu_sub_item
                           [ Sidebar.menu_sub_button
                               ~is_active
                               ~href:"#"
                               [ Node.text title ]
                           ]))
                  ])
           ]
       ]))
    graph
;;

let app_sidebar (local_ graph) =
  let items =
    Bonsai.all (List.mapi nav_main ~f:(fun index item -> nav_item ~index item graph))
  in
  let%arr items in
  fun sidebar ->
    Sidebar.root
      sidebar
      [ Sidebar.header [ logo (); search_form () ]
      ; Sidebar.content [ Sidebar.group [ Sidebar.menu items ] ]
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
              [ Attr.class_ "flex h-16 shrink-0 items-center gap-2 border-b px-4" ]
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
        ; Node.div
            ~attrs:[ Attr.class_ "flex flex-1 flex-col gap-4 p-4" ]
            [ Node.div
                ~attrs:[ Attr.class_ "grid auto-rows-min gap-4 md:grid-cols-3" ]
                [ Node.div ~attrs:[ Attr.class_ "aspect-video rounded-xl bg-muted/50" ] []
                ; Node.div ~attrs:[ Attr.class_ "aspect-video rounded-xl bg-muted/50" ] []
                ; Node.div ~attrs:[ Attr.class_ "aspect-video rounded-xl bg-muted/50" ] []
                ]
            ; Node.div
                ~attrs:
                  [ Attr.class_
                      "min-h-[100vh] flex-1 rounded-xl bg-muted/50 md:min-h-min"
                  ]
                []
            ]
        ]
    ]
;;
