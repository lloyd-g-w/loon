open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "tabs"

(*$ Demo *)
let demo (local_ graph) =
  let panel tabs ~value ~title ~description content =
    Tabs.content
      tabs
      ~value
      [ Card.root
          [ Card.header
              [ Card.title [ Node.text title ]
              ; Card.description [ Node.text description ]
              ]
          ; Card.content ~class_:"text-sm text-muted-foreground" [ Node.text content ]
          ]
      ]
  in
  Tabs.component
    ~default_value:"overview"
    ~class_:"w-[400px]"
    (Bonsai.return (fun tabs ->
       [ Tabs.list
           tabs
           [ Tabs.trigger ~value:"overview" [ Node.text "Overview" ]
           ; Tabs.trigger ~value:"analytics" [ Node.text "Analytics" ]
           ; Tabs.trigger ~value:"reports" [ Node.text "Reports" ]
           ; Tabs.trigger ~value:"settings" [ Node.text "Settings" ]
           ]
       ; panel
           tabs
           ~value:"overview"
           ~title:"Overview"
           ~description:
             "View your key metrics and recent project activity. Track progress \
              across all your active projects."
           "You have 12 active projects and 3 pending tasks."
       ; panel
           tabs
           ~value:"analytics"
           ~title:"Analytics"
           ~description:
             "Track performance and user engagement metrics. Monitor trends and \
              identify growth opportunities."
           "Page views are up 25% compared to last month."
       ; panel
           tabs
           ~value:"reports"
           ~title:"Reports"
           ~description:
             "Generate and download your detailed reports. Export data in multiple \
              formats for analysis."
           "You have 5 reports ready and available to export."
       ; panel
           tabs
           ~value:"settings"
           ~title:"Settings"
           ~description:
             "Manage your account preferences and options. Customize your experience \
              to fit your needs."
           "Configure notifications, security, and themes."
       ]))
    graph
;;

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
