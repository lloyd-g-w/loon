open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Js_of_ocaml
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let format_date = function
  | None -> ""
  | Some date -> Calendar.format "MMMM dd, yyyy" date
;;

let number = function
  | "a" | "an" | "one" -> Some 1
  | "two" -> Some 2
  | "three" -> Some 3
  | "four" -> Some 4
  | "five" -> Some 5
  | "six" -> Some 6
  | "seven" -> Some 7
  | "eight" -> Some 8
  | "nine" -> Some 9
  | "ten" -> Some 10
  | s -> Int.of_string_opt s
;;

let shift ~today n unit =
  match String.chop_suffix unit ~suffix:"s" |> Option.value ~default:unit with
  | "day" -> Some (Date.add_days today n)
  | "week" -> Some (Date.add_days today (7 * n))
  | "month" -> Some (Date.add_months today n)
  | "year" -> Some (Date.add_months today (12 * n))
  | _ -> None
;;

let weekday s =
  List.find Day_of_week.all ~f:(fun d ->
    let name = String.lowercase (Day_of_week.to_string_long d) in
    String.equal s name || String.equal s (String.prefix name 3))
;;

(* The next [d] after [today] (or [today] itself if [or_today]). *)
let next_weekday ?(or_today = false) ~today d =
  let ahead =
    (Day_of_week.to_int d - Day_of_week.to_int (Date.day_of_week today) + 7) % 7
  in
  Date.add_days today (if ahead = 0 && not or_today then 7 else ahead)
;;

(* [new Date(text)], as the browser parses it ("June 01, 2025"). *)
let js_date text =
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

(* A small stand-in for chrono-node's [parseDate], for the phrases the
   placeholder suggests: "today", "tomorrow", "in 2 days", "next week",
   "3 weeks ago", "friday", "next monday", and dates as [Date] reads them. *)
let parse_date ?(today = Calendar.today ()) text =
  let words =
    String.lowercase text
    |> String.split_on_chars ~on:[ ' '; '\t'; ',' ]
    |> List.filter ~f:(Fn.non String.is_empty)
  in
  match words with
  | [ "today" ] | [ "now" ] -> Some today
  | [ "tomorrow" ] -> Some (Date.add_days today 1)
  | [ "yesterday" ] -> Some (Date.add_days today (-1))
  | [ "in"; n; unit ] ->
    Option.bind (number n) ~f:(fun n -> shift ~today n unit)
  | [ n; unit; "ago" ] ->
    Option.bind (number n) ~f:(fun n -> shift ~today (-n) unit)
  | [ (("next" | "last") as dir); unit ] ->
    let n = if String.equal dir "next" then 1 else -1 in
    (match weekday unit with
     | Some d when n = 1 -> Some (next_weekday ~today d)
     | Some d ->
       Some (Date.add_days (next_weekday ~or_today:true ~today d) (-7))
     | None -> shift ~today n unit)
  | ([ ("this" | "on"); day ] | [ day ]) when Option.is_some (weekday day) ->
    Option.map (weekday day) ~f:(next_weekday ~or_today:true ~today)
  | _ -> js_date text
;;

let view (local_ graph) =
  let initial = parse_date "In 2 days" in
  let open_, set_open = Bonsai.state false graph in
  let value, set_value = Bonsai.state "In 2 days" graph in
  let date, set_date = Bonsai.state initial graph in
  let month, set_month =
    Bonsai.state (Option.value initial ~default:(Calendar.today ())) graph
  in
  let focused, set_focused = Bonsai.state None graph in
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
    [ Label.view ~for_:"date" ~class_:"px-1" [ Node.text "Schedule Date" ]
    ; Node.div
        ~attrs:[ Attr.class_ "relative flex gap-2" ]
        [ Input.view
            ~id:"date"
            ~value
            ~placeholder:"Tomorrow or next week"
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
            ~id:("calendar-29-" ^ id)
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
                   [ Calendar.view
                       ~id:("calendar-29-calendar-" ^ id)
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
    ; Node.div
        ~attrs:[ Attr.class_ "text-muted-foreground px-1 text-sm" ]
        [ Node.text "Your post will be published on "
        ; Node.span
            ~attrs:[ Attr.class_ "font-medium" ]
            [ Node.text (format_date date) ]
        ; Node.text "."
        ]
    ]
;;
