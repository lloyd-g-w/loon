open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "empty"

(*$ No projects yet *)
let projects =
  Empty.view
    ~bordered:true
    ~icon:Folder
    ~description:
      "Projects keep your files, people and settings together. Make one to get \
       started."
    ~actions:
      [ Button.view [ Icon.view Plus; Node.text "New project" ]
      ; Button.view ~variant:Outline [ Node.text "Import" ]
      ]
    "No projects yet"
;;

(*$*)

(*$ No search results *)
let search =
  Empty.view
    ~icon:Search
    ~description:
      "Nothing matches “bonsia”. Check the spelling or try fewer words."
    ~actions:[ Button.view ~variant:Ghost [ Node.text "Clear search" ] ]
    "No results"
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Empty"
    ~group:Feedback
    ~description:"What to show when there is nothing to show."
    ~usage:
      {|Empty.view ~icon:Inbox ~description:"New mail shows up here." "No messages"|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "icon", "Icon.t", "Shown in a tile above the title."
          ; "description", "string", "A sentence or two under the title."
          ; "actions", "Vdom.Node.t list", "Buttons: what to do next."
          ; "bordered", "bool", "A dashed outline around it (default false)."
          ]
      ]
    [ Doc.static ~page "No projects yet" projects
    ; Doc.static ~page "No search results" search
    ]
;;
