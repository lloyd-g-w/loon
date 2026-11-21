open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node

module Language = struct
  type t =
    | En
    | Es
  [@@deriving sexp_of, equal]

  let of_string = function
    | "en" -> En
    | _ -> Es
  ;;

  let to_string = function
    | En -> "en"
    | Es -> "es"
  ;;

  let title = function
    | En -> "Book an appointment"
    | Es -> "Reserva una cita"
  ;;

  let description = function
    | En -> "Select the dates for your appointment"
    | Es -> "Selecciona las fechas para tu cita"
  ;;
end

let view (local_ graph) =
  let locale, set_locale = Bonsai.state Language.Es graph in
  let date_range, set_date_range =
    Bonsai.state
      (Calendar.Selection.Range
         (Some
            { from = Date.create_exn ~y:2025 ~m:Sep ~d:9
            ; to_ = Some (Date.create_exn ~y:2025 ~m:Sep ~d:17)
            }))
      graph
  in
  let month, set_month =
    Bonsai.state (Date.create_exn ~y:2025 ~m:Sep ~d:9) graph
  in
  let focused, set_focused = Bonsai.state None graph in
  let select_state, set_select_state = Bonsai.state Select.State.closed graph in
  let id = Bonsai.path_id graph in
  let%arr locale
  and set_locale
  and date_range
  and set_date_range
  and month
  and set_month
  and focused
  and set_focused
  and select_state
  and set_select_state
  and id in
  Card.root
    [ Card.header
        ~class_:"border-b"
        [ Card.title [ Node.text (Language.title locale) ]
        ; Card.description [ Node.text (Language.description locale) ]
        ; Card.action
            [ Select.view
                ~id:("calendar-12-language" ^ id)
                ~value:(Some (Language.to_string locale))
                ~on_value_change:(fun value ->
                  set_locale (Language.of_string value))
                ~state:select_state
                ~on_state_change:set_select_state
                (Select.trigger ~class_:"w-[100px]" ~placeholder:"Language" ())
                (Select.content
                   ~align:End
                   [ Select.item ~value:"es" [ Node.text "Español" ]
                   ; Select.item ~value:"en" [ Node.text "English" ]
                   ])
            ]
        ]
    ; Card.content
        [ Calendar.view
            ~id:("calendar-12-calendar" ^ id)
            ~selected:date_range
            ~on_select:set_date_range
            ~month
            ~on_month_change:set_month
            ~focused
            ~on_focus:set_focused
            ~number_of_months:2
            ~locale:
              (match locale with
               | Es -> Calendar.Locale.es
               | En -> Calendar.Locale.en_us)
            ~class_:"bg-transparent p-0"
            ~button_variant:Outline
            ()
        ]
    ]
;;
