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

let app_sidebar sidebar =
  Sidebar.root
    sidebar
    [ Sidebar.header [ logo () ]
    ; Sidebar.content
        [ Sidebar.group
            [ Sidebar.menu
                (List.map nav_main ~f:(fun (title, items) ->
                   Sidebar.menu_item
                     [ Sidebar.menu_button
                         ~href:"#"
                         ~class_:"font-medium"
                         [ Node.text title ]
                     ; (if List.is_empty items
                        then Node.none
                        else
                          Sidebar.menu_sub
                            (List.map items ~f:(fun (title, is_active) ->
                               Sidebar.menu_sub_item
                                 [ Sidebar.menu_sub_button
                                     ~is_active
                                     ~href:"#"
                                     [ Node.text title ]
                                 ])))
                     ]))
            ]
        ]
    ; Sidebar.rail sidebar
    ]
;;

let view (local_ graph) =
  let sidebar = Sidebar.component graph in
  let%arr sidebar in
  Sidebar.provider
    sidebar
    [ app_sidebar sidebar
    ; Sidebar.inset
        [ Node.header
            ~attrs:[ Attr.class_ "flex h-16 shrink-0 items-center gap-2 border-b" ]
            [ Node.div
                ~attrs:[ Attr.class_ "flex items-center gap-2 px-3" ]
                [ Sidebar.trigger sidebar
                ; Separator.view ~orientation:Vertical ~class_:"mr-2 h-4" ()
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
