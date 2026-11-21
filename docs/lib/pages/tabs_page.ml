open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "tabs"

(*$ Demo *)
let demo (local_ graph) =
  let name = Input.component ~default:"Pedro Duarte" graph in
  let username = Input.component ~default:"@peduarte" graph in
  let current = Input.component ~type_:Password graph in
  let new_ = Input.component ~type_:Password graph in
  let field ~id ~label (control : string Control.t) =
    Node.div
      ~attrs:[ Attr.class_ "grid gap-3" ]
      [ Label.text ~for_:id label
      ; Input.view
          ~attrs:[ Attr.id id ]
          ~value:control.value
          ~on_input:control.set
          ()
      ]
  in
  let tabs =
    Tabs.component
      ~default_value:"account"
      (let%arr name and username and current and new_ in
       fun tabs ->
         [ Tabs.list
             tabs
             [ Tabs.trigger ~value:"account" [ Node.text "Account" ]
             ; Tabs.trigger ~value:"password" [ Node.text "Password" ]
             ]
         ; Tabs.content
             tabs
             ~value:"account"
             [ Card.root
                 [ Card.header
                     [ Card.title [ Node.text "Account" ]
                     ; Card.description
                         [ Node.text
                             "Make changes to your account here. Click save when \
                              you're done."
                         ]
                     ]
                 ; Card.content
                     ~class_:"grid gap-6"
                     [ field ~id:"tabs-demo-name" ~label:"Name" name
                     ; field ~id:"tabs-demo-username" ~label:"Username" username
                     ]
                 ; Card.footer [ Button.view [ Node.text "Save changes" ] ]
                 ]
             ]
         ; Tabs.content
             tabs
             ~value:"password"
             [ Card.root
                 [ Card.header
                     [ Card.title [ Node.text "Password" ]
                     ; Card.description
                         [ Node.text
                             "Change your password here. After saving, you'll be logged \
                              out."
                         ]
                     ]
                 ; Card.content
                     ~class_:"grid gap-6"
                     [ field ~id:"tabs-demo-current" ~label:"Current password" current
                     ; field ~id:"tabs-demo-new" ~label:"New password" new_
                     ]
                 ; Card.footer [ Button.view [ Node.text "Save password" ] ]
                 ]
             ]
         ])
      graph
  in
  let%arr tabs in
  Node.div ~attrs:[ Attr.class_ "flex w-full max-w-sm flex-col gap-6" ] [ tabs ]
(*$*)

(*$ Line
   [~variant:Line] draws the selected tab as an underline. *)
let line (local_ graph) =
  Tabs.component
    ~default_value:"overview"
    (Bonsai.return (fun tabs ->
       [ Tabs.list
           ~variant:Line
           tabs
           [ Tabs.trigger ~value:"overview" [ Node.text "Overview" ]
           ; Tabs.trigger ~value:"analytics" [ Node.text "Analytics" ]
           ; Tabs.trigger ~value:"reports" [ Node.text "Reports" ]
           ]
       ]))
    graph
(*$*)

(*$ Vertical *)
let vertical (local_ graph) =
  Tabs.component
    ~orientation:Vertical
    ~default_value:"account"
    (Bonsai.return (fun tabs ->
       [ Tabs.list
           tabs
           [ Tabs.trigger ~value:"account" [ Node.text "Account" ]
           ; Tabs.trigger ~value:"password" [ Node.text "Password" ]
           ; Tabs.trigger ~value:"notifications" [ Node.text "Notifications" ]
           ]
       ]))
    graph
(*$*)

(*$ Disabled *)
let disabled (local_ graph) =
  Tabs.component
    ~default_value:"home"
    (Bonsai.return (fun tabs ->
       [ Tabs.list
           tabs
           [ Tabs.trigger ~value:"home" [ Node.text "Home" ]
           ; Tabs.trigger ~value:"settings" ~disabled:true [ Node.text "Disabled" ]
           ]
       ]))
    graph
(*$*)

(*$ Icons *)
let icons (local_ graph) =
  Tabs.component
    ~default_value:"preview"
    (Bonsai.return (fun tabs ->
       [ Tabs.list
           tabs
           [ Tabs.trigger ~value:"preview" [ Icon.view App_window; Node.text "Preview" ]
           ; Tabs.trigger ~value:"code" [ Icon.view Code; Node.text "Code" ]
           ]
       ]))
    graph
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Tabs"
    ~group:Navigation
    ~description:
      "A set of layered sections of content—known as tab panels—that are displayed one \
       at a time."
    ~usage:
      {|Tabs.component ~default_value:"account"
  (return (fun tabs ->
     [ Tabs.list tabs
         [ Tabs.trigger ~value:"account" [ Node.text "Account" ]
         ; Tabs.trigger ~value:"password" [ Node.text "Password" ]
         ]
     ; Tabs.content tabs ~value:"account" [ Node.text "Make changes to your account here." ]
     ; Tabs.content tabs ~value:"password" [ Node.text "Change your password here." ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "default_value"
            , "string"
            , "[Tabs.component]: the tab selected at first. [Tabs.view] takes [~value] \
               and [~on_change] instead." )
          ; "orientation", "Tabs.Orientation.t", "[Horizontal] (default) or [Vertical]."
          ; ( "variant"
            , "Tabs.List_variant.t"
            , "[Tabs.list]: [Default] (a muted track) or [Line] (an underline)." )
          ; "disabled", "bool", "[Tabs.trigger]: cannot be selected; keys skip it."
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.table
          [ "Key"; "Does" ]
          [ [ Doc.text "Arrow keys"; Doc.text "Select the previous or next tab (wrapping)." ]
          ; [ Doc.text "Home / End"; Doc.text "Select the first or last tab." ]
          ; [ Doc.text "Tab"; Doc.text "Move into the selected panel." ]
          ]
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Line" line
    ; Doc.example ~page "Vertical" vertical
    ; Doc.example ~page "Disabled" disabled
    ; Doc.example ~page "Icons" icons
    ]
;;
