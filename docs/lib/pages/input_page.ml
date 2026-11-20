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

let page = "input"

(*$ Default *)
let default (local_ graph) =
  let%arr email =
    Input.component ~type_:Email ~placeholder:"you@example.com" graph
  in
  narrow [ email.view ]
;;

(*$*)

(*$ With a label
   Field gives the input its label, a description and the ids that tie them
   together for screen readers. *)
let with_label (local_ graph) =
  let%arr name = Input.component ~placeholder:"Ada Lovelace" graph in
  narrow
    [ Field.view
        ~id:"input-name"
        ~label:"Name"
        ~description:"As it should appear on your profile."
        (fun attrs -> Input.view ~attrs ~value:name.value ~on_input:name.set ())
    ]
;;

(*$*)

(*$ Icons and addons *)
let addons (local_ graph) =
  let search =
    Input.component
      ~type_:Search
      ~leading:Search
      ~trailing:(Node.kbd [ Node.text "⌘K" ])
      ~placeholder:"Search documentation…"
      graph
  in
  let site =
    Input.component
      ~leading:External_link
      ~trailing:(Node.span [ Node.text ".loon.dev" ])
      ~placeholder:"your-site"
      graph
  in
  let%arr search
  and site in
  narrow [ search.view; site.view ]
;;

(*$*)

(*$ Password with a show button *)
let password (local_ graph) =
  let shown, set_shown = Bonsai.state false graph in
  let value, set_value = Bonsai.state "hunter2" graph in
  let%arr shown
  and set_shown
  and value
  and set_value in
  narrow
    [ Input.view
        ~attrs:[ Attr.create "aria-label" "Password" ]
        ~type_:(if shown then Text else Password)
        ~leading:Settings
        ~trailing:
          (Button.view
             ~variant:Ghost
             ~size:Sm
             ~on_click:(set_shown (not shown))
             [ Node.text (if shown then "Hide" else "Show") ])
        ~value
        ~on_input:set_value
        ()
    ]
;;

(*$*)

(*$ Invalid and disabled *)
let states =
  narrow
    [ Input.view
        ~invalid:true
        ~value:"not-an-email"
        ~on_input:(fun _ -> Effect.Ignore)
        ()
    ; Input.view
        ~disabled:true
        ~placeholder:"Disabled"
        ~value:""
        ~on_input:(fun _ -> Effect.Ignore)
        ()
    ]
;;

(*$*)

(*$ Textarea *)
let textarea (local_ graph) =
  let%arr bio =
    Textarea.component ~placeholder:"Tell us a little about yourself" graph
  in
  narrow
    [ bio.view
    ; Node.p
        ~attrs:[ Attr.class_ "loon-field-description" ]
        [ Node.textf "%d / 280 characters" (String.length bio.value) ]
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Input"
    ~group:Forms
    ~description:
      "A text field, with optional icons and addons; and Textarea, its \
       multi-line sibling."
    ~usage:{|Input.view ~type_:Email ~value ~on_input:set_value ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "type_"
            , "Input.Type.t"
            , "Text (default), Email, Password, Search, Number, Url or Tel." )
          ; "value", "string", "The text shown."
          ; "on_input", "string -> unit Effect.t", "Gets every edit."
          ; "on_enter", "unit Effect.t", "Runs when Enter is pressed."
          ; "leading", "Icon.t", "An icon inside the field, before the text."
          ; ( "trailing"
            , "Vdom.Node.t"
            , "An addon inside the field, after the text: a hint, a unit, a \
               small button." )
          ; ( "invalid"
            , "bool"
            , "Sets aria-invalid and draws it in the danger colour (Field does \
               this for you)." )
          ; "disabled", "bool", "Greys it out."
          ; ( "attrs"
            , "Vdom.Attr.t list"
            , "Extra attributes for the <input>: id, name, autocomplete…" )
          ]
      ; Doc.p
          "[Input.component] keeps the text in Bonsai state and returns a \
           [Control.t]: its value, a set effect and its view."
      ]
    [ Doc.example ~page "Default" default
    ; Doc.example ~page "With a label" with_label
    ; Doc.example ~page "Icons and addons" addons
    ; Doc.example ~page "Password with a show button" password
    ; Doc.static ~page "Invalid and disabled" states
    ; Doc.example ~page "Textarea" textarea
    ]
;;
