open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "checkbox"

(*$ Demo *)
let demo (local_ graph) =
  let terms = Checkbox.component ~id:"terms-checkbox" graph in
  let terms_2 = Checkbox.component ~id:"terms-checkbox-2" ~default_checked:true graph in
  let toggle = Checkbox.component ~id:"toggle-checkbox" ~disabled:true graph in
  let toggle_2 = Checkbox.component ~id:"toggle-checkbox-2" graph in
  let%arr terms and terms_2 and toggle and toggle_2 in
  Field.group
    ~class_:"max-w-sm"
    [ Field.root
        ~orientation:Horizontal
        [ terms.view
        ; Label.view ~for_:"terms-checkbox" [ Node.text "Accept terms and conditions" ]
        ]
    ; Field.root
        ~orientation:Horizontal
        [ terms_2.view
        ; Field.content
            [ Field.label
                ~for_:"terms-checkbox-2"
                [ Node.text "Accept terms and conditions" ]
            ; Field.description
                [ Node.text "By clicking this checkbox, you agree to the terms." ]
            ]
        ]
    ; Field.root
        ~orientation:Horizontal
        ~disabled:true
        [ toggle.view
        ; Field.label ~for_:"toggle-checkbox" [ Node.text "Enable notifications" ]
        ]
    ; Field.label
        [ Field.root
            ~orientation:Horizontal
            [ toggle_2.view
            ; Field.content
                [ Field.title [ Node.text "Enable notifications" ]
                ; Field.description
                    [ Node.text "You can enable or disable notifications at any time." ]
                ]
            ]
        ]
    ]
(*$*)

(*$ Basic
   Pair the checkbox with [Field] and [Field.label] for proper layout and
   labelling. *)
let basic (local_ graph) =
  let%arr terms = Checkbox.component ~id:"terms-checkbox-basic" graph in
  Field.group
    ~class_:"mx-auto w-56"
    [ Field.root
        ~orientation:Horizontal
        [ terms.view
        ; Field.label
            ~for_:"terms-checkbox-basic"
            [ Node.text "Accept terms and conditions" ]
        ]
    ]
(*$*)

(*$ Description
   Use [Field.content] and [Field.description] for helper text. *)
let description (local_ graph) =
  let%arr terms =
    Checkbox.component ~id:"terms-checkbox-desc" ~default_checked:true graph
  in
  Field.group
    ~class_:"mx-auto w-72"
    [ Field.root
        ~orientation:Horizontal
        [ terms.view
        ; Field.content
            [ Field.label
                ~for_:"terms-checkbox-desc"
                [ Node.text "Accept terms and conditions" ]
            ; Field.description
                [ Node.text
                    "By clicking this checkbox, you agree to the terms and conditions."
                ]
            ]
        ]
    ]
(*$*)

(*$ Disabled
   Use [~disabled:true] to prevent interaction, and [~disabled:true] on the
   [Field] for disabled styles. *)
let disabled =
  Field.group
    ~class_:"mx-auto w-56"
    [ Field.root
        ~orientation:Horizontal
        ~disabled:true
        [ Checkbox.view
            ~id:"toggle-checkbox-disabled"
            ~disabled:true
            ~checked:Unchecked
            ~on_change:(fun _ -> Effect.Ignore)
            ()
        ; Field.label ~for_:"toggle-checkbox-disabled" [ Node.text "Enable notifications" ]
        ]
    ]
(*$*)

(*$ Invalid
   [~invalid:true] on the checkbox sets [aria-invalid]; on the [Field] it
   turns the label destructive. *)
let invalid (local_ graph) =
  let%arr terms = Checkbox.component ~id:"terms-checkbox-invalid" ~invalid:true graph in
  Field.group
    ~class_:"mx-auto w-56"
    [ Field.root
        ~orientation:Horizontal
        ~invalid:true
        [ terms.view
        ; Field.label
            ~for_:"terms-checkbox-invalid"
            [ Node.text "Accept terms and conditions" ]
        ]
    ]
(*$*)

(*$ Group
   Use several fields to build a checkbox list. *)
let group (local_ graph) =
  let item ~id ~default_checked label =
    let%arr checkbox = Checkbox.component ~id ~default_checked graph in
    Field.root
      ~orientation:Horizontal
      [ checkbox.view; Field.label ~for_:id ~class_:"font-normal" [ Node.text label ] ]
  in
  let hard_disks = item ~id:"hard-disks-checkbox" ~default_checked:true "Hard disks" in
  let external_disks =
    item ~id:"external-disks-checkbox" ~default_checked:true "External disks"
  in
  let cds = item ~id:"cds-dvds-checkbox" ~default_checked:false "CDs, DVDs, and iPods" in
  let servers =
    item ~id:"connected-servers-checkbox" ~default_checked:false "Connected servers"
  in
  let%arr hard_disks and external_disks and cds and servers in
  Field.set
    [ Field.legend ~variant:Label [ Node.text "Show these items on the desktop:" ]
    ; Field.description [ Node.text "Select the items you want to show on the desktop." ]
    ; Field.group ~class_:"gap-3" [ hard_disks; external_disks; cds; servers ]
    ]
(*$*)

(*$ Select All
   A checkbox showing [Indeterminate] while only some of the others are on:
   checking it turns them all on. *)
let select_all (local_ graph) =
  let items = [ "Hard disks"; "External disks"; "CDs, DVDs, and iPods" ] in
  let checked, set_checked =
    Bonsai.state (String.Set.of_list [ "Hard disks" ]) ~equal:String.Set.equal graph
  in
  let%arr checked and set_checked in
  let all : Checkbox.State.t =
    if Set.length checked = List.length items
    then Checked
    else if Set.is_empty checked
    then Unchecked
    else Indeterminate
  in
  Field.group
    ~class_:"gap-3"
    (Field.root
       ~orientation:Horizontal
       [ Checkbox.view
           ~id:"select-all-checkbox"
           ~class_:
             "data-[state=indeterminate]:border-primary \
              data-[state=indeterminate]:bg-primary \
              data-[state=indeterminate]:text-primary-foreground"
           ~checked:all
           ~on_change:(fun on ->
             set_checked (if on then String.Set.of_list items else String.Set.empty))
           ()
       ; Field.label ~for_:"select-all-checkbox" [ Node.text "Select all" ]
       ]
     :: List.mapi items ~f:(fun i item ->
       let id = sprintf "select-all-item-%d" i in
       Field.root
         ~orientation:Horizontal
         ~class_:"pl-6"
         [ Checkbox.view
             ~id
             ~checked:(Checkbox.State.of_bool (Set.mem checked item))
             ~on_change:(fun on ->
               set_checked (if on then Set.add checked item else Set.remove checked item))
             ()
         ; Field.label ~for_:id ~class_:"font-normal" [ Node.text item ]
         ]))
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Checkbox"
    ~group:Forms
    ~description:
      "A control that allows the user to toggle between checked and not checked."
    ~usage:
      {|Checkbox.view ~id:"terms" ~checked:(Checkbox.State.of_bool terms) ~on_change:set_terms ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "checked"
            , "Checkbox.State.t"
            , "[Checked], [Unchecked] or [Indeterminate] (a dash)." )
          ; ( "on_change"
            , "bool -> unit Effect.t"
            , "Gets the new value: [true] from [Unchecked] and [Indeterminate]." )
          ; "id", "string", "For a label's [for_]: a click on the label toggles it."
          ; "disabled", "bool", "Greys it out and ignores clicks."
          ; "required", "bool", "Sets [aria-required]."
          ; "invalid", "bool", "Sets [aria-invalid], drawing it in the destructive colour."
          ; "class_", "string", "More Tailwind classes, merged last (they win conflicts)."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ; Doc.p
          "[Checkbox.component ~default_checked graph] keeps the state in Bonsai and \
           returns a [bool Control.t]."
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Basic" basic
    ; Doc.example ~page "Description" description
    ; Doc.static ~page "Disabled" disabled
    ; Doc.example ~page "Invalid" invalid
    ; Doc.example ~page "Group" group
    ; Doc.example ~page "Select All" select_all
    ]
;;
