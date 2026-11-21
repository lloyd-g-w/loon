open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "slider"

(*$ Demo *)
let demo (local_ graph) =
  let%arr slider =
    Slider.component ~default_value:[ 50. ] ~max:100. ~step:1. ~class_:"w-[60%]" graph
  in
  slider.view
(*$*)

(*$ Range
   Two values make two thumbs, with the range between them filled. *)
let range (local_ graph) =
  let%arr slider =
    Slider.component
      ~default_value:[ 25.; 50. ]
      ~max:100.
      ~step:5.
      ~class_:"mx-auto w-full max-w-xs"
      graph
  in
  slider.view
(*$*)

(*$ Multiple Thumbs *)
let multiple (local_ graph) =
  let%arr slider =
    Slider.component
      ~default_value:[ 10.; 20.; 70. ]
      ~max:100.
      ~step:10.
      ~class_:"mx-auto w-full max-w-xs"
      graph
  in
  slider.view
(*$*)

(*$ Vertical *)
let vertical (local_ graph) =
  let first =
    Slider.component
      ~default_value:[ 50. ]
      ~max:100.
      ~step:1.
      ~orientation:Vertical
      ~class_:"h-40"
      graph
  in
  let second =
    Slider.component
      ~default_value:[ 25. ]
      ~max:100.
      ~step:1.
      ~orientation:Vertical
      ~class_:"h-40"
      graph
  in
  let%arr first and second in
  Node.div
    ~attrs:
      [ Attr.class_ "mx-auto flex w-full max-w-xs items-center justify-center gap-6" ]
    [ first.view; second.view ]
(*$*)

(*$ Controlled
   [Slider.view] takes the values and gets the new ones in [on_change]. *)
let controlled (local_ graph) =
  let value, set_value = Bonsai.state [ 0.3; 0.7 ] graph in
  let%arr value and set_value in
  Node.div
    ~attrs:[ Attr.class_ "mx-auto grid w-full max-w-xs gap-3" ]
    [ Node.div
        ~attrs:[ Attr.class_ "flex items-center justify-between gap-2" ]
        [ Label.view ~for_:"slider-demo-temperature" [ Node.text "Temperature" ]
        ; Node.span
            ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ]
            [ Node.text
                (String.concat
                   ~sep:", "
                   (List.map value ~f:(Float.to_string_hum ~strip_zero:true)))
            ]
        ]
    ; Slider.view
        ~attrs:[ Attr.id "slider-demo-temperature" ]
        ~value
        ~on_change:set_value
        ~min:0.
        ~max:1.
        ~step:0.1
        ()
    ]
(*$*)

(*$ Disabled *)
let disabled (local_ graph) =
  let%arr slider =
    Slider.component
      ~default_value:[ 50. ]
      ~max:100.
      ~step:1.
      ~disabled:true
      ~class_:"mx-auto w-full max-w-xs"
      graph
  in
  slider.view
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Slider"
    ~group:Forms
    ~description:"An input where the user selects a value from within a given range."
    ~usage:{|Slider.component ~default_value:[ 33. ] ~max:100. ~step:1. graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "value"
            , "float list"
            , "One thumb per value, in increasing order (controlled [view])." )
          ; ( "on_change"
            , "float list -> unit Effect.t"
            , "Gets the values after each move: sorted and on a step." )
          ; ( "default_value"
            , "float list"
            , "The first values of [component]; [[min; max]] by default." )
          ; "min, max", "float", "The ends of the range: 0 and 100 by default."
          ; "step", "float", "The values a thumb stops at; 1 by default."
          ; ( "min_steps_between_thumbs"
            , "int"
            , "How many steps apart thumbs must stay; 0 by default." )
          ; "orientation", "Slider.Orientation.t", "[Horizontal] or [Vertical]."
          ; "disabled", "bool", "Fades it and ignores the pointer and keys."
          ; "class_", "string", "More Tailwind classes for the root, merged last."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes for the root."
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.p
          "On a thumb: the arrow keys move it a step, Shift with an arrow or Page Up \
           and Page Down ten steps, Home and End to the ends. A thumb dragged past \
           another swaps places with it."
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Range" range
    ; Doc.example ~page "Multiple Thumbs" multiple
    ; Doc.example ~page "Vertical" vertical
    ; Doc.example ~page "Controlled" controlled
    ; Doc.example ~page "Disabled" disabled
    ]
;;
