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

let page = "slider"

(*$ Default *)
let default (local_ graph) =
  let%arr volume = Slider.component ~default:40. ~show_value:true graph in
  narrow [ volume.view ]
;;

(*$*)

(*$ With a label and a format *)
let temperature (local_ graph) =
  let%arr temp =
    Slider.component
      ~min:16.
      ~max:30.
      ~step:0.5
      ~default:21.5
      ~show_value:true
      ~format:(fun t -> sprintf "%.1f °C" t)
      graph
  in
  narrow
    [ Field.view
        ~id:"slider-temp"
        ~label:"Thermostat"
        ~description:
          (if Float.(temp.value > 24.) then "Toasty." else "Just right.")
        (fun attrs ->
           Slider.view
             ~attrs
             ~min:16.
             ~max:30.
             ~step:0.5
             ~show_value:true
             ~format:(fun t -> sprintf "%.1f °C" t)
             ~value:temp.value
             ~on_change:temp.set
             ())
    ]
;;

(*$*)

(*$ Disabled *)
let disabled =
  narrow
    [ Slider.view
        ~disabled:true
        ~value:60.
        ~on_change:(fun _ -> Effect.Ignore)
        ()
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Slider"
    ~group:Forms
    ~description:
      "Picks a number in a range by dragging, or with the arrow keys."
    ~usage:{|Slider.view ~min:0. ~max:100. ~value ~on_change:set_value ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "value", "float", "The current value (clamped to the range)."
          ; ( "on_change"
            , "float -> unit Effect.t"
            , "Gets each new value while dragging." )
          ; ( "min, max, step"
            , "float"
            , "The range (0 to 100 by default) and its increments (1)." )
          ; "show_value", "bool", "Prints the value beside the track."
          ; ( "format"
            , "float -> string"
            , "How the value is printed and announced." )
          ; "disabled", "bool", "Greys it out."
          ]
      ]
    [ Doc.example ~page "Default" default
    ; Doc.example ~page "With a label and a format" temperature
    ; Doc.static ~page "Disabled" disabled
    ]
;;
