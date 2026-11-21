open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "calendar"

(*$ Demo *)
let demo (local_ graph) =
  let calendar =
    Calendar.component
      ~class_:"rounded-md border shadow-sm"
      ~caption_layout:Dropdown
      ~default:(Single (Some (Calendar.today ())))
      graph
  in
  let%arr calendar in
  calendar.view
(*$*)

(*$ Basic
   A basic calendar, with [~class_:"rounded-lg border"]. *)
let basic (local_ graph) =
  let calendar =
    Calendar.component ~class_:"rounded-lg border" ~default:(Single None) graph
  in
  let%arr calendar in
  calendar.view
(*$*)

(*$ Range Calendar
   [Range] selects a range of dates, here over two months. *)
let range (local_ graph) =
  let today = Calendar.today () in
  let from = Date.create_exn ~y:(Date.year today) ~m:Jan ~d:12 in
  let calendar =
    Calendar.component
      ~default_month:from
      ~number_of_months:2
      ~disabled:(fun date ->
        Date.( > ) date today || Date.( < ) date (Date.of_string "1900-01-01"))
      ~default:(Range (Some { from; to_ = Some (Date.add_days from 30) }))
      graph
  in
  let%arr calendar in
  Card.root ~class_:"mx-auto w-fit p-0" [ Card.content ~class_:"p-0" [ calendar.view ] ]
(*$*)

(*$ Month and Year Selector
   [~caption_layout:Dropdown] shows a month and a year dropdown. *)
let caption (local_ graph) =
  let calendar =
    Calendar.component
      ~class_:"rounded-lg border"
      ~caption_layout:Dropdown
      ~default:(Single None)
      graph
  in
  let%arr calendar in
  calendar.view
(*$*)

(*$ Multiple
   [Multiple] selects any number of dates. *)
let multiple (local_ graph) =
  let calendar = Calendar.component ~default:(Multiple []) graph in
  let%arr calendar in
  Card.root ~class_:"mx-auto w-fit p-0" [ Card.content ~class_:"p-0" [ calendar.view ] ]
(*$*)

(*$ Presets
   The buttons set both the date and the month shown. *)
let presets (local_ graph) =
  let today = Calendar.today () in
  let calendar =
    Calendar.component
      ~fixed_weeks:true
      ~class_:"p-0 [--cell-size:--spacing(9.5)]"
      ~default:(Single (Some (Date.create_exn ~y:(Date.year today) ~m:Feb ~d:12)))
      graph
  in
  let%arr calendar in
  let preset (label, days) =
    let date = Date.add_days (Calendar.today ()) days in
    Button.view
      ~variant:Outline
      ~size:Sm
      ~class_:"flex-1"
      ~on_click:
        (Effect.Many [ calendar.set_selected (Single (Some date)); calendar.set_month date ])
      [ Node.text label ]
  in
  Card.root
    ~class_:"mx-auto w-fit max-w-[300px]"
    [ Card.content [ calendar.view ]
    ; Card.footer
        ~class_:"flex flex-wrap gap-2 border-t"
        (List.map
           ~f:preset
           [ "Today", 0; "Tomorrow", 1; "In 3 days", 3; "In a week", 7; "In 2 weeks", 14 ])
    ]
(*$*)

(*$ Booked dates
   Booked days are disabled and struck through, with [~modifiers]. *)
let booked (local_ graph) =
  let year = Date.year (Calendar.today ()) in
  let booked date =
    Date.between
      date
      ~low:(Date.create_exn ~y:year ~m:Feb ~d:12)
      ~high:(Date.create_exn ~y:year ~m:Feb ~d:26)
  in
  let date = Date.create_exn ~y:year ~m:Feb ~d:3 in
  let calendar =
    Calendar.component
      ~default_month:date
      ~disabled:booked
      ~modifiers:[ booked, "[&>button]:line-through opacity-100" ]
      ~default:(Single (Some date))
      graph
  in
  let%arr calendar in
  Card.root ~class_:"mx-auto w-fit p-0" [ Card.content ~class_:"p-0" [ calendar.view ] ]
(*$*)

(*$ Custom Cell Size
   A calendar with custom cell size that's responsive: [--cell-size] sets
   it, per breakpoint. [~day_content] adds a price under each day. *)
let custom_days (local_ graph) =
  let from = Date.create_exn ~y:(Date.year (Calendar.today ())) ~m:Dec ~d:8 in
  let calendar =
    Calendar.component
      ~default_month:from
      ~caption_layout:Dropdown
      ~class_:"[--cell-size:--spacing(10)] md:[--cell-size:--spacing(12)]"
      ~day_content:(fun date ~outside ->
        let weekend =
          match Date.day_of_week date with
          | Sat | Sun -> true
          | _ -> false
        in
        Node.text (Int.to_string (Date.day date))
        :: (if outside then [] else [ Node.span [ Node.text (if weekend then "$120" else "$100") ] ]))
      ~default:(Range (Some { from; to_ = Some (Date.add_days from 10) }))
      graph
  in
  let%arr calendar in
  Card.root ~class_:"mx-auto w-fit p-0" [ Card.content ~class_:"p-0" [ calendar.view ] ]
(*$*)

(*$ Week Numbers
   [~show_week_number:true] adds the week of the year to each row. *)
let week_numbers (local_ graph) =
  let date = Date.create_exn ~y:(Date.year (Calendar.today ())) ~m:Feb ~d:3 in
  let calendar =
    Calendar.component
      ~default_month:date
      ~show_week_number:true
      ~default:(Single (Some date))
      graph
  in
  let%arr calendar in
  Card.root ~class_:"mx-auto w-fit p-0" [ Card.content ~class_:"p-0" [ calendar.view ] ]
(*$*)

(*$ Date Picker
   A calendar in a popover. *)
let date_picker (local_ graph) =
  let open_, set_open = Bonsai.state false graph in
  let calendar = Calendar.component ~default:(Single None) graph in
  let%arr calendar and open_ and set_open in
  let date =
    match calendar.selected with
    | Single date -> date
    | Multiple _ | Range _ -> None
  in
  Popover.view ~id:"date-picker" ~open_ ~on_open_change:set_open (fun popover ->
    [ Popover.trigger
        popover
        (Button.view
           ~variant:Outline
           ~class_:
             (Cn.cn
                [ "w-[240px] justify-start text-left font-normal"
                ; (if Option.is_none date then "text-muted-foreground" else "")
                ])
           [ Icon.view Calendar
           ; (match date with
              | Some date -> Node.text (Calendar.format "PPP" date)
              | None -> Node.span [ Node.text "Pick a date" ])
           ])
    ; Popover.content popover ~class_:"w-auto p-0" ~align:Start [ calendar.view ]
    ])
(*$*)

(*$ Date Picker with Presets
   A select of presets above the calendar. *)
let date_picker_presets (local_ graph) =
  let open_, set_open = Bonsai.state false graph in
  let calendar = Calendar.component ~default:(Single None) graph in
  let select_state, set_select_state = Bonsai.state Select.State.closed graph in
  let preset, set_preset = Bonsai.state None graph in
  let%arr calendar
  and open_
  and set_open
  and select_state
  and set_select_state
  and preset
  and set_preset in
  let date =
    match calendar.selected with
    | Single date -> date
    | Multiple _ | Range _ -> None
  in
  Popover.view ~id:"date-picker-presets" ~open_ ~on_open_change:set_open (fun popover ->
    [ Popover.trigger
        popover
        (Button.view
           ~variant:Outline
           ~class_:
             (Cn.cn
                [ "w-[240px] justify-start text-left font-normal"
                ; (if Option.is_none date then "text-muted-foreground" else "")
                ])
           [ Icon.view Calendar
           ; (match date with
              | Some date -> Node.text (Calendar.format "PPP" date)
              | None -> Node.span [ Node.text "Pick a date" ])
           ])
    ; Popover.content
        popover
        ~class_:"flex w-auto flex-col space-y-2 p-2"
        ~align:Start
        [ Select.view
            ~id:"date-picker-presets-select"
            ~value:preset
            ~on_value_change:(fun value ->
              let date = Date.add_days (Calendar.today ()) (Int.of_string value) in
              Effect.Many
                [ set_preset (Some value)
                ; calendar.set_selected (Single (Some date))
                ; calendar.set_month date
                ])
            ~state:select_state
            ~on_state_change:set_select_state
            (Select.trigger ~class_:"w-full" ~placeholder:"Select" ())
            (Select.content
               ~position:Popper
               [ Select.item ~value:"0" [ Node.text "Today" ]
               ; Select.item ~value:"1" [ Node.text "Tomorrow" ]
               ; Select.item ~value:"3" [ Node.text "In 3 days" ]
               ; Select.item ~value:"7" [ Node.text "In a week" ]
               ])
        ; Node.div ~attrs:[ Attr.class_ "rounded-md border" ] [ calendar.view ]
        ]
    ])
(*$*)

(*$ Date Range Picker
   A range over two months, in a popover. *)
let date_range_picker (local_ graph) =
  let open_, set_open = Bonsai.state false graph in
  let from = Date.of_string "2022-01-20" in
  let calendar =
    Calendar.component
      ~default_month:from
      ~number_of_months:2
      ~default:(Range (Some { from; to_ = Some (Date.add_days from 20) }))
      graph
  in
  let%arr calendar and open_ and set_open in
  let range =
    match calendar.selected with
    | Range range -> range
    | Single _ | Multiple _ -> None
  in
  Node.div
    ~attrs:[ Attr.class_ "grid gap-2" ]
    [ Popover.view ~id:"date-range-picker" ~open_ ~on_open_change:set_open (fun popover ->
        [ Popover.trigger
            popover
            (Button.view
               ~variant:Outline
               ~class_:
                 (Cn.cn
                    [ "w-[300px] justify-start text-left font-normal"
                    ; (if Option.is_none range then "text-muted-foreground" else "")
                    ])
               [ Icon.view Calendar
               ; (match range with
                  | Some { from; to_ = Some to_ } ->
                    Node.text
                      (Calendar.format "LLL dd, y" from
                       ^ " - "
                       ^ Calendar.format "LLL dd, y" to_)
                  | Some { from; to_ = None } -> Node.text (Calendar.format "LLL dd, y" from)
                  | None -> Node.span [ Node.text "Pick a date" ])
               ])
        ; Popover.content popover ~class_:"w-auto p-0" ~align:Start [ calendar.view ]
        ])
    ]
(*$*)

(*$ Date of Birth Picker
   A dropdown caption to jump to a year; picking a day closes the
   popover. *)
let date_of_birth (local_ graph) =
  let open_, set_open = Bonsai.state false graph in
  let calendar =
    Calendar.component
      ~caption_layout:Dropdown
      ~on_select:(Bonsai.map set_open ~f:(fun set_open _ -> set_open false))
      ~default:(Single None)
      graph
  in
  let%arr calendar and open_ and set_open in
  let date =
    match calendar.selected with
    | Single date -> date
    | Multiple _ | Range _ -> None
  in
  Node.div
    ~attrs:[ Attr.class_ "mx-auto flex w-44 flex-col gap-3" ]
    [ Label.view ~for_:"date-of-birth-trigger" ~class_:"px-1" [ Node.text "Date of birth" ]
    ; Popover.view ~id:"date-of-birth" ~open_ ~on_open_change:set_open (fun popover ->
        [ Popover.trigger
            popover
            (Button.view
               ~variant:Outline
               ~class_:"w-48 justify-between font-normal"
               [ Node.text
                   (match date with
                    | Some date -> Calendar.format "P" date
                    | None -> "Select date")
               ; Icon.view Chevron_down
               ])
        ; Popover.content
            popover
            ~class_:"w-auto overflow-hidden p-0"
            ~align:Start
            [ calendar.view ]
        ])
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Calendar"
    ~group:Forms
    ~description:
      "A calendar component that allows users to select a date or a range of dates."
    ~usage:
      {|let calendar =
  Calendar.component
    ~class_:"rounded-lg border"
    ~default:(Single (Some (Calendar.today ())))
    graph
in
let%arr calendar in
calendar.view|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "default"
            , "Calendar.Selection.t"
            , "[Calendar.component]: the selection at first, which sets the mode: [Single \
               (Some date)], [Multiple dates] or [Range (Some { from; to_ })]. \
               [Calendar.view] takes [~selected] and [~on_select] instead." )
          ; ( "caption_layout"
            , "Calendar.Caption_layout.t"
            , "[Label] (default), [Dropdown], [Dropdown_months] or [Dropdown_years]." )
          ; "number_of_months", "int", "Months shown side by side (default 1)."
          ; "default_month", "Date.t", "The month shown at first (default today's)."
          ; "disabled", "Date.t -> bool", "Days that cannot be selected."
          ; ( "start_month, end_month"
            , "Date.t"
            , "Bound the navigation (and the year dropdown's years)." )
          ; "show_outside_days", "bool", "Days of the next and previous months (default true)."
          ; "show_week_number", "bool", "A column of week numbers."
          ; "fixed_weeks", "bool", "Always six weeks."
          ; "week_starts_on", "Day_of_week.t", "Default [Sun]."
          ; "required", "bool", "The selection cannot be emptied by clicking it again."
          ; "min, max", "int", "Days in a multiple selection, or nights in a range."
          ; ( "modifiers"
            , "((Date.t -> bool) * string) list"
            , "Classes for the days each function matches." )
          ; ( "day_content"
            , "Date.t -> outside:bool -> Node.t list"
            , "What a day's button shows (default its number)." )
          ; "button_variant", "Button.Variant.t", "The navigation buttons' (default [Ghost])."
          ]
      ; Doc.p
          "[Calendar.component] returns the view, the selection and the month shown, \
           with effects to set them. [Calendar.format] formats dates with date-fns's \
           tokens ([PPP]: June 9th, 2025)."
      ; Doc.h2 "Keyboard"
      ; Doc.table
          [ "Key"; "Does" ]
          [ [ Doc.text "Arrow keys"; Doc.text "Move by a day or a week." ]
          ; [ Doc.text "Home / End"; Doc.text "Move to the start or end of the week." ]
          ; [ Doc.text "Page Up / Page Down"; Doc.text "Move by a month (with Shift, a year)." ]
          ; [ Doc.text "Enter / Space"; Doc.text "Select the focused day." ]
          ]
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Basic" basic
    ; Doc.example ~page "Range Calendar" range
    ; Doc.example ~page "Month and Year Selector" caption
    ; Doc.example ~page "Multiple" multiple
    ; Doc.example ~page "Presets" presets
    ; Doc.example ~page "Booked dates" booked
    ; Doc.example ~page "Custom Cell Size" custom_days
    ; Doc.example ~page "Week Numbers" week_numbers
    ; Doc.example ~page "Date Picker" date_picker
    ; Doc.example ~page "Date Picker with Presets" date_picker_presets
    ; Doc.example ~page "Date Range Picker" date_range_picker
    ; Doc.example ~page "Date of Birth Picker" date_of_birth
    ]
;;
