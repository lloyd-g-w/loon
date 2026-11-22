open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "navigation_menu"

(*$ Demo *)
let components =
  [ ( "Alert Dialog"
    , "A modal dialog that interrupts the user with important content and expects a \
       response." )
  ; "Hover Card", "For sighted users to preview content available behind a link."
  ; ( "Progress"
    , "Displays an indicator showing the completion progress of a task, typically \
       displayed as a progress bar." )
  ; "Scroll-area", "Visually or semantically separates content."
  ; ( "Tabs"
    , "A set of layered sections of content—known as tab panels—that are displayed \
       one at a time." )
  ; ( "Tooltip"
    , "A popup that displays information related to an element when the element \
       receives keyboard focus or the mouse hovers over it." )
  ]
;;

let list_item ~href ~title description =
  Node.li
    [ Navigation_menu.link
        ~href
        [ Node.div
            ~attrs:[ Attr.class_ "flex flex-col gap-1 text-sm" ]
            [ Node.div ~attrs:[ Attr.class_ "leading-none font-medium" ] [ Node.text title ]
            ; Node.div
                ~attrs:[ Attr.class_ "line-clamp-2 text-muted-foreground" ]
                [ Node.text description ]
            ]
        ]
    ]
;;

let demo (local_ graph) =
  let menu =
    Navigation_menu.component
      (Bonsai.return (fun nav ->
         [ Navigation_menu.list
             nav
             [ Navigation_menu.item
                 [ Navigation_menu.trigger
                     nav
                     ~value:"getting-started"
                     [ Node.text "Getting started" ]
                 ; Navigation_menu.content
                     nav
                     ~value:"getting-started"
                     [ Node.ul
                         ~attrs:[ Attr.class_ "w-96" ]
                         [ list_item
                             ~href:"#/introduction"
                             ~title:"Introduction"
                             "Re-usable components built with Tailwind CSS."
                         ; list_item
                             ~href:"#/installation"
                             ~title:"Installation"
                             "How to install dependencies and structure your app."
                         ; list_item
                             ~href:"#/theming"
                             ~title:"Typography"
                             "Styles for headings, paragraphs, lists...etc"
                         ]
                     ]
                 ]
             ; Navigation_menu.item
                 ~class_:"hidden md:flex"
                 [ Navigation_menu.trigger
                     nav
                     ~value:"components"
                     [ Node.text "Components" ]
                 ; Navigation_menu.content
                     nav
                     ~value:"components"
                     [ Node.ul
                         ~attrs:
                           [ Attr.class_
                               "grid w-[400px] gap-2 md:w-[500px] md:grid-cols-2 \
                                lg:w-[600px]"
                           ]
                         (List.map components ~f:(fun (title, description) ->
                            list_item ~href:"#/navigation-menu" ~title description))
                     ]
                 ]
             ; Navigation_menu.item
                 [ Navigation_menu.link
                     ~class_:(Navigation_menu.trigger_style ())
                     ~href:"#/introduction"
                     [ Node.text "Docs" ]
                 ]
             ]
         ]))
      graph
  in
  (* Room under the menu for its contents. *)
  let%arr menu in
  Node.div
    ~attrs:
      [ Attr.class_ "flex min-h-[480px] w-full items-start justify-center md:min-h-[340px]"
      ]
    [ menu ]
;;

(*$*)

(*$ Viewport
   With [~viewport:true] (the default) the open content shows in one panel
   under the list, which resizes and slides between contents; an
   [indicator] points at the open trigger. *)
let viewport (local_ graph) =
  let%map.Bonsai menu =
    Navigation_menu.component
      (Bonsai.return (fun nav ->
         let simple value title links =
           Navigation_menu.item
             [ Navigation_menu.trigger nav ~value [ Node.text title ]
             ; Navigation_menu.content
                 nav
                 ~value
                 [ Node.ul
                     ~attrs:[ Attr.class_ "grid w-[200px] gap-1" ]
                     (List.map links ~f:(fun t ->
                        Node.li
                          [ Navigation_menu.link
                              ~href:"#/navigation_menu"
                              [ Node.text t ]
                          ]))
                 ]
             ]
         in
         [ Navigation_menu.list
             nav
             [ simple
                 "getting-started"
                 "Getting started"
                 [ "Introduction"; "Installation" ]
             ; simple
                 "components"
                 "Components"
                 [ "Breadcrumb"
                 ; "Navigation Menu"
                 ; "Pagination"
                 ; "Sidebar"
                 ; "Tabs"
                 ]
             ; Navigation_menu.item
                 [ Navigation_menu.link
                     ~class_:(Navigation_menu.trigger_style ())
                     ~href:"#/introduction"
                     [ Node.text "Docs" ]
                 ]
             ; Navigation_menu.indicator nav
             ]
         ]))
      graph
  in
  Node.div
    ~attrs:
      [ Attr.class_ "flex min-h-[300px] w-full items-start justify-center" ]
    [ menu ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Navigation Menu"
    ~description:"A collection of links for navigating websites."
    ~usage:
      {|Navigation_menu.component
  (return (fun nav ->
     [ Navigation_menu.list nav
         [ Navigation_menu.item
             [ Navigation_menu.trigger nav ~value:"item-one" [ Node.text "Item One" ]
             ; Navigation_menu.content nav ~value:"item-one"
                 [ Navigation_menu.link ~href:"#" [ Node.text "Link" ] ]
             ]
         ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "viewport"
            , "bool"
            , "Show the open content in a shared viewport under the list \
               (default [true]); [false]: under its own item." )
          ; ( "default_value"
            , "string"
            , "[Navigation_menu.component]: the item open at first (none by \
               default). [Navigation_menu.view] takes [~value] and \
               [~on_change] instead." )
          ; ( "value"
            , "string"
            , "[trigger] and [content]: which trigger opens which content." )
          ; "active", "bool", "[link]: the current page."
          ]
      ; Doc.p
          "[Navigation_menu.trigger_style ()] gives a link in the list the \
           look of a trigger."
      ; Doc.h2 "Keyboard"
      ; Doc.table
          [ "Key"; "Does" ]
          [ [ Doc.text "Enter / Space"
            ; Doc.text "Open or close the focused trigger's content."
            ]
          ; [ Doc.text "Arrow Down / Tab"
            ; Doc.text "Move from an open trigger into its content."
            ]
          ; [ Doc.text "Arrow Left / Right"
            ; Doc.text "Move between the triggers and links of the list."
            ]
          ; [ Doc.text "Arrow keys"
            ; Doc.text "Move between the links of the content."
            ]
          ; [ Doc.text "Home / End"; Doc.text "Move to the first or last." ]
          ; [ Doc.text "Esc"; Doc.text "Close, and focus the trigger." ]
          ]
      ]
    [ Doc.example ~page "Demo" demo; Doc.example ~page "Viewport" viewport ]
;;
