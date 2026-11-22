open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

(* This is sample data: each parent's title and its items (title,
   is_active). *)
let nav_main_data =
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
  ]
;;

(* A dropdown menu of a parent's items, beside it (below it on phones). *)
let nav_item ~sidebar (title, items) (local_ graph) =
  Dropdown_menu.component
    (let%arr sidebar in
     fun menu ->
       [ Sidebar.menu_item
           [ Dropdown_menu.trigger
               menu
               (Sidebar.menu_button
                  ~class_:
                    "data-[state=open]:bg-sidebar-accent \
                     data-[state=open]:text-sidebar-accent-foreground"
                  [ Node.text (title ^ " ")
                  ; Icon.view ~class_:"ml-auto" Ellipsis
                  ])
           ; (if List.is_empty items
              then Node.none
              else (
                let is_mobile = Sidebar.is_mobile sidebar in
                Dropdown_menu.content
                  menu
                  ~side:(if is_mobile then Bottom else Right)
                  ~align:(if is_mobile then End else Start)
                  ~class_:"min-w-56 rounded-lg"
                  (List.map items ~f:(fun (title, _) ->
                     Dropdown_menu.item ~href:"#" [ Node.text title ]))))
           ]
       ])
    graph
;;

let nav_main ~sidebar ~items (local_ graph) =
  let items =
    Bonsai.all (List.map items ~f:(fun item -> nav_item ~sidebar item graph))
  in
  let%arr items in
  Sidebar.group [ Sidebar.menu items ]
;;

let sidebar_opt_in_form () =
  Card.root
    ~class_:"gap-2 py-4 shadow-none"
    [ Card.header
        ~class_:"px-4"
        [ Card.title ~class_:"text-sm" [ Node.text "Subscribe to our newsletter" ]
        ; Card.description
            [ Node.text "Opt-in to receive updates and news about the sidebar." ]
        ]
    ; Card.content
        ~class_:"px-4"
        [ Node.form
            ~attrs:[ Attr.on_submit Dom_util.prevent_default ]
            [ Node.div
                ~attrs:[ Attr.class_ "grid gap-2.5" ]
                [ Sidebar.input ~type_:Email ~placeholder:"Email" ()
                ; Button.view
                    ~class_:
                      "w-full bg-sidebar-primary text-sidebar-primary-foreground \
                       shadow-none"
                    ~size:Sm
                    [ Node.text "Subscribe" ]
                ]
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

let app_sidebar ~sidebar (local_ graph) =
  let nav_main = nav_main ~sidebar ~items:nav_main_data graph in
  let%arr nav_main and sidebar in
  Sidebar.root
    sidebar
      [ Sidebar.header [ logo () ]
      ; Sidebar.content [ nav_main ]
      ; Sidebar.footer
          [ Node.div ~attrs:[ Attr.class_ "p-1" ] [ sidebar_opt_in_form () ] ]
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
              [ Attr.class_ "flex h-16 shrink-0 items-center gap-2 border-b px-4" ]
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
            [ Node.div
                ~attrs:[ Attr.class_ "grid auto-rows-min gap-4 md:grid-cols-3" ]
                [ Node.div ~attrs:[ Attr.class_ "aspect-video rounded-xl bg-muted/50" ] []
                ; Node.div ~attrs:[ Attr.class_ "aspect-video rounded-xl bg-muted/50" ] []
                ; Node.div ~attrs:[ Attr.class_ "aspect-video rounded-xl bg-muted/50" ] []
                ]
            ; Node.div
                ~attrs:
                  [ Attr.class_
                      "min-h-screen flex-1 rounded-xl bg-muted/50 md:min-h-min"
                  ]
                []
            ]
        ]
    ]
;;
