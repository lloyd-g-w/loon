open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node

let view (local_ graph) =
  let dropdown, set_dropdown =
    Bonsai.state Calendar.Caption_layout.Dropdown graph
  in
  let date, set_date =
    Bonsai.state
      (Calendar.Selection.Single (Some (Date.create_exn ~y:2025 ~m:Jun ~d:12)))
      graph
  in
  let month, set_month =
    Bonsai.state (Date.create_exn ~y:2025 ~m:Jun ~d:12) graph
  in
  let focused, set_focused = Bonsai.state None graph in
  let select_state, set_select_state = Bonsai.state Select.State.closed graph in
  let id = Bonsai.path_id graph in
  let%arr dropdown
  and set_dropdown
  and date
  and set_date
  and month
  and set_month
  and focused
  and set_focused
  and select_state
  and set_select_state
  and id in
  Node.div
    ~attrs:[ Vdom.Attr.class_ "flex flex-col gap-4" ]
    [ Calendar.view
        ~id:("calendar-13-calendar" ^ id)
        ~month
        ~on_month_change:set_month
        ~focused
        ~on_focus:set_focused
        ~selected:date
        ~on_select:set_date
        ~caption_layout:dropdown
        ~class_:"rounded-lg border shadow-sm"
        ()
    ; Node.div
        ~attrs:[ Vdom.Attr.class_ "flex flex-col gap-3" ]
        [ Label.view ~for_:"dropdown" ~class_:"px-1" [ Node.text "Dropdown" ]
        ; Select.view
            ~id:("calendar-13-dropdown" ^ id)
            ~value:(Some (Calendar.Caption_layout.name dropdown))
            ~on_value_change:(fun value ->
              match
                List.find Calendar.Caption_layout.all ~f:(fun layout ->
                  String.equal (Calendar.Caption_layout.name layout) value)
              with
              | Some layout -> set_dropdown layout
              | None -> Effect.Ignore)
            ~state:select_state
            ~on_state_change:set_select_state
            (Select.trigger
               ~id:"dropdown"
               ~size:Sm
               ~class_:"bg-background w-full"
               ~placeholder:"Dropdown"
               ())
            (Select.content
               ~align:Center
               [ Select.item ~value:"dropdown" [ Node.text "Month and Year" ]
               ; Select.item ~value:"dropdown-months" [ Node.text "Month Only" ]
               ; Select.item ~value:"dropdown-years" [ Node.text "Year Only" ]
               ])
        ]
    ]
;;
