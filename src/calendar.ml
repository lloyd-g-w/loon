open! Import
open Js_of_ocaml

let first_of_month d = Date.create_exn ~y:(Date.year d) ~m:(Date.month d) ~d:1

let start_of_week ~week_start d =
  let back =
    (Day_of_week.to_int (Date.day_of_week d) - Day_of_week.to_int week_start + 7) % 7
  in
  Date.add_days d (-back)
;;

let weeks ~week_start month =
  let start = start_of_week ~week_start (first_of_month month) in
  List.init 6 ~f:(fun w -> List.init 7 ~f:(fun d -> Date.add_days start ((7 * w) + d)))
;;

let moved ~week_start ~shift ~(key : Dom_html.Keyboard_code.t) d =
  match key with
  | ArrowLeft -> Some (Date.add_days d (-1))
  | ArrowRight -> Some (Date.add_days d 1)
  | ArrowUp -> Some (Date.add_days d (-7))
  | ArrowDown -> Some (Date.add_days d 7)
  | Home -> Some (start_of_week ~week_start d)
  | End -> Some (Date.add_days (start_of_week ~week_start d) 6)
  | PageUp -> Some (Date.add_months d (if shift then -12 else -1))
  | PageDown -> Some (Date.add_months d (if shift then 12 else 1))
  | _ -> None
;;

let month_name m =
  match (m : Month.t) with
  | Jan -> "January"
  | Feb -> "February"
  | Mar -> "March"
  | Apr -> "April"
  | May -> "May"
  | Jun -> "June"
  | Jul -> "July"
  | Aug -> "August"
  | Sep -> "September"
  | Oct -> "October"
  | Nov -> "November"
  | Dec -> "December"
;;

let day_name (d : Day_of_week.t) =
  match d with
  | Mon -> "Monday"
  | Tue -> "Tuesday"
  | Wed -> "Wednesday"
  | Thu -> "Thursday"
  | Fri -> "Friday"
  | Sat -> "Saturday"
  | Sun -> "Sunday"
;;

let long_date d =
  sprintf
    "%s, %d %s %d"
    (day_name (Date.day_of_week d))
    (Date.day d)
    (month_name (Date.month d))
    (Date.year d)
;;

let same_month a b = Date.year a = Date.year b && Month.equal (Date.month a) (Date.month b)
let day_id ~name d = sprintf "%s-day-%s" name (Date.to_string d)

let clamp ?min ?max d =
  let d = Option.value_map min ~default:d ~f:(fun m -> Date.max d m) in
  Option.value_map max ~default:d ~f:(fun m -> Date.min d m)
;;

let view_internal
  ?attrs:extra
  ?(week_start = Day_of_week.Mon)
  ?min
  ?max
  ?(is_disabled = fun _ -> false)
  ?today
  ~name
  ~focused
  ~selected
  ~update_focus
  ~on_select
  ()
  =
  let on_focus d = update_focus (Fn.const d) in
  let disabled d =
    is_disabled d
    || Option.value_map min ~default:false ~f:(fun m -> Date.( < ) d m)
    || Option.value_map max ~default:false ~f:(fun m -> Date.( > ) d m)
  in
  let caption_id = name ^ "-caption" in
  let grid_id = name ^ "-grid" in
  let on_keydown (ev : Dom_html.keyboardEvent Js.t) =
    match
      moved ~week_start ~shift:(Js.to_bool ev##.shiftKey) ~key:(Dom_util.key ev) focused
    with
    | None -> Effect.Ignore
    | Some _ ->
      let shift = Js.to_bool ev##.shiftKey and key = Dom_util.key ev in
      Effect.Many
        [ Dom_util.prevent_default ev
        ; update_focus (fun f ->
            Option.value_map (moved ~week_start ~shift ~key f) ~default:f ~f:(clamp ?min ?max))
        ; Dom_util.focus_selector (sprintf "#%s button[tabindex='0']" grid_id)
        ]
  in
  let nav ~label ~icon ~months =
    let blocked =
      match months < 0, min, max with
      | true, Some min, _ -> Date.( < ) (Date.add_days (first_of_month focused) (-1)) min
      | false, _, Some max ->
        Date.( > ) (first_of_month (Date.add_months (first_of_month focused) 1)) max
      | _ -> false
    in
    Node.button
      ~attrs:
        ([ Attr.class_ "loon-calendar-nav"
         ; Attr.type_ "button"
         ; aria "label" label
         ]
         @ if blocked then [ Attr.disabled ] else [ Attr.on_click (fun _ ->
                 update_focus (fun f -> clamp ?min ?max (Date.add_months f months)))
             ])
      [ Icon.view icon ]
  in
  let header_days =
    List.init 7 ~f:(fun i ->
      let day = Day_of_week.of_int_exn ((Day_of_week.to_int week_start + i) % 7) in
      Node.th
        ~attrs:
          [ Attr.class_ "loon-calendar-weekday"
          ; Attr.create "scope" "col"
          ; Attr.create "abbr" (day_name day)
          ]
        [ Node.text (String.prefix (day_name day) 2) ])
  in
  let cell d =
    let outside = not (same_month d focused) in
    let is_selected = Option.value_map selected ~default:false ~f:(Date.equal d) in
    let is_today = Option.value_map today ~default:false ~f:(Date.equal d) in
    let is_disabled = disabled d in
    Node.td
      ~attrs:
        ([ Attr.class_ "loon-calendar-cell"; Attr.role "gridcell"; aria_bool "selected" is_selected ]
         @ if is_disabled then [ aria "disabled" "true" ] else [])
      [ Node.button
          ~attrs:
            ([ Attr.class_ "loon-calendar-day"
             ; Attr.type_ "button"
             ; Attr.id (day_id ~name d)
             ; aria "label" (long_date d)
             ; Attr.tabindex (if Date.equal d focused then 0 else -1)
             ]
             @ List.filter_opt
                 [ Option.some_if is_selected (data "selected" "")
                 ; Option.some_if is_today (aria "current" "date")
                 ; Option.some_if outside (data "outside" "")
                 ]
             @
             if is_disabled
             then [ aria "disabled" "true" ]
             else [ Attr.on_click (fun _ -> Effect.Many [ on_focus d; on_select d ]) ])
          [ Node.text (Int.to_string (Date.day d)) ]
      ]
  in
  Node.div
    ~attrs:(attrs ?attrs:extra [ "loon-calendar" ])
    [ Node.div
        ~attrs:[ Attr.class_ "loon-calendar-header" ]
        [ nav ~label:"Previous month" ~icon:Chevron_left ~months:(-1)
        ; Node.div
            ~attrs:[ Attr.class_ "loon-calendar-caption"; Attr.id caption_id; aria "live" "polite" ]
            [ Node.textf "%s %d" (month_name (Date.month focused)) (Date.year focused) ]
        ; nav ~label:"Next month" ~icon:Chevron_right ~months:1
        ]
    ; Node.table
        ~attrs:
          [ Attr.class_ "loon-calendar-grid"
          ; Attr.id grid_id
          ; Attr.role "grid"
          ; aria "labelledby" caption_id
          ; Attr.on_keydown on_keydown
          ]
        [ Node.thead [ Node.tr header_days ]
        ; Node.tbody
            (List.map (weeks ~week_start focused) ~f:(fun week ->
               Node.tr (List.map week ~f:cell)))
        ]
    ]
;;

let view ?attrs ?week_start ?min ?max ?is_disabled ?today ~name ~focused ~selected ~on_focus ~on_select () =
  view_internal
    ?attrs
    ?week_start
    ?min
    ?max
    ?is_disabled
    ?today
    ~name
    ~focused
    ~selected
    ~update_focus:(fun f -> on_focus (f focused))
    ~on_select
    ()
;;

type t =
  { view : Node.t
  ; selected : Date.t option
  }

let local_today () =
  let now = new%js Js.date_now in
  Date.create_exn
    ~y:now##getFullYear
    ~m:(Month.of_int_exn (now##getMonth + 1))
    ~d:now##getDate
;;

let component ?attrs ?week_start ?min ?max ?is_disabled ?today ?default (local_ graph) =
  let today = match today with Some t -> t | None -> local_today () in
  let selected, set_selected = Bonsai.state default graph in
  let focused, update_focused =
    Bonsai.state' (clamp ?min ?max (Option.value default ~default:today)) graph
  in
  let name = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr selected and set_selected and focused and update_focused and name in
  { view =
      view_internal
        ?attrs
        ?week_start
        ?min
        ?max
        ?is_disabled
        ~today
        ~name:("loon" ^ name)
        ~focused
        ~selected
        ~update_focus:update_focused
        ~on_select:(fun d -> set_selected (Some d))
        ()
  ; selected
  }
;;
