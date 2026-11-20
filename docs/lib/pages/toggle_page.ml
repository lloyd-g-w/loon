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

let page = "toggle"

(*$ Default
   Ghost toggles have no border until pressed, which suits a toolbar; use
   Outline for one on its own. *)
let default (local_ graph) =
  let bold =
    Toggle.component
      ~attrs:[ Attr.create "aria-label" "Bold" ]
      ~default:true
      [ Node.strong [ Node.text "B" ] ]
      graph
  in
  let italic =
    Toggle.component
      ~attrs:[ Attr.create "aria-label" "Italic" ]
      [ Node.em [ Node.text "I" ] ]
      graph
  in
  let%arr bold and italic in
  Node.div
    ~attrs:[ Attr.class_ "docs-toolbar" ]
    [ bold.view; italic.view ]
;;

(*$*)

(*$ Outline, with text *)
let outline (local_ graph) =
  let%arr starred =
    Toggle.component
      ~variant:Outline
      [ Icon.view Bell; Node.text "Watch" ]
      graph
  in
  starred.view
;;

(*$*)

(*$ Toggle group: one at a time
   With Single, a group works like a segmented control. *)
let single (local_ graph) =
  let%arr view =
    Toggle_group.single_component
      ~variant:Outline
      ~required:true
      ~default:"week"
      [ Toggle_group.Item.text ~value:"day" "Day"
      ; Toggle_group.Item.text ~value:"week" "Week"
      ; Toggle_group.Item.text ~value:"month" "Month"
      ; Toggle_group.Item.text ~value:"year" "Year"
      ]
      graph
  in
  view.view
;;

(*$*)

(*$ Toggle group: any number *)
let multiple (local_ graph) =
  let%arr format =
    Toggle_group.multiple_component
      ~default:(String.Set.singleton "bold")
      [ Toggle_group.Item.create
          ~label:"Bold"
          ~value:"bold"
          [ Node.strong [ Node.text "B" ] ]
      ; Toggle_group.Item.create
          ~label:"Italic"
          ~value:"italic"
          [ Node.em [ Node.text "I" ] ]
      ; Toggle_group.Item.create
          ~label:"Underline"
          ~value:"underline"
          [ Node.span
              ~attrs:
                [ Attr.style
                    (Css_gen.create ~field:"text-decoration" ~value:"underline")
                ]
              [ Node.text "U" ]
          ]
      ]
      graph
  in
  Node.div
    ~attrs:[ Attr.class_ "docs-row" ]
    [ format.view
    ; Node.span
        ~attrs:[ Attr.class_ "loon-field-description" ]
        [ Node.text
            (match Set.to_list format.value with
             | [] -> "Plain"
             | styles -> String.concat ~sep:" + " styles)
        ]
    ]
;;

(*$*)

(*$ Sizes *)
let sizes =
  Node.div
    ~attrs:[ Attr.class_ "docs-row" ]
    (List.map Toggle.Size.all ~f:(fun size ->
       Toggle.view
         ~variant:Outline
         ~size
         ~pressed:true
         ~on_change:(fun _ -> Effect.Ignore)
         [ Icon.view Sun; Node.text (Toggle.Size.name size) ]))
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Toggle"
    ~group:Forms
    ~description:
      "A button that stays pressed; and groups of them, one or many at a time."
    ~usage:{|Toggle.view ~pressed ~on_change:set_pressed [ Icon.view Bell ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "pressed", "bool", "Whether it is pressed (aria-pressed)."
          ; "on_change", "bool -> unit Effect.t", "Gets the new value."
          ; "variant", "Toggle.Variant.t", "Ghost (default) or Outline."
          ; "size", "Toggle.Size.t", "Sm, Md (default) or Lg."
          ]
      ; Doc.h2 "Toggle groups"
      ; Doc.p
          "Toggle_group.single has one item pressed at most (required: exactly \
           one) and is announced as a radio group; Toggle_group.multiple any \
           number. Tab reaches the group once; the arrow keys, Home and End \
           move between its items, and Space or Enter presses one. Outline \
           groups join into a single segmented control."
      ]
    [ Doc.example ~page "Default" default
    ; Doc.example ~page "Outline, with text" outline
    ; Doc.example ~page "Toggle group: one at a time" single
    ; Doc.example ~page "Toggle group: any number" multiple
    ; Doc.static ~page "Sizes" sizes
    ]
;;
