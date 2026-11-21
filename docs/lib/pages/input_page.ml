open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "input"

(*$ Demo *)
let demo =
  Field.root
    [ Field.label ~for_:"input-demo-api-key" [ Node.text "API Key" ]
    ; Input.view ~id:"input-demo-api-key" ~type_:Password ~placeholder:"sk-..." ()
    ; Field.description [ Node.text "Your API key is encrypted and stored securely." ]
    ]
(*$*)

(*$ Basic *)
let basic = Input.view ~placeholder:"Enter text" ()
(*$*)

(*$ Field
   Use [Field], [Field.label] and [Field.description] to create an input
   with a label and description. *)
let field =
  Field.root
    [ Field.label ~for_:"input-field-username" [ Node.text "Username" ]
    ; Input.view
        ~id:"input-field-username"
        ~type_:Text
        ~placeholder:"Enter your username"
        ()
    ; Field.description [ Node.text "Choose a unique username for your account." ]
    ]
(*$*)

(*$ Field Group
   Use [Field.group] to show multiple [Field] blocks and to build forms. *)
let field_group =
  Field.group
    [ Field.root
        [ Field.label ~for_:"fieldgroup-name" [ Node.text "Name" ]
        ; Input.view ~id:"fieldgroup-name" ~placeholder:"Jordan Lee" ()
        ]
    ; Field.root
        [ Field.label ~for_:"fieldgroup-email" [ Node.text "Email" ]
        ; Input.view
            ~id:"fieldgroup-email"
            ~type_:Email
            ~placeholder:"name@example.com"
            ()
        ; Field.description [ Node.text "We'll send updates to this address." ]
        ]
    ; Field.root
        ~orientation:Horizontal
        [ Button.view ~type_:`Reset ~variant:Outline [ Node.text "Reset" ]
        ; Button.view ~type_:`Submit [ Node.text "Submit" ]
        ]
    ]
(*$*)

(*$ Disabled
   Use [~disabled:true] on the input; [~disabled:true] on the [Field] styles
   its label and description too. *)
let disabled =
  Field.root
    ~disabled:true
    [ Field.label ~for_:"input-demo-disabled" [ Node.text "Email" ]
    ; Input.view
        ~id:"input-demo-disabled"
        ~type_:Email
        ~placeholder:"Email"
        ~disabled:true
        ()
    ; Field.description [ Node.text "This field is currently disabled." ]
    ]
(*$*)

(*$ Invalid
   [~invalid:true] on the input sets [aria-invalid]; on the [Field] it turns
   the label destructive too. *)
let invalid =
  Field.root
    ~invalid:true
    [ Field.label ~for_:"input-invalid" [ Node.text "Invalid Input" ]
    ; Input.view ~id:"input-invalid" ~placeholder:"Error" ~invalid:true ()
    ; Field.description [ Node.text "This field contains validation errors." ]
    ]
(*$*)

(*$ File *)
let file =
  Field.root
    [ Field.label ~for_:"picture" [ Node.text "Picture" ]
    ; Input.view ~id:"picture" ~type_:File ()
    ; Field.description [ Node.text "Select a picture to upload." ]
    ]
(*$*)

(*$ Inline
   A horizontal [Field] puts the input and a button side by side. *)
let inline =
  Field.root
    ~orientation:Horizontal
    [ Input.view ~type_:Search ~placeholder:"Search..." ()
    ; Button.view [ Node.text "Search" ]
    ]
(*$*)

(*$ Grid *)
let grid =
  Field.group
    ~class_:"grid max-w-sm grid-cols-2"
    [ Field.root
        [ Field.label ~for_:"first-name" [ Node.text "First Name" ]
        ; Input.view ~id:"first-name" ~placeholder:"Jordan" ()
        ]
    ; Field.root
        [ Field.label ~for_:"last-name" [ Node.text "Last Name" ]
        ; Input.view ~id:"last-name" ~placeholder:"Lee" ()
        ]
    ]
(*$*)

(*$ Required *)
let required =
  Field.root
    [ Field.label
        ~for_:"input-required"
        [ Node.text "Required Field "
        ; Node.span ~attrs:[ Attr.class_ "text-destructive" ] [ Node.text "*" ]
        ]
    ; Input.view
        ~id:"input-required"
        ~placeholder:"This field is required"
        ~required:true
        ()
    ; Field.description [ Node.text "This field must be filled out." ]
    ]
(*$*)

(*$ Badge *)
let badge =
  Field.root
    [ Field.label
        ~for_:"input-badge"
        [ Node.text "Webhook URL "
        ; Badge.view ~variant:Secondary ~class_:"ml-auto" [ Node.text "Beta" ]
        ]
    ; Input.view
        ~id:"input-badge"
        ~type_:Url
        ~placeholder:"https://api.example.com/webhook"
        ()
    ]
(*$*)

(*$ Input Group
   [Input_group] adds icons, text or buttons inside the input. *)
let input_group =
  Field.root
    [ Field.label ~for_:"input-group-url" [ Node.text "Website URL" ]
    ; Input_group.root
        [ Input_group.input ~id:"input-group-url" ~placeholder:"example.com" ()
        ; Input_group.addon [ Input_group.text [ Node.text "https://" ] ]
        ; Input_group.addon ~align:Inline_end [ Icon.view Info ]
        ]
    ]
(*$*)

(*$ Button Group
   [Button_group] joins an input and buttons. *)
let button_group =
  Field.root
    [ Field.label ~for_:"input-button-group" [ Node.text "Search" ]
    ; Button_group.root
        [ Input.view ~id:"input-button-group" ~placeholder:"Type to search..." ()
        ; Button.view ~variant:Outline [ Node.text "Search" ]
        ]
    ]
(*$*)

(*$ Form
   A form of several inputs, with [Native_select] for the country. *)
let form =
  Node.form
    ~attrs:[ Attr.class_ "w-full max-w-sm"; Attr.on_submit Dom_util.prevent_default ]
    [ Field.group
        [ Field.root
            [ Field.label ~for_:"form-name" [ Node.text "Name" ]
            ; Input.view
                ~id:"form-name"
                ~type_:Text
                ~placeholder:"Evil Rabbit"
                ~required:true
                ()
            ]
        ; Field.root
            [ Field.label ~for_:"form-email" [ Node.text "Email" ]
            ; Input.view ~id:"form-email" ~type_:Email ~placeholder:"john@example.com" ()
            ; Field.description [ Node.text "We'll never share your email with anyone." ]
            ]
        ; Node.div
            ~attrs:[ Attr.class_ "grid grid-cols-2 gap-4" ]
            [ Field.root
                [ Field.label ~for_:"form-phone" [ Node.text "Phone" ]
                ; Input.view ~id:"form-phone" ~type_:Tel ~placeholder:"+1 (555) 123-4567" ()
                ]
            ; Field.root
                [ Field.label ~for_:"form-country" [ Node.text "Country" ]
                ; Native_select.view
                    ~id:"form-country"
                    [ Native_select.option ~value:"us" [ Node.text "United States" ]
                    ; Native_select.option ~value:"uk" [ Node.text "United Kingdom" ]
                    ; Native_select.option ~value:"ca" [ Node.text "Canada" ]
                    ]
                ]
            ]
        ; Field.root
            [ Field.label ~for_:"form-address" [ Node.text "Address" ]
            ; Input.view ~id:"form-address" ~type_:Text ~placeholder:"123 Main St" ()
            ]
        ; Field.root
            ~orientation:Horizontal
            [ Button.view ~type_:`Button ~variant:Outline [ Node.text "Cancel" ]
            ; Button.view ~type_:`Submit [ Node.text "Submit" ]
            ]
        ]
    ]
(*$*)

(*$ Controlled
   [Input.component] keeps the text in Bonsai state; its [value] follows
   each keystroke. *)
let controlled (local_ graph) =
  let name = Input.component ~id:"input-controlled" ~placeholder:"Your name" graph in
  let%arr name in
  Field.root
    [ Field.label ~for_:"input-controlled" [ Node.text "Name" ]
    ; name.view
    ; Field.description
        [ Node.text
            (if String.is_empty name.value then "Hello!" else "Hello, " ^ name.value ^ "!")
        ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Input"
    ~group:Forms
    ~description:
      "A text input component for forms and user data entry with built-in styling and \
       accessibility features."
    ~usage:{|Input.view ~type_:Email ~placeholder:"Email" ~value ~on_input:set ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "type_"
            , "Input.Type.t"
            , "Text (default), Email, Password, Search, Number, Url, Tel, File, Date or \
               Time." )
          ; ( "value"
            , "string"
            , "Makes it controlled: the text shown. Without it the browser keeps what is \
               typed." )
          ; "on_input", "string -> unit Effect.t", "Gets the text after each edit."
          ; "placeholder", "string", "Shown while it is empty."
          ; "id", "string", "For a label's [for_]."
          ; "name", "string", "The form field's name."
          ; "disabled", "bool", "Greys it out."
          ; "required", "bool", "Must be filled in."
          ; "invalid", "bool", "Sets [aria-invalid], drawing it in the destructive colour."
          ; "class_", "string", "More Tailwind classes, merged last (they win conflicts)."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes (autocomplete, inputmode...)."
          ]
      ; Doc.p
          "[Input.component ~default_value graph] keeps the text in Bonsai state and \
           returns a [Control.t]: its [value], a [set] effect and its [view]."
      ]
    [ Doc.static ~page "Demo" demo
    ; Doc.static ~page "Basic" basic
    ; Doc.static ~page "Field" field
    ; Doc.static ~page "Field Group" field_group
    ; Doc.static ~page "Disabled" disabled
    ; Doc.static ~page "Invalid" invalid
    ; Doc.static ~page "File" file
    ; Doc.static ~page "Inline" inline
    ; Doc.static ~page "Grid" grid
    ; Doc.static ~page "Required" required
    ; Doc.static ~page "Badge" badge
    ; Doc.static ~page "Input Group" input_group
    ; Doc.static ~page "Button Group" button_group
    ; Doc.static ~page "Form" form
    ; Doc.example ~page "Controlled" controlled
    ]
;;
