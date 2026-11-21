open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
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
let nav_main =
  [ ( "Playground"
    , Icon.Square_terminal
    , true
    , [ "History"; "Starred"; "Settings" ] )
  ; "Models", Bot, false, [ "Genesis"; "Explorer"; "Quantum" ]
  ; ( "Documentation"
    , Book_open
    , false
    , [ "Introduction"; "Get Started"; "Tutorials"; "Changelog" ] )
  ; "Settings", Settings_2, false, [ "General"; "Team"; "Billing"; "Limits" ]
  ]
;;

let projects =
  [ "Design Engineering", Icon.Frame
  ; "Sales & Marketing", Chart_pie
  ; "Travel", Map
  ]
;;

let team_switcher =
  Sidebar.menu
    [ Sidebar.menu_item
        [ Sidebar.menu_button
            ~size:Lg
            ~class_:
              "data-[state=open]:bg-sidebar-accent \
               data-[state=open]:text-sidebar-accent-foreground"
            [ Node.div
                ~attrs:
                  [ Attr.class_
                      "flex aspect-square size-8 items-center justify-center \
                       rounded-lg bg-sidebar-primary \
                       text-sidebar-primary-foreground"
                  ]
                [ Icon.view ~class_:"size-4" Gallery_vertical_end ]
            ; Node.div
                ~attrs:
                  [ Attr.class_ "grid flex-1 text-left text-sm leading-tight" ]
                [ Node.span
                    ~attrs:[ Attr.class_ "truncate font-medium" ]
                    [ Node.text "Acme Inc" ]
                ; Node.span
                    ~attrs:[ Attr.class_ "truncate text-xs" ]
                    [ Node.text "Enterprise" ]
                ]
            ; Icon.view ~class_:"ml-auto" Chevrons_up_down
            ]
        ]
    ]
;;

let nav_user =
  Sidebar.menu
    [ Sidebar.menu_item
        [ Sidebar.menu_button
            ~size:Lg
            [ Node.span
                ~attrs:
                  [ Attr.class_
                      "flex h-8 w-8 shrink-0 items-center justify-center \
                       overflow-hidden rounded-lg bg-muted"
                  ]
                [ Node.text "CN" ]
            ; Node.div
                ~attrs:
                  [ Attr.class_ "grid flex-1 text-left text-sm leading-tight" ]
                [ Node.span
                    ~attrs:[ Attr.class_ "truncate font-medium" ]
                    [ Node.text "shadcn" ]
                ; Node.span
                    ~attrs:[ Attr.class_ "truncate text-xs" ]
                    [ Node.text "m@example.com" ]
                ]
            ; Icon.view ~class_:"ml-auto size-4" Chevrons_up_down
            ]
        ]
    ]
;;

let demo (local_ graph) =
  let sidebar = Sidebar.component graph in
  (* The sections open, as each [Collapsible]'s state. *)
  let expanded, set_expanded =
    Bonsai.state
      (String.Set.of_list
         (List.filter_map nav_main ~f:(fun (title, _, active, _) ->
            Option.some_if active title)))
      graph
  in
  let%arr sidebar
  and expanded
  and set_expanded in
  let nav_item (title, icon, _, items) =
    let open_ = Set.mem expanded title in
    let state = if open_ then "open" else "closed" in
    let toggle =
      set_expanded
        (if open_ then Set.remove expanded title else Set.add expanded title)
    in
    Sidebar.menu_item
      ~class_:"group/collapsible"
      ~attrs:[ Attr.create "data-state" state ]
      [ Sidebar.menu_button
          ~tooltip:title
          ~on_click:toggle
          ~attrs:
            [ Attr.create "aria-expanded" (Bool.to_string open_)
            ; Attr.create "data-state" state
            ]
          [ Icon.view icon
          ; Node.span [ Node.text title ]
          ; Icon.view
              ~class_:
                "ml-auto transition-transform duration-200 \
                 group-data-[state=open]/collapsible:rotate-90"
              Chevron_right
          ]
      ; (if open_
         then
           Sidebar.menu_sub
             (List.map items ~f:(fun item ->
                Sidebar.menu_sub_item
                  [ Sidebar.menu_sub_button
                      ~href:"#"
                      [ Node.span [ Node.text item ] ]
                  ]))
         else Node.none)
      ]
  in
  frame
    [ Sidebar.provider
        ~class_:"min-h-0"
        sidebar
        [ Sidebar.root
            ~collapsible:Icon
            sidebar
            [ Sidebar.header [ team_switcher ]
            ; Sidebar.content
                [ Sidebar.group
                    [ Sidebar.group_label [ Node.text "Platform" ]
                    ; Sidebar.menu (List.map nav_main ~f:nav_item)
                    ]
                ; Sidebar.group
                    ~class_:"group-data-[collapsible=icon]:hidden"
                    [ Sidebar.group_label [ Node.text "Projects" ]
                    ; Sidebar.menu
                        (List.map projects ~f:(fun (name, icon) ->
                           Sidebar.menu_item
                             [ Sidebar.menu_button
                                 ~href:"#"
                                 [ Icon.view icon
                                 ; Node.span [ Node.text name ]
                                 ]
                             ; Sidebar.menu_action
                                 ~show_on_hover:true
                                 [ Icon.view Ellipsis
                                 ; Node.span
                                     ~attrs:[ Attr.class_ "sr-only" ]
                                     [ Node.text "More" ]
                                 ]
                             ])
                         @ [ Sidebar.menu_item
                               [ Sidebar.menu_button
                                   ~class_:"text-sidebar-foreground/70"
                                   [ Icon.view
                                       ~class_:"text-sidebar-foreground/70"
                                       Ellipsis
                                   ; Node.span [ Node.text "More" ]
                                   ]
                               ]
                           ])
                    ]
                ]
            ; Sidebar.footer [ nav_user ]
            ; Sidebar.rail sidebar
            ]
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
                                      ~tooltip:title
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
          ; "tooltip", "string (shown when collapsed to icons)", "none"
          ; "href", "string (an <a> rather than a <button>)", "none"
          ]
      ]
    [ Doc.example ~page "Demo" demo; Doc.example ~page "Variants" variants ]
;;
