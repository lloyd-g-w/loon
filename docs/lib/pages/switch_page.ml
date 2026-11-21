open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "switch"

(*$ Demo *)
let demo (local_ graph) =
  let%arr airplane = Switch.component ~id:"airplane-mode" graph in
  Node.div
    ~attrs:[ Attr.class_ "flex items-center space-x-2" ]
    [ airplane.view; Label.view ~for_:"airplane-mode" [ Node.text "Airplane Mode" ] ]
(*$*)

(*$ Description *)
let description (local_ graph) =
  let%arr focus_mode = Switch.component ~id:"switch-focus-mode" graph in
  Field.root
    ~orientation:Horizontal
    ~class_:"max-w-sm"
    [ Field.content
        [ Field.label ~for_:"switch-focus-mode" [ Node.text "Share across devices" ]
        ; Field.description
            [ Node.text
                "Focus is shared across devices, and turns off when you leave the app."
            ]
        ]
    ; focus_mode.view
    ]
(*$*)

(*$ Choice Card
   Card-style selection where [Field.label] wraps the entire [Field] for a
   clickable card pattern. *)
let choice_card (local_ graph) =
  let share = Switch.component ~id:"switch-share" graph in
  let notifications =
    Switch.component ~id:"switch-notifications" ~default_checked:true graph
  in
  let%arr share and notifications in
  let card ~id ~title ~description (switch : bool Control.t) =
    Field.label
      ~for_:id
      [ Field.root
          ~orientation:Horizontal
          [ Field.content
              [ Field.title [ Node.text title ]
              ; Field.description [ Node.text description ]
              ]
          ; switch.view
          ]
      ]
  in
  Field.group
    ~class_:"w-full max-w-sm"
    [ card
        ~id:"switch-share"
        ~title:"Share across devices"
        ~description:
          "Focus is shared across devices, and turns off when you leave the app."
        share
    ; card
        ~id:"switch-notifications"
        ~title:"Enable notifications"
        ~description:"Receive notifications when focus mode is enabled or disabled."
        notifications
    ]
(*$*)

(*$ Disabled
   [~disabled:true] on the switch prevents interaction; on the [Field] it
   fades the label too. *)
let disabled =
  Field.root
    ~orientation:Horizontal
    ~disabled:true
    ~class_:"w-fit"
    [ Switch.view
        ~id:"switch-disabled-unchecked"
        ~disabled:true
        ~checked:false
        ~on_change:(fun _ -> Effect.Ignore)
        ()
    ; Field.label ~for_:"switch-disabled-unchecked" [ Node.text "Disabled" ]
    ]
(*$*)

(*$ Invalid
   [~invalid:true] on the switch sets [aria-invalid]; on the [Field] it
   turns the label destructive. *)
let invalid (local_ graph) =
  let%arr terms = Switch.component ~id:"switch-terms" ~invalid:true graph in
  Field.root
    ~orientation:Horizontal
    ~class_:"max-w-sm"
    ~invalid:true
    [ Field.content
        [ Field.label ~for_:"switch-terms" [ Node.text "Accept terms and conditions" ]
        ; Field.description
            [ Node.text "You must accept the terms and conditions to continue." ]
        ]
    ; terms.view
    ]
(*$*)

(*$ Size
   [~size:Sm] for a smaller switch. *)
let size (local_ graph) =
  let small = Switch.component ~id:"switch-size-sm" ~size:Sm graph in
  let default = Switch.component ~id:"switch-size-default" ~size:Default graph in
  let%arr small and default in
  Field.group
    ~class_:"w-full max-w-[10rem]"
    [ Field.root
        ~orientation:Horizontal
        [ small.view; Field.label ~for_:"switch-size-sm" [ Node.text "Small" ] ]
    ; Field.root
        ~orientation:Horizontal
        [ default.view; Field.label ~for_:"switch-size-default" [ Node.text "Default" ] ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Switch"
    ~group:Forms
    ~description:
      "A control that allows the user to toggle between checked and not checked."
    ~usage:{|Switch.view ~id:"airplane-mode" ~checked ~on_change:set_checked ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "checked", "bool", "Whether it is on."
          ; "on_change", "bool -> unit Effect.t", "Gets the new value on a click or Space/Enter."
          ; "size", "Switch.Size.t", "[Default] or [Sm]."
          ; "id", "string", "For a label's [for_]: a click on the label toggles it."
          ; "disabled", "bool", "Greys it out and ignores clicks."
          ; "required", "bool", "Sets [aria-required]."
          ; "invalid", "bool", "Sets [aria-invalid], drawing it in the destructive colour."
          ; "class_", "string", "More Tailwind classes, merged last (they win conflicts)."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ; Doc.p
          "[Switch.component ~default_checked graph] keeps the state in Bonsai and \
           returns a [bool Control.t]."
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Description" description
    ; Doc.example ~page "Choice Card" choice_card
    ; Doc.static ~page "Disabled" disabled
    ; Doc.example ~page "Invalid" invalid
    ; Doc.example ~page "Size" size
    ]
;;
