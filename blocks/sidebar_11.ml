open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

module Tree_item = struct
  type t =
    | File of string
    | Folder of string * t list
end

let changes = [ "README.md", "M"; "api/hello/route.ts", "U"; "app/layout.tsx", "M" ]

let tree : Tree_item.t list =
  [ Folder
      ( "app"
      , [ Folder
            ( "api"
            , [ Folder ("hello", [ File "route.ts" ])
              ; File "page.tsx"
              ; File "layout.tsx"
              ; Folder ("blog", [ File "page.tsx" ])
              ] )
        ] )
  ; Folder
      ( "components"
      , [ Folder ("ui", [ File "button.tsx"; File "card.tsx" ])
        ; File "header.tsx"
        ; File "footer.tsx"
        ] )
  ; Folder ("lib", [ File "util.ts" ])
  ; Folder ("public", [ File "favicon.ico"; File "vercel.svg" ])
  ; File ".eslintrc.json"
  ; File ".gitignore"
  ; File "next.config.js"
  ; File "tailwind.config.js"
  ; File "package.json"
  ; File "README.md"
  ]
;;

(* The folders' state, by path: open at first for [components] and [ui]. *)
let default_open path =
  match List.last path with
  | Some ("components" | "ui") -> true
  | _ -> false
;;

let rec tree_view ~toggled ~set_toggled ~path (item : Tree_item.t) =
  match item with
  | File name | Folder (name, []) ->
    Sidebar.menu_button
      ~is_active:(String.equal name "button.tsx")
      ~class_:"data-[active=true]:bg-transparent"
      [ Icon.view File; Node.text name ]
  | Folder (name, items) ->
    let path = path @ [ name ] in
    let key = String.concat ~sep:"/" path in
    let open_ = Bool.( <> ) (default_open path) (Set.mem toggled key) in
    Sidebar.menu_item
      [ Collapsible.view
          ~id:("tree-" ^ key)
          ~class_:
            "group/collapsible \
             [&[data-state=open]>button>svg:first-child]:rotate-90"
          ~open_
          ~on_change:(fun _ ->
            set_toggled
              (if Set.mem toggled key
               then Set.remove toggled key
               else Set.add toggled key))
          (fun collapsible ->
             [ Sidebar.menu_button
                 ~attrs:(Collapsible.trigger_attrs collapsible)
                 [ Icon.view ~class_:"transition-transform" Chevron_right
                 ; Icon.view Folder
                 ; Node.text name
                 ]
             ; Collapsible.content
                 collapsible
                 [ Sidebar.menu_sub
                     (List.map items ~f:(tree_view ~toggled ~set_toggled ~path))
                 ]
             ])
      ]
;;

let app_sidebar ~sidebar (local_ graph) =
  (* The folders opened or closed from their default. *)
  let toggled, set_toggled = Bonsai.state String.Set.empty graph in
  let%arr sidebar and toggled and set_toggled in
  Sidebar.root
    sidebar
    [ Sidebar.content
        [ Sidebar.group
            [ Sidebar.group_label [ Node.text "Changes" ]
            ; Sidebar.group_content
                [ Sidebar.menu
                    (List.map changes ~f:(fun (file, state) ->
                       Sidebar.menu_item
                         [ Sidebar.menu_button [ Icon.view File; Node.text file ]
                         ; Sidebar.menu_badge [ Node.text state ]
                         ]))
                ]
            ]
        ; Sidebar.group
            [ Sidebar.group_label [ Node.text "Files" ]
            ; Sidebar.group_content
                [ Sidebar.menu
                    (List.map tree ~f:(tree_view ~toggled ~set_toggled ~path:[]))
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
                        [ Breadcrumb.link ~href:"#" [ Node.text "components" ] ]
                    ; Breadcrumb.separator ~class_:"hidden md:block" ()
                    ; Breadcrumb.item
                        ~class_:"hidden md:block"
                        [ Breadcrumb.link ~href:"#" [ Node.text "ui" ] ]
                    ; Breadcrumb.separator ~class_:"hidden md:block" ()
                    ; Breadcrumb.item [ Breadcrumb.page [ Node.text "button.tsx" ] ]
                    ]
                ]
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
    ]
;;
