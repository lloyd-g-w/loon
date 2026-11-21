open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let time_slots =
  List.init 37 ~f:(fun i ->
    let total_minutes = i * 15 in
    sprintf "%02d:%02d" ((total_minutes / 60) + 9) (total_minutes % 60))
;;

let booked_dates = List.init 3 ~f:(fun i -> Date.create_exn ~y:2025 ~m:Jun ~d:(17 + i))
let is_booked d = List.mem booked_dates d ~equal:Date.equal

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~default_month:(Date.create_exn ~y:2025 ~m:Jun ~d:12)
      ~disabled:is_booked
      ~show_outside_days:false
      ~modifiers:[ is_booked, "[&>button]:line-through opacity-100" ]
      ~class_:
        "bg-transparent p-0 [--cell-size:--spacing(10)] md:[--cell-size:--spacing(12)]"
      ~format_weekday_name:(fun day ->
        String.prefix (Day_of_week.to_string_long day |> String.capitalize) 3)
      ~default:(Single (Some (Date.create_exn ~y:2025 ~m:Jun ~d:12)))
      graph
  in
  let selected_time, set_selected_time = Bonsai.state (Some "10:00") graph in
  let%arr calendar and selected_time and set_selected_time in
  let date =
    match calendar.selected with
    | Single d -> d
    | Multiple _ | Range _ -> None
  in
  Card.root
    ~class_:"gap-0 p-0"
    [ Card.content
        ~class_:"relative p-0 md:pr-48"
        [ Node.div ~attrs:[ Attr.class_ "p-6" ] [ calendar.view ]
        ; Node.div
            ~attrs:
              [ Attr.class_
                  "no-scrollbar inset-y-0 right-0 flex max-h-72 w-full scroll-pb-6 \
                   flex-col gap-4 overflow-y-auto border-t p-6 md:absolute \
                   md:max-h-none md:w-48 md:border-t-0 md:border-l"
              ]
            [ Node.div
                ~attrs:[ Attr.class_ "grid gap-2" ]
                (List.map time_slots ~f:(fun time ->
                   Button.view
                     ~variant:
                       (if Option.equal String.equal selected_time (Some time)
                        then Default
                        else Outline)
                     ~on_click:(set_selected_time (Some time))
                     ~class_:"w-full shadow-none"
                     [ Node.text time ]))
            ]
        ]
    ; Card.footer
        ~class_:"flex flex-col gap-4 border-t px-6 !py-5 md:flex-row"
        [ Node.div
            ~attrs:[ Attr.class_ "text-sm" ]
            (match date, selected_time with
             | Some date, Some time ->
               [ Node.text "Your meeting is booked for "
               ; Node.span
                   ~attrs:[ Attr.class_ "font-medium" ]
                   [ Node.text (" " ^ Calendar.format "EEEE, MMMM d" date ^ " ") ]
               ; Node.text "at "
               ; Node.span ~attrs:[ Attr.class_ "font-medium" ] [ Node.text time ]
               ; Node.text "."
               ]
             | _ -> [ Node.text "Select a date and time for your meeting." ])
        ; Button.view
            ~disabled:(Option.is_none date || Option.is_none selected_time)
            ~class_:"w-full md:ml-auto md:w-auto"
            ~variant:Outline
            [ Node.text "Continue" ]
        ]
    ]
;;
