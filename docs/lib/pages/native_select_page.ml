open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

(* Examples sit in a column no wider than a form would be. *)
let narrow nodes =
  Node.div
    ~attrs:
      [ Attr.class_ "docs-stack"
      ; Attr.style (Css_gen.create ~field:"width" ~value:"min(100%, 24rem)")
      ]
    nodes
;;
let page = "native_select"

(*$ Default *)
let timezones =
  [ Native_select.Item.create ~value:"Australia/Sydney" "Sydney (AEST)"
  ; Native_select.Item.create ~value:"Australia/Perth" "Perth (AWST)"
  ; Native_select.Item.create ~value:"Pacific/Auckland" "Auckland (NZST)"
  ; Native_select.Item.create ~value:"Europe/London" "London (GMT)"
  ; Native_select.Item.create ~value:"America/New_York" "New York (EST)"
  ]
;;

let default (local_ graph) =
  let timezone, set_timezone = Bonsai.state "" graph in
  let%arr timezone and set_timezone in
  narrow
    [ Field.view
        ~id:"select-tz"
        ~label:"Time zone"
        ~description:"Used for reminders and the calendar."
        (fun attrs ->
           Native_select.view
             ~attrs
             ~placeholder:"Select a time zone"
             ~value:timezone
             ~on_change:set_timezone
             timezones)
    ]
(*$*)

(*$ Invalid and disabled *)
let states =
  let items = [ Native_select.Item.create ~value:"a" "Option A" ] in
  narrow
    [ Native_select.view
        ~invalid:true
        ~placeholder:"Required"
        ~value:""
        ~on_change:(fun _ -> Effect.Ignore)
        items
    ; Native_select.view ~disabled:true ~value:"a" ~on_change:(fun _ -> Effect.Ignore) items
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Native select"
    ~group:Forms
    ~description:"The browser's own <select>, styled to match. On phones it opens the system picker."
    ~usage:
      {|Native_select.view ~value ~on_change:set_value
  [ Native_select.Item.create ~value:"au" "Australia"
  ; Native_select.Item.create ~value:"nz" "New Zealand"
  ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "value", "string", "The chosen item's value."
          ; "on_change", "string -> unit Effect.t", "Gets the newly chosen value."
          ; "placeholder", "string", "Shown, and not choosable, while value matches no item."
          ; "invalid", "bool", "Sets aria-invalid and the danger colour."
          ; "disabled", "bool", "Greys it out."
          ]
      ]
    [ Doc.example ~page "Default" default; Doc.static ~page "Invalid and disabled" states ]
;;
