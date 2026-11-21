open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "breadcrumb"

(*$ Demo *)
let demo (local_ graph) =
  let menu =
    Dropdown_menu.component
      ~align:Start
      ~trigger:(fun attrs ->
        Node.button
          ~attrs:([ Attr.type_ "button"; Attr.class_ "flex items-center gap-1" ] @ attrs)
          [ Breadcrumb.ellipsis ~class_:"size-4" ()
          ; Node.span ~attrs:[ Attr.class_ "sr-only" ] [ Node.text "Toggle menu" ]
          ])
      (Bonsai.return
         Dropdown_menu.Item.
           [ action ~on_select:Effect.Ignore "Documentation"
           ; action ~on_select:Effect.Ignore "Themes"
           ; action ~on_select:Effect.Ignore "GitHub"
           ])
      graph
  in
  let%arr menu in
  Breadcrumb.root
    [ Breadcrumb.list
        [ Breadcrumb.item [ Breadcrumb.link ~href:"#/" [ Node.text "Home" ] ]
        ; Breadcrumb.separator ()
        ; Breadcrumb.item [ menu ]
        ; Breadcrumb.separator ()
        ; Breadcrumb.item
            [ Breadcrumb.link ~href:"#/introduction" [ Node.text "Components" ] ]
        ; Breadcrumb.separator ()
        ; Breadcrumb.item [ Breadcrumb.page [ Node.text "Breadcrumb" ] ]
        ]
    ]
(*$*)

(*$ Custom separator
   Give [Breadcrumb.separator] its children. *)
let custom_separator =
  Breadcrumb.root
    [ Breadcrumb.list
        [ Breadcrumb.item [ Breadcrumb.link ~href:"#/" [ Node.text "Home" ] ]
        ; Breadcrumb.separator ~children:[ Icon.view Slash ] ()
        ; Breadcrumb.item
            [ Breadcrumb.link ~href:"#/introduction" [ Node.text "Components" ] ]
        ; Breadcrumb.separator ~children:[ Icon.view Slash ] ()
        ; Breadcrumb.item [ Breadcrumb.page [ Node.text "Breadcrumb" ] ]
        ]
    ]
;;

(*$*)

(*$ Dropdown
   A dropdown menu in an item. *)
let dropdown (local_ graph) =
  let menu =
    Dropdown_menu.component
      ~align:Start
      ~trigger:(fun attrs ->
        Node.button
          ~attrs:
            ([ Attr.type_ "button"
             ; Attr.class_
                 "flex items-center gap-1 [&_svg]:pointer-events-none [&_svg]:shrink-0 \
                  [&_svg:not([class*='size-'])]:size-3.5"
             ]
             @ attrs)
          [ Node.text "Components"; Icon.view Chevron_down ])
      (Bonsai.return
         Dropdown_menu.Item.
           [ action ~on_select:Effect.Ignore "Documentation"
           ; action ~on_select:Effect.Ignore "Themes"
           ; action ~on_select:Effect.Ignore "GitHub"
           ])
      graph
  in
  let%arr menu in
  Breadcrumb.root
    [ Breadcrumb.list
        [ Breadcrumb.item [ Breadcrumb.link ~href:"#/" [ Node.text "Home" ] ]
        ; Breadcrumb.separator ~children:[ Icon.view Slash ] ()
        ; Breadcrumb.item [ menu ]
        ; Breadcrumb.separator ~children:[ Icon.view Slash ] ()
        ; Breadcrumb.item [ Breadcrumb.page [ Node.text "Breadcrumb" ] ]
        ]
    ]
(*$*)

(*$ Collapsed
   [Breadcrumb.ellipsis] stands for the items left out of a long trail. *)
let collapsed =
  Breadcrumb.root
    [ Breadcrumb.list
        [ Breadcrumb.item [ Breadcrumb.link ~href:"#/" [ Node.text "Home" ] ]
        ; Breadcrumb.separator ()
        ; Breadcrumb.item [ Breadcrumb.ellipsis () ]
        ; Breadcrumb.separator ()
        ; Breadcrumb.item
            [ Breadcrumb.link ~href:"#/introduction" [ Node.text "Components" ] ]
        ; Breadcrumb.separator ()
        ; Breadcrumb.item [ Breadcrumb.page [ Node.text "Breadcrumb" ] ]
        ]
    ]
;;

(*$*)

(*$ Link component
   Any element can be the link: give it [Breadcrumb.link_classes ()]. *)
let link_component =
  Breadcrumb.root
    [ Breadcrumb.list
        [ Breadcrumb.item
            [ Node.button
                ~attrs:
                  [ Attr.type_ "button"
                  ; Attr.class_ (Breadcrumb.link_classes ())
                  ; Attr.on_click (fun _ -> Effect.Ignore)
                  ]
                [ Node.text "Home" ]
            ]
        ; Breadcrumb.separator ()
        ; Breadcrumb.item
            [ Breadcrumb.link ~href:"#/introduction" [ Node.text "Components" ] ]
        ; Breadcrumb.separator ()
        ; Breadcrumb.item [ Breadcrumb.page [ Node.text "Breadcrumb" ] ]
        ]
    ]
;;

(*$*)

(*$ Responsive
   The middle of a long trail folds into a menu, and the last items
   truncate on small screens. *)
let responsive (local_ graph) =
  let items =
    [ Some "#/", "Home"
    ; Some "#/", "Documentation"
    ; Some "#/", "Build Your Application"
    ; Some "#/", "Data Fetching"
    ; None, "Caching and Revalidating"
    ]
  in
  let items_to_display = 3 in
  let menu =
    Dropdown_menu.component
      ~align:Start
      ~trigger:(fun attrs ->
        Node.button
          ~attrs:
            ([ Attr.type_ "button"
             ; Attr.class_ "flex items-center gap-1"
             ; Attr.create "aria-label" "Toggle menu"
             ]
             @ attrs)
          [ Breadcrumb.ellipsis ~class_:"size-4" () ])
      (Bonsai.return
         (List.sub items ~pos:1 ~len:(List.length items - 3)
          |> List.map ~f:(fun (_, label) ->
            Dropdown_menu.Item.action ~on_select:Effect.Ignore label)))
      graph
  in
  let%arr menu in
  let first_href, first_label = List.hd_exn items in
  Breadcrumb.root
    [ Breadcrumb.list
        ([ Breadcrumb.item
             [ Breadcrumb.link
                 ~href:(Option.value first_href ~default:"#/")
                 [ Node.text first_label ]
             ]
         ; Breadcrumb.separator ()
         ]
         @ (if List.length items > items_to_display
            then [ Breadcrumb.item [ menu ]; Breadcrumb.separator () ]
            else [])
         @ List.map
             (List.drop items (List.length items - (items_to_display - 1)))
             ~f:(fun (href, label) ->
               Breadcrumb.item
                 (match href with
                  | Some href ->
                    [ Breadcrumb.link
                        ~class_:"max-w-20 truncate md:max-w-none"
                        ~href
                        [ Node.text label ]
                    ; Breadcrumb.separator ()
                    ]
                  | None ->
                    [ Breadcrumb.page
                        ~class_:"max-w-20 truncate md:max-w-none"
                        [ Node.text label ]
                    ])))
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Breadcrumb"
    ~group:Navigation
    ~description:"Displays the path to the current resource using a hierarchy of links."
    ~usage:
      {|Breadcrumb.root
  [ Breadcrumb.list
      [ Breadcrumb.item [ Breadcrumb.link ~href:"/" [ Node.text "Home" ] ]
      ; Breadcrumb.separator ()
      ; Breadcrumb.item [ Breadcrumb.link ~href:"/components" [ Node.text "Components" ] ]
      ; Breadcrumb.separator ()
      ; Breadcrumb.item [ Breadcrumb.page [ Node.text "Breadcrumb" ] ]
      ]
  ]|}
    ~body:
      [ Doc.h2 "Parts"
      ; Doc.props
          [ "root", "Node.t list", "The [<nav aria-label=\"breadcrumb\">]."
          ; "list", "Node.t list", "The [<ol>] of items and separators."
          ; "item", "Node.t list", "An [<li>] holding a link, the page or a menu."
          ; "link", "~href", "A link to an ancestor ([link_classes] for other elements)."
          ; "page", "Node.t list", "The current page ([aria-current=\"page\"])."
          ; "separator", "?children", "A chevron, or [children] (e.g. a slash)."
          ; "ellipsis", "unit", "Stands for collapsed items."
          ]
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.static ~page "Custom separator" custom_separator
    ; Doc.example ~page "Dropdown" dropdown
    ; Doc.static ~page "Collapsed" collapsed
    ; Doc.static ~page "Link component" link_component
    ; Doc.example ~page "Responsive" responsive
    ]
;;
