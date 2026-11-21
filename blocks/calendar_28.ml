open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Js_of_ocaml
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

(* [toLocaleDateString("en-US", { day: "2-digit", month: "long", year:
   "numeric" })]: "June 01, 2025". *)
let format_date = function
  | None -> ""
  | Some date -> Calendar.format "MMMM dd, yyyy" date
;;

(* [new Date(text)], as the browser parses it, if it is a valid date. *)
let parse_date text =
  let d = new%js Js.date_fromTimeValue (Js.date##parse (Js.string text)) in
  if Float.is_nan (Js.to_float d##getTime)
  then None
  else
    Some
      (Date.create_exn
         ~y:d##getFullYear
         ~m:(Month.of_int_exn (d##getMonth + 1))
         ~d:d##getDate)
;;

let view (local_ graph) =
  let open_, set_open = Bonsai.state false graph in
  let initial = Date.create_exn ~y:2025 ~m:Jun ~d:1 in
  let date, set_date = Bonsai.state (Some initial) graph in
  let month, set_month = Bonsai.state initial graph in
  let focused, set_focused = Bonsai.state None graph in
  let value, set_value = Bonsai.state (format_date (Some initial)) graph in
  let id = Bonsai.path_id graph in
  let%arr open_
  and set_open
  and date
  and set_date
  and month
  and set_month
  and focused
  and set_focused
  and value
  and set_value
  and id in
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col gap-3" ]
    [ Label.view ~for_:"date" ~class_:"px-1" [ Node.text "Subscription Date" ]
    ; Node.div
        ~attrs:[ Attr.class_ "relative flex gap-2" ]
        [ Input.view
            ~id:"date"
            ~value
            ~placeholder:"June 01, 2025"
            ~class_:"bg-background pr-10"
            ~on_input:(fun text ->
              match parse_date text with
              | Some date ->
                Effect.Many
                  [ set_value text; set_date (Some date); set_month date ]
              | None -> set_value text)
            ~attrs:
              [ Attr.on_keydown (fun ev ->
                  match Dom_util.key ev with
                  | ArrowDown ->
                    Effect.Many [ Dom_util.prevent_default ev; set_open true ]
                  | _ -> Effect.Ignore)
              ]
            ()
        ; Popover.view
            ~id:("calendar-28-" ^ id)
            ~trigger_id:"date-picker"
            ~open_
            ~on_open_change:set_open
            (fun popover ->
               [ Popover.trigger
                   popover
                   (Button.view
                      ~variant:Ghost
                      ~class_:"absolute top-1/2 right-2 size-6 -translate-y-1/2"
                      [ Icon.view ~class_:"size-3.5" Calendar
                      ; Node.span
                          ~attrs:[ Attr.class_ "sr-only" ]
                          [ Node.text "Select date" ]
                      ])
               ; Popover.content
                   popover
                   ~class_:"w-auto overflow-hidden p-0"
                   ~align:End
                   ~align_offset:(-8.)
                   ~side_offset:10.
                   [ Calendar.view
                       ~id:("calendar-28-calendar-" ^ id)
                       ~selected:(Single date)
                       ~caption_layout:Dropdown
                       ~month
                       ~on_month_change:set_month
                       ~focused
                       ~on_focus:set_focused
                       ~on_select:(fun selection ->
                         let date =
                           match selection with
                           | Single date -> date
                           | Multiple _ | Range _ -> None
                         in
                         Effect.Many
                           [ set_date date
                           ; set_value (format_date date)
                           ; set_open false
                           ])
                       ()
                   ]
               ])
        ]
    ]
;;
