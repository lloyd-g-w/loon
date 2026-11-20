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

let page = "switch"

(*$ Default *)
let default (local_ graph) =
  let%arr airplane = Switch.component ~label:"Airplane mode" graph in
  airplane.view
(*$*)

(*$ Settings list *)
let settings (local_ graph) =
  let setting ~id ~label ~description ~default (local_ graph) =
    let%arr control = Switch.component ~default graph in
    Node.div
      ~attrs:
        [ Attr.style
            (Css_gen.concat
               [ Css_gen.create ~field:"display" ~value:"flex"
               ; Css_gen.create ~field:"align-items" ~value:"center"
               ; Css_gen.create ~field:"justify-content" ~value:"space-between"
               ; Css_gen.create ~field:"gap" ~value:"1rem"
               ; Css_gen.create ~field:"padding" ~value:"0.875rem 1rem"
               ])
        ]
      [ Node.div
          ~attrs:[ Attr.class_ "loon-field-text" ]
          [ Label.text ~for_:id label
          ; Node.p ~attrs:[ Attr.class_ "loon-field-description" ] [ Node.text description ]
          ]
      ; Switch.view
          ~attrs:[ Attr.id id ]
          ~checked:control.value
          ~on_change:control.set
          ()
      ]
  in
  let a =
    setting
      ~id:"switch-security"
      ~label:"Security emails"
      ~description:"Sign-ins from new devices."
      ~default:true
      graph
  in
  let b =
    setting
      ~id:"switch-marketing"
      ~label:"Marketing emails"
      ~description:"News, offers and the odd survey."
      ~default:false
      graph
  in
  let%arr a and b in
  Card.container
    ~attrs:[ Attr.style (Css_gen.create ~field:"width" ~value:"min(100%, 26rem)") ]
    [ a; Node.hr ~attrs:[ Attr.style (Css_gen.create ~field:"margin" ~value:"0") ] (); b ]
(*$*)

(*$ Sizes and disabled *)
let sizes =
  Node.div
    ~attrs:[ Attr.class_ "docs-row" ]
    [ Switch.view ~size:Sm ~label:"Small" ~checked:true ~on_change:(fun _ -> Effect.Ignore) ()
    ; Switch.view ~label:"Medium" ~checked:true ~on_change:(fun _ -> Effect.Ignore) ()
    ; Switch.view
        ~disabled:true
        ~label:"Disabled"
        ~checked:false
        ~on_change:(fun _ -> Effect.Ignore)
        ()
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Switch"
    ~group:Forms
    ~description:"Turns a setting on or off, taking effect at once."
    ~usage:{|Switch.view ~label:"Wi-Fi" ~checked:wifi ~on_change:set_wifi ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "checked", "bool", "Whether it is on."
          ; "on_change", "bool -> unit Effect.t", "Gets the new value."
          ; "size", "Switch.Size.t", "Sm or Md (default)."
          ; "label", "string", "Text beside it, which toggles it too."
          ; "disabled", "bool", "Greys it out and ignores clicks."
          ]
      ; Doc.p
          "Use a switch for a setting that applies immediately; in a form that is submitted, use a checkbox."
      ]
    [ Doc.example ~page "Default" default
    ; Doc.example ~page "Settings list" settings
    ; Doc.static ~page "Sizes and disabled" sizes
    ]
;;
