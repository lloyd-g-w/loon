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

let page = "radio_group"

(*$ Default *)
let default (local_ graph) =
  let%arr density =
    Radio_group.component
      ~default:"comfortable"
      [ Radio_group.Item.create ~value:"default" "Default"
      ; Radio_group.Item.create ~value:"comfortable" "Comfortable"
      ; Radio_group.Item.create ~value:"compact" "Compact"
      ]
      graph
  in
  density.view
;;

(*$*)

(*$ With descriptions *)
let plans (local_ graph) =
  let%arr plan =
    Radio_group.component
      ~default:"pro"
      [ Radio_group.Item.create
          ~value:"hobby"
          ~description:"For side projects. Free forever."
          "Hobby"
      ; Radio_group.Item.create
          ~value:"pro"
          ~description:"Unlimited projects and priority support. $12/month."
          "Pro"
      ; Radio_group.Item.create
          ~value:"enterprise"
          ~description:"SSO, audit logs and a person to call."
          ~disabled:true
          "Enterprise (contact us)"
      ]
      graph
  in
  narrow
    [ Field.set ~legend:"Plan" [ plan.view ]
    ; Node.p
        ~attrs:[ Attr.class_ "loon-field-description" ]
        [ Node.textf "Chosen: %s" (Option.value plan.value ~default:"nothing") ]
    ]
;;

(*$*)

(*$ Horizontal *)
let horizontal (local_ graph) =
  let%arr size =
    Radio_group.component
      ~orientation:Horizontal
      ~default:"m"
      (List.map [ "XS"; "S"; "M"; "L"; "XL" ] ~f:(fun s ->
         Radio_group.Item.create ~value:(String.lowercase s) s))
      graph
  in
  size.view
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Radio group"
    ~group:Forms
    ~description:"Choose one of a few options, all in view."
    ~usage:
      {|Radio_group.view ~name:"plan" ~value ~on_change:set_value
  [ Radio_group.Item.create ~value:"hobby" "Hobby"
  ; Radio_group.Item.create ~value:"pro" "Pro"
  ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "value"
            , "string option"
            , "The chosen item's value; None before one is chosen." )
          ; ( "on_change"
            , "string -> unit Effect.t"
            , "Gets the newly chosen value." )
          ; ( "name"
            , "string"
            , "Scopes the elements' ids: one per group on a page (the \
               component makes its own)." )
          ; ( "orientation"
            , "Roving.Orientation.t"
            , "Vertical (default) or Horizontal." )
          ; ( "disabled"
            , "bool"
            , "Disables every item; Item.create ~disabled disables one." )
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.p
          "Tab moves to the chosen option. The arrow keys choose the next or \
           previous option, wrapping and skipping disabled ones; Home and End \
           the first and last."
      ]
    [ Doc.example ~page "Default" default
    ; Doc.example ~page "With descriptions" plans
    ; Doc.example ~page "Horizontal" horizontal
    ]
;;
