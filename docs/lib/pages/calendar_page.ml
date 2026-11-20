open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "calendar"

(*$ Pick a date
   Arrow keys move by a day or a week, Page Up and Page Down by a month. *)
let pick (local_ graph) =
  let calendar = Calendar.component graph in
  let%arr { Calendar.view; selected } = calendar in
  Node.div
    ~attrs:[ Attr.class_ "docs-stack"; Attr.create "style" "align-items: center" ]
    [ view
    ; Node.span
        ~attrs:[ Attr.create "style" "color: var(--loon-muted-foreground); font-size: 0.875rem" ]
        [ Node.text
            (match selected with
             | None -> "No date picked yet."
             | Some d -> "Picked " ^ Date.to_string d)
        ]
    ]
(*$*)

(*$ Weekdays only, from today
   Sunday-first, with weekends and past days disabled. *)
let weekdays (local_ graph) =
  let today = Date.of_string "2026-11-20" in
  let calendar =
    Calendar.component
      ~today
      ~week_start:Sun
      ~min:today
      ~is_disabled:(fun d ->
        match Date.day_of_week d with
        | Sat | Sun -> true
        | _ -> false)
      graph
  in
  let%arr { Calendar.view; _ } = calendar in
  view
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Calendar"
    ~group:Forms
    ~description:"A month of days to pick a date from."
    ~usage:{|Calendar.component ~min:today graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "default", "Date.t", "The date picked at first."
          ; "week_start", "Day_of_week.t", "Default Mon."
          ; "min, max", "Date.t", "Days outside can't be picked."
          ; "is_disabled", "Date.t -> bool", "Other days that can't be picked."
          ; "today", "Date.t", "Marked; default the browser's local date."
          ]
      ; Doc.p "[Calendar.component] returns its view and the date picked. [Calendar.view] is the controlled form: you keep the focused day (which sets the month shown) and the selection."
      ]
    [ Doc.example ~page "Pick a date" pick
    ; Doc.example ~page "Weekdays only, from today" weekdays
    ]
;;
