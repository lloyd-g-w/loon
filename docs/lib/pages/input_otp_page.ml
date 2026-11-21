open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "input_otp"

(*$ Demo *)
let demo (local_ graph) =
  let%arr otp =
    Input_otp.component
      ~max_length:6
      (return (fun otp ->
         [ Input_otp.group
             [ Input_otp.slot otp ~index:0
             ; Input_otp.slot otp ~index:1
             ; Input_otp.slot otp ~index:2
             ]
         ; Input_otp.separator ()
         ; Input_otp.group
             [ Input_otp.slot otp ~index:3
             ; Input_otp.slot otp ~index:4
             ; Input_otp.slot otp ~index:5
             ]
         ]))
      graph
  in
  otp.view
(*$*)

(*$ Pattern
   [pattern] refuses other characters: here letters and digits. *)
let pattern (local_ graph) =
  let%arr otp =
    Input_otp.component
      ~max_length:6
      ~pattern:Digits_and_chars
      (return (fun otp ->
         [ Input_otp.group
             (List.init 6 ~f:(fun index -> Input_otp.slot otp ~index))
         ]))
      graph
  in
  otp.view
(*$*)

(*$ Separator *)
let separator (local_ graph) =
  let%arr otp =
    Input_otp.component
      ~max_length:6
      (return (fun otp ->
         [ Input_otp.group [ Input_otp.slot otp ~index:0; Input_otp.slot otp ~index:1 ]
         ; Input_otp.separator ()
         ; Input_otp.group [ Input_otp.slot otp ~index:2; Input_otp.slot otp ~index:3 ]
         ; Input_otp.separator ()
         ; Input_otp.group [ Input_otp.slot otp ~index:4; Input_otp.slot otp ~index:5 ]
         ]))
      graph
  in
  otp.view
(*$*)

(*$ Controlled
   The component's [value] is the code typed so far. *)
let controlled (local_ graph) =
  let%arr otp =
    Input_otp.component
      ~max_length:6
      (return (fun otp ->
         [ Input_otp.group
             (List.init 6 ~f:(fun index -> Input_otp.slot otp ~index))
         ]))
      graph
  in
  Node.div
    ~attrs:[ Attr.class_ "space-y-2" ]
    [ otp.view
    ; Node.div
        ~attrs:[ Attr.class_ "text-center text-sm" ]
        [ (if String.is_empty otp.value
           then Node.text "Enter your one-time password."
           else Node.textf "You entered: %s" otp.value)
        ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Input OTP"
    ~group:Forms
    ~description:"Accessible one-time password component with copy paste functionality."
    ~usage:
      {|Input_otp.component ~max_length:6
  (return (fun otp ->
     [ Input_otp.group
         [ Input_otp.slot otp ~index:0
         ; Input_otp.slot otp ~index:1
         ; Input_otp.slot otp ~index:2
         ]
     ; Input_otp.separator ()
     ; Input_otp.group
         [ Input_otp.slot otp ~index:3
         ; Input_otp.slot otp ~index:4
         ; Input_otp.slot otp ~index:5
         ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "max_length", "int", "How many characters the code has."
          ; ( "pattern"
            , "Input_otp.Pattern.t"
            , "[Digits], [Chars] or [Digits_and_chars]: what may be typed or pasted." )
          ; "default_value", "string", "The code at first; empty by default."
          ; "disabled", "bool", "Fades it and ignores typing."
          ; "id", "string", "The <input>'s id, for a label."
          ; "class_", "string", "More Tailwind classes for the <input>."
          ; "container_class", "string", "More Tailwind classes for the container."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes for the <input>."
          ]
      ; Doc.p
          "The last argument lays out the slots from the component's state: \
           [Input_otp.group] joins slots, [Input_otp.slot otp ~index] shows one \
           character, [Input_otp.separator ()] goes between groups. One hidden \
           <input> takes the typing, so paste and one-time-code autofill work."
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Pattern" pattern
    ; Doc.example ~page "Separator" separator
    ; Doc.example ~page "Controlled" controlled
    ]
;;
