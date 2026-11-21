open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

(* This is sample data. *)
let nav_main =
  [ "Getting Started", [ "Installation"; "Project Structure" ]
  ; ( "Build Your Application"
    , [ "Routing"
      ; "Data Fetching"
      ; "Rendering"
      ; "Caching"
      ; "Styling"
      ; "Optimizing"
      ; "Configuring"
      ; "Testing"
      ; "Authentication"
      ; "Deploying"
      ; "Upgrading"
      ; "Examples"
      ] )
  ; ( "API Reference"
    , [ "Components"
      ; "File Conventions"
      ; "Functions"
      ; "next.config.js Options"
      ; "CLI"
      ; "Edge Runtime"
      ] )
  ; ( "Architecture"
    , [ "Accessibility"
      ; "Fast Refresh"
      ; "Next.js Compiler"
      ; "Supported Browsers"
      ; "Turbopack"
      ] )
  ; "Community", [ "Contribution Guide" ]
  ]
;;

let is_active title = String.equal title "Data Fetching"

let app_sidebar ?side sidebar =
  Sidebar.root
    ?side
    sidebar
    [ Sidebar.content
        [ Sidebar.group
            [ Sidebar.group_label [ Node.text "Table of Contents" ]
            ; Sidebar.group_content
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
                                (List.map items ~f:(fun title ->
                                   Sidebar.menu_sub_item
                                     [ Sidebar.menu_sub_button
                                         ~href:"#"
                                         ~is_active:(is_active title)
                                         [ Node.text title ]
                                     ])))
                         ]))
                ]
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
    [ Sidebar.inset
        [ Node.header
            ~attrs:
              [ Attr.class_ "flex h-16 shrink-0 items-center gap-2 border-b px-4" ]
            [ Breadcrumb.root
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
            ; Sidebar.trigger ~class_:"-mr-1 ml-auto rotate-180" sidebar
            ]
        ; Node.div
            ~attrs:[ Attr.class_ "flex flex-1 flex-col gap-4 p-4" ]
            [ Node.div
                ~attrs:[ Attr.class_ "grid auto-rows-min gap-4 md:grid-cols-3" ]
                (List.init 3 ~f:(fun _ ->
                   Node.div
                     ~attrs:[ Attr.class_ "aspect-video rounded-xl bg-muted/50" ]
                     []))
            ; Node.div
                ~attrs:
                  [ Attr.class_
                      "min-h-[100vh] flex-1 rounded-xl bg-muted/50 md:min-h-min"
                  ]
                []
            ]
        ]
    ; app_sidebar ~side:Right sidebar
    ]
;;
