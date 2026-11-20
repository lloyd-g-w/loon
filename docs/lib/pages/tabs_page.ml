open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node

let page = "tabs"

(*$ Segmented *)
let segmented (local_ graph) =
  let name = Input.component ~default:"Ada Lovelace" graph in
  let password = Input.component ~type_:Password graph in
  let field ~id ~label (control : string Control.t) =
    Field.view ~id ~label (fun attrs ->
      Input.view ~attrs ~value:control.value ~on_input:control.set ())
  in
  Tabs.component
    ~attrs:[ Vdom.Attr.style (Css_gen.create ~field:"width" ~value:"min(100%, 24rem)") ]
    (let%arr name and password in
     [ Tabs.Tab.create
         ~id:"account"
         ~label:"Account"
         (Card.view
            ~title:"Account"
            ~description:"Make changes to your account here."
            ~footer:[ Button.view [ Node.text "Save changes" ] ]
            [ field ~id:"tabs-name" ~label:"Name" name ])
     ; Tabs.Tab.create
         ~id:"password"
         ~label:"Password"
         (Card.view
            ~title:"Password"
            ~description:"Change your password here."
            ~footer:[ Button.view [ Node.text "Save password" ] ]
            [ field ~id:"tabs-password" ~label:"New password" password ])
     ; Tabs.Tab.create ~disabled:true ~id:"billing" ~label:"Billing" Node.none
     ])
    graph
(*$*)

(*$ Underline *)
let underline (local_ graph) =
  let panel text =
    Node.p
      ~attrs:[ Vdom.Attr.class_ "loon-field-description" ]
      [ Node.text text ]
  in
  Tabs.component
    ~variant:Underline
    ~attrs:[ Vdom.Attr.style (Css_gen.create ~field:"width" ~value:"min(100%, 24rem)") ]
    (Bonsai.return
       [ Tabs.Tab.create
           ~id:"overview"
           ~label:"Overview"
           (panel "12 open issues, 3 pull requests waiting for review.")
       ; Tabs.Tab.create
           ~id:"activity"
           ~label:"Activity"
           (panel "Ada pushed 4 commits to main an hour ago.")
       ; Tabs.Tab.create
           ~id:"settings"
           ~label:"Settings"
           (panel "Visibility, collaborators and branch rules.")
       ])
    graph
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Tabs"
    ~group:Navigation
    ~description:"Layered panels of content, shown one at a time."
    ~usage:
      {|Tabs.component
  (Bonsai.return
     [ Tabs.Tab.create ~id:"account" ~label:"Account" account
     ; Tabs.Tab.create ~id:"password" ~label:"Password" password
     ])
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "tabs", "Tabs.Tab.t list Bonsai.t", "Each with an id, a label, its panel and whether it is disabled."
          ; "variant", "Tabs.Variant.t", "Segmented (default) or Underline."
          ; "default", "string", "The id of the tab shown first (else the first)."
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.p
          "Tab reaches the selected trigger, then its panel. The arrow keys, Home \
           and End move between the triggers, skipping disabled ones, and show \
           the tab they reach. Tabs.view is the controlled form, given the active \
           id and on_change."
      ]
    [ Doc.example ~page "Segmented" segmented; Doc.example ~page "Underline" underline ]
;;
