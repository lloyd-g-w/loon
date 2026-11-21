open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let time_input ~id ~label ~default_value =
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col gap-3" ]
    [ Label.view ~for_:id ~class_:"invisible px-1" [ Node.text label ]
    ; Input.view
        ~type_:Time
        ~id
        ~attrs:[ Attr.create "step" "1"; Attr.create "value" default_value ]
        ~class_:
          "bg-background appearance-none \
           [&::-webkit-calendar-picker-indicator]:hidden \
           [&::-webkit-calendar-picker-indicator]:appearance-none"
        ()
    ]
;;

(* A date in a popover: its trigger shows it as "Jun 01, 2025". *)
let date_picker ~id ~label ~popover_id ~open_ ~set_open (calendar : Node.t) date
  =
  Node.div
    ~attrs:[ Attr.class_ "flex flex-1 flex-col gap-3" ]
    [ Label.view ~for_:id ~class_:"px-1" [ Node.text label ]
    ; Popover.view
        ~id:popover_id
        ~trigger_id:id
        ~open_
        ~on_open_change:set_open
        (fun popover ->
           [ Popover.trigger
               popover
               (Button.view
                  ~variant:Outline
                  ~class_:"w-full justify-between font-normal"
                  [ Node.text
                      (match date with
                       | Some date -> Calendar.format "MMM dd, yyyy" date
                       | None -> "Select date")
                  ; Icon.view Chevron_down
                  ])
           ; Popover.content
               popover
               ~class_:"w-auto overflow-hidden p-0"
               ~align:Start
               [ calendar ]
           ])
    ]
;;

let view (local_ graph) =
  let open_from, set_open_from = Bonsai.state false graph in
  let open_to, set_open_to = Bonsai.state false graph in
  let date_from, set_date_from =
    Bonsai.state (Some (Date.create_exn ~y:2025 ~m:Jun ~d:1)) graph
  in
  let date_to, set_date_to =
    Bonsai.state (Some (Date.create_exn ~y:2025 ~m:Jun ~d:3)) graph
  in
  let today = Calendar.today () in
  let month_from, set_month_from = Bonsai.state today graph in
  let month_to, set_month_to = Bonsai.state today graph in
  let focused_from, set_focused_from = Bonsai.state None graph in
  let focused_to, set_focused_to = Bonsai.state None graph in
  let id = Bonsai.path_id graph in
  let%arr open_from
  and set_open_from
  and open_to
  and set_open_to
  and date_from
  and set_date_from
  and date_to
  and set_date_to
  and month_from
  and set_month_from
  and month_to
  and set_month_to
  and focused_from
  and set_focused_from
  and focused_to
  and set_focused_to
  and id in
  let selected_date = function
    | Calendar.Selection.Single date -> date
    | Multiple _ | Range _ -> None
  in
  let calendar_from =
    Calendar.view
      ~id:("calendar-26-from-calendar" ^ id)
      ~selected:(Single date_from)
      ~caption_layout:Dropdown
      ~on_select:(fun selection ->
        Effect.Many
          [ set_date_from (selected_date selection); set_open_from false ])
      ~month:month_from
      ~on_month_change:set_month_from
      ~focused:focused_from
      ~on_focus:set_focused_from
      ()
  in
  let calendar_to =
    Calendar.view
      ~id:("calendar-26-to-calendar" ^ id)
      ~selected:(Single date_to)
      ~caption_layout:Dropdown
      ~on_select:(fun selection ->
        Effect.Many [ set_date_to (selected_date selection); set_open_to false ])
      ?disabled:
        (Option.map date_from ~f:(fun date_from date ->
           Date.( < ) date date_from))
      ~month:month_to
      ~on_month_change:set_month_to
      ~focused:focused_to
      ~on_focus:set_focused_to
      ()
  in
  Node.div
    ~attrs:[ Attr.class_ "flex w-full max-w-64 min-w-0 flex-col gap-6" ]
    [ Node.div
        ~attrs:[ Attr.class_ "flex gap-4" ]
        [ date_picker
            ~id:"date-from"
            ~label:"Check-in"
            ~popover_id:("calendar-26-from" ^ id)
            ~open_:open_from
            ~set_open:set_open_from
            calendar_from
            date_from
        ; time_input ~id:"time-from" ~label:"From" ~default_value:"10:30:00"
        ]
    ; Node.div
        ~attrs:[ Attr.class_ "flex gap-4" ]
        [ date_picker
            ~id:"date-to"
            ~label:"Check-out"
            ~popover_id:("calendar-26-to" ^ id)
            ~open_:open_to
            ~set_open:set_open_to
            calendar_to
            date_to
        ; time_input ~id:"time-to" ~label:"To" ~default_value:"12:30:00"
        ]
    ]
;;
