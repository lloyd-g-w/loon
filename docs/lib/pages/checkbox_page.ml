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

let page = "checkbox"

(*$ Default *)
let default (local_ graph) =
  let%arr terms =
    Checkbox.component ~label:"Accept terms and conditions" graph
  in
  terms.view
;;

(*$*)

(*$ With a description *)
let with_description (local_ graph) =
  let%arr marketing = Checkbox.component ~default:true graph in
  Field.view
    ~orientation:Horizontal
    ~id:"checkbox-marketing"
    ~label:"Product updates"
    ~description:
      "A short email when we ship something new. No more than once a month."
    (fun attrs ->
       Checkbox.view
         ~attrs
         ~state:(Checkbox.State.of_bool marketing.value)
         ~on_change:marketing.set
         ())
;;

(*$*)

(*$ Select all
   The parent checkbox is indeterminate while only some are checked. *)
let select_all (local_ graph) =
  let all = [ "Mentions"; "Direct messages"; "Replies"; "Reactions" ] in
  let chosen, set_chosen =
    Bonsai.state (String.Set.of_list [ "Mentions"; "Replies" ]) graph
  in
  let%arr chosen
  and set_chosen in
  let state : Checkbox.State.t =
    if Set.length chosen = List.length all
    then Checked
    else if Set.is_empty chosen
    then Unchecked
    else Indeterminate
  in
  Node.div
    ~attrs:[ Attr.class_ "docs-stack" ]
    [ Checkbox.view
        ~label:"All notifications"
        ~state
        ~on_change:(fun all_on ->
          set_chosen
            (if all_on then String.Set.of_list all else String.Set.empty))
        ()
    ; Node.div
        ~attrs:
          [ Attr.class_ "docs-stack"
          ; Attr.style (Css_gen.create ~field:"padding-left" ~value:"1.625rem")
          ]
        (List.map all ~f:(fun item ->
           Checkbox.view
             ~label:item
             ~state:(Checkbox.State.of_bool (Set.mem chosen item))
             ~on_change:(fun on ->
               set_chosen
                 (if on then Set.add chosen item else Set.remove chosen item))
             ()))
    ]
;;

(*$*)

(*$ Disabled *)
let disabled =
  Node.div
    ~attrs:[ Attr.class_ "docs-row" ]
    [ Checkbox.view
        ~disabled:true
        ~label:"Checked"
        ~state:Checked
        ~on_change:(fun _ -> Effect.Ignore)
        ()
    ; Checkbox.view
        ~disabled:true
        ~label:"Unchecked"
        ~state:Unchecked
        ~on_change:(fun _ -> Effect.Ignore)
        ()
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Checkbox"
    ~group:Forms
    ~description:
      "Turns an option on or off; or shows that some of a group are on."
    ~usage:
      {|Checkbox.view ~label:"Remember me" ~state:(Checkbox.State.of_bool remember) ~on_change:set_remember ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "state", "Checkbox.State.t", "Checked, Unchecked or Indeterminate."
          ; ( "on_change"
            , "bool -> unit Effect.t"
            , "Gets the new value: true from Unchecked and Indeterminate." )
          ; "label", "string", "Text beside the box, which toggles it too."
          ; "disabled", "bool", "Greys it out and ignores clicks."
          ]
      ]
    [ Doc.example ~page "Default" default
    ; Doc.example ~page "With a description" with_description
    ; Doc.example ~page "Select all" select_all
    ; Doc.static ~page "Disabled" disabled
    ]
;;
