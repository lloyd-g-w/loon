open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "radio_group"

(*$ Demo *)
let demo (local_ graph) =
  let%arr group =
    Radio_group.component
      ~class_:"w-fit"
      ~default_value:"comfortable"
      (return (fun group ->
         List.map
           [ "default", "r1", "Default"
           ; "comfortable", "r2", "Comfortable"
           ; "compact", "r3", "Compact"
           ]
           ~f:(fun (value, id, label) ->
             Node.div
               ~attrs:[ Attr.class_ "flex items-center gap-3" ]
               [ Radio_group.item group ~value ~id
               ; Label.view ~for_:id [ Node.text label ]
               ])))
      graph
  in
  group.view
(*$*)

(*$ Description
   Radio items with a description, laid out with [Field]. *)
let description (local_ graph) =
  let%arr group =
    Radio_group.component
      ~class_:"w-fit"
      ~default_value:"comfortable"
      (return (fun group ->
         List.map
           [ "default", "desc-r1", "Default", "Standard spacing for most use cases."
           ; "comfortable", "desc-r2", "Comfortable", "More space between elements."
           ; "compact", "desc-r3", "Compact", "Minimal spacing for dense layouts."
           ]
           ~f:(fun (value, id, label, description) ->
             Field.root
               ~orientation:Horizontal
               [ Radio_group.item group ~value ~id
               ; Field.content
                   [ Field.label ~for_:id [ Node.text label ]
                   ; Field.description [ Node.text description ]
                   ]
               ])))
      graph
  in
  group.view
(*$*)

(*$ Choice Card
   [Field.label] wraps the whole [Field] for a clickable card. *)
let choice_card (local_ graph) =
  let%arr group =
    Radio_group.component
      ~class_:"max-w-sm"
      ~default_value:"plus"
      (return (fun group ->
         List.map
           [ "plus", "plus-plan", "Plus", "For individuals and small teams."
           ; "pro", "pro-plan", "Pro", "For growing businesses."
           ; "enterprise", "enterprise-plan", "Enterprise", "For large teams and enterprises."
           ]
           ~f:(fun (value, id, title, description) ->
             Field.label
               ~for_:id
               [ Field.root
                   ~orientation:Horizontal
                   [ Field.content
                       [ Field.title [ Node.text title ]
                       ; Field.description [ Node.text description ]
                       ]
                   ; Radio_group.item group ~value ~id
                   ]
               ])))
      graph
  in
  group.view
(*$*)

(*$ Fieldset
   [Field.set] and [Field.legend] group the radio items with a label and a
   description. *)
let fieldset (local_ graph) =
  let%arr group =
    Radio_group.component
      ~default_value:"monthly"
      (return (fun group ->
         List.map
           [ "monthly", "plan-monthly", "Monthly ($9.99/month)"
           ; "yearly", "plan-yearly", "Yearly ($99.99/year)"
           ; "lifetime", "plan-lifetime", "Lifetime ($299.99)"
           ]
           ~f:(fun (value, id, label) ->
             Field.root
               ~orientation:Horizontal
               [ Radio_group.item group ~value ~id
               ; Field.label ~for_:id ~class_:"font-normal" [ Node.text label ]
               ])))
      graph
  in
  Field.set
    ~class_:"w-full max-w-xs"
    [ Field.legend ~variant:Label [ Node.text "Subscription Plan" ]
    ; Field.description
        [ Node.text "Yearly and lifetime plans offer significant savings." ]
    ; group.view
    ]
(*$*)

(*$ Disabled
   [~disabled:true] on an item skips it (and on the group, every item). *)
let disabled (local_ graph) =
  let%arr group =
    Radio_group.component
      ~class_:"w-fit"
      ~default_value:"option2"
      (return (fun group ->
         [ Field.root
             ~orientation:Horizontal
             ~disabled:true
             [ Radio_group.item group ~value:"option1" ~id:"disabled-1" ~disabled:true
             ; Field.label ~for_:"disabled-1" ~class_:"font-normal" [ Node.text "Disabled" ]
             ]
         ; Field.root
             ~orientation:Horizontal
             [ Radio_group.item group ~value:"option2" ~id:"disabled-2"
             ; Field.label ~for_:"disabled-2" ~class_:"font-normal" [ Node.text "Option 2" ]
             ]
         ; Field.root
             ~orientation:Horizontal
             [ Radio_group.item group ~value:"option3" ~id:"disabled-3"
             ; Field.label ~for_:"disabled-3" ~class_:"font-normal" [ Node.text "Option 3" ]
             ]
         ]))
      graph
  in
  group.view
(*$*)

(*$ Invalid
   [~invalid:true] on the items sets [aria-invalid]; on the fields it turns
   the labels destructive. *)
let invalid (local_ graph) =
  let%arr group =
    Radio_group.component
      ~default_value:"email"
      (return (fun group ->
         List.map
           [ "email", "invalid-email", "Email only"
           ; "sms", "invalid-sms", "SMS only"
           ; "both", "invalid-both", "Both Email & SMS"
           ]
           ~f:(fun (value, id, label) ->
             Field.root
               ~orientation:Horizontal
               ~invalid:true
               [ Radio_group.item group ~value ~id ~invalid:true
               ; Field.label ~for_:id ~class_:"font-normal" [ Node.text label ]
               ])))
      graph
  in
  Field.set
    ~class_:"w-full max-w-xs"
    [ Field.legend ~variant:Label [ Node.text "Notification Preferences" ]
    ; Field.description [ Node.text "Choose how you want to receive notifications." ]
    ; group.view
    ]
(*$*)

(*$ Controlled
   [Radio_group.view] takes the value and [on_change]: here from a state
   shown below the group. *)
let controlled (local_ graph) =
  let value, set_value = Bonsai.state (Some "comfortable") graph in
  let%arr value and set_value in
  Node.div
    ~attrs:[ Attr.class_ "grid gap-4" ]
    [ Radio_group.view
        ~class_:"w-fit"
        ~value
        ~on_change:(fun v -> set_value (Some v))
        (fun group ->
          List.map
            [ "default", "ctl-r1", "Default"
            ; "comfortable", "ctl-r2", "Comfortable"
            ; "compact", "ctl-r3", "Compact"
            ]
            ~f:(fun (value, id, label) ->
              Node.div
                ~attrs:[ Attr.class_ "flex items-center gap-3" ]
                [ Radio_group.item group ~value ~id
                ; Label.view ~for_:id [ Node.text label ]
                ]))
    ; Node.p
        ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ]
        [ Node.text ("Density: " ^ Option.value value ~default:"none") ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Radio Group"
    ~description:
      "A set of checkable buttons\u{2014}known as radio buttons\u{2014}where no more than \
       one of the buttons can be checked at a time."
    ~usage:
      {|Radio_group.view ~value ~on_change:set_value (fun group ->
  [ Radio_group.item group ~value:"default" ~id:"r1"
  ; Label.view ~for_:"r1" [ Node.text "Default" ]
  ])|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "value", "string option", "The checked item's value."
          ; ( "on_change"
            , "string -> unit Effect.t"
            , "Gets an item's value when it is clicked or reached by the arrow keys." )
          ; ( "orientation"
            , "Roving.Orientation.t"
            , "Sets [aria-orientation]; the arrow keys work either way." )
          ; "disabled", "bool", "Disables every item."
          ; "required", "bool", "Sets [aria-required]."
          ; "class_", "string", "More Tailwind classes, merged last (they win conflicts)."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ; Doc.p
          "[Radio_group.item group ~value] is one radio button, with [?id] (for a label), \
           [?disabled] and [?invalid]. [Radio_group.component ~default_value children \
           graph] keeps the value in Bonsai and returns a [string option Control.t]."
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Description" description
    ; Doc.example ~page "Choice Card" choice_card
    ; Doc.example ~page "Fieldset" fieldset
    ; Doc.example ~page "Disabled" disabled
    ; Doc.example ~page "Invalid" invalid
    ; Doc.example ~page "Controlled" controlled
    ]
;;
