open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "toggle_group"

(*$ Demo *)
let demo (local_ graph) =
  let%arr group =
    Toggle_group.multiple_component
      ~variant:Outline
      (return (fun group ->
         [ Toggle_group.item
             group
             ~value:"bold"
             ~attrs:[ Attr.create "aria-label" "Toggle bold" ]
             [ Icon.view ~class_:"h-4 w-4" Letter_b ]
         ; Toggle_group.item
             group
             ~value:"italic"
             ~attrs:[ Attr.create "aria-label" "Toggle italic" ]
             [ Icon.view ~class_:"h-4 w-4" Italic ]
         ; Toggle_group.item
             group
             ~value:"strikethrough"
             ~attrs:[ Attr.create "aria-label" "Toggle strikethrough" ]
             [ Icon.view ~class_:"h-4 w-4" Underline ]
         ]))
      graph
  in
  group.view
(*$*)

(*$ Outline *)
let outline (local_ graph) =
  let%arr group =
    Toggle_group.multiple_component
      ~variant:Outline
      (return (fun group ->
         [ Toggle_group.item
             group
             ~value:"bold"
             ~attrs:[ Attr.create "aria-label" "Toggle bold" ]
             [ Icon.view ~class_:"h-4 w-4" Letter_b ]
         ; Toggle_group.item
             group
             ~value:"italic"
             ~attrs:[ Attr.create "aria-label" "Toggle italic" ]
             [ Icon.view ~class_:"h-4 w-4" Italic ]
         ; Toggle_group.item
             group
             ~value:"strikethrough"
             ~attrs:[ Attr.create "aria-label" "Toggle strikethrough" ]
             [ Icon.view ~class_:"h-4 w-4" Underline ]
         ]))
      graph
  in
  group.view
(*$*)

(*$ Single
   [single_component]: one item pressed at most; pressing it again releases
   it. *)
let single (local_ graph) =
  let%arr group =
    Toggle_group.single_component
      (return (fun group ->
         [ Toggle_group.item
             group
             ~value:"bold"
             ~attrs:[ Attr.create "aria-label" "Toggle bold" ]
             [ Icon.view ~class_:"h-4 w-4" Letter_b ]
         ; Toggle_group.item
             group
             ~value:"italic"
             ~attrs:[ Attr.create "aria-label" "Toggle italic" ]
             [ Icon.view ~class_:"h-4 w-4" Italic ]
         ; Toggle_group.item
             group
             ~value:"strikethrough"
             ~attrs:[ Attr.create "aria-label" "Toggle strikethrough" ]
             [ Icon.view ~class_:"h-4 w-4" Underline ]
         ]))
      graph
  in
  group.view
(*$*)

(*$ Small *)
let small (local_ graph) =
  let%arr group =
    Toggle_group.single_component
      ~size:Sm
      (return (fun group ->
         [ Toggle_group.item
             group
             ~value:"bold"
             ~attrs:[ Attr.create "aria-label" "Toggle bold" ]
             [ Icon.view ~class_:"h-4 w-4" Letter_b ]
         ; Toggle_group.item
             group
             ~value:"italic"
             ~attrs:[ Attr.create "aria-label" "Toggle italic" ]
             [ Icon.view ~class_:"h-4 w-4" Italic ]
         ; Toggle_group.item
             group
             ~value:"strikethrough"
             ~attrs:[ Attr.create "aria-label" "Toggle strikethrough" ]
             [ Icon.view ~class_:"h-4 w-4" Underline ]
         ]))
      graph
  in
  group.view
(*$*)

(*$ Large *)
let large (local_ graph) =
  let%arr group =
    Toggle_group.multiple_component
      ~size:Lg
      (return (fun group ->
         [ Toggle_group.item
             group
             ~value:"bold"
             ~attrs:[ Attr.create "aria-label" "Toggle bold" ]
             [ Icon.view ~class_:"h-4 w-4" Letter_b ]
         ; Toggle_group.item
             group
             ~value:"italic"
             ~attrs:[ Attr.create "aria-label" "Toggle italic" ]
             [ Icon.view ~class_:"h-4 w-4" Italic ]
         ; Toggle_group.item
             group
             ~value:"strikethrough"
             ~attrs:[ Attr.create "aria-label" "Toggle strikethrough" ]
             [ Icon.view ~class_:"h-4 w-4" Underline ]
         ]))
      graph
  in
  group.view
(*$*)

(*$ Disabled *)
let disabled (local_ graph) =
  let%arr group =
    Toggle_group.multiple_component
      ~disabled:true
      (return (fun group ->
         [ Toggle_group.item
             group
             ~value:"bold"
             ~attrs:[ Attr.create "aria-label" "Toggle bold" ]
             [ Icon.view ~class_:"h-4 w-4" Letter_b ]
         ; Toggle_group.item
             group
             ~value:"italic"
             ~attrs:[ Attr.create "aria-label" "Toggle italic" ]
             [ Icon.view ~class_:"h-4 w-4" Italic ]
         ; Toggle_group.item
             group
             ~value:"strikethrough"
             ~attrs:[ Attr.create "aria-label" "Toggle strikethrough" ]
             [ Icon.view ~class_:"h-4 w-4" Underline ]
         ]))
      graph
  in
  group.view
(*$*)

(*$ Spacing
   With [spacing], the items stand apart instead of joining. *)
let spacing (local_ graph) =
  let%arr group =
    Toggle_group.multiple_component
      ~variant:Outline
      ~spacing:2
      ~size:Sm
      (return (fun group ->
         [ Toggle_group.item
             group
             ~value:"star"
             ~attrs:[ Attr.create "aria-label" "Toggle star" ]
             ~class_:
               "data-[state=on]:bg-transparent data-[state=on]:*:[svg]:fill-yellow-500 \
                data-[state=on]:*:[svg]:stroke-yellow-500"
             [ Icon.view Star; Node.text "Star" ]
         ; Toggle_group.item
             group
             ~value:"heart"
             ~attrs:[ Attr.create "aria-label" "Toggle heart" ]
             ~class_:
               "data-[state=on]:bg-transparent data-[state=on]:*:[svg]:fill-red-500 \
                data-[state=on]:*:[svg]:stroke-red-500"
             [ Icon.view Heart; Node.text "Heart" ]
         ; Toggle_group.item
             group
             ~value:"bookmark"
             ~attrs:[ Attr.create "aria-label" "Toggle bookmark" ]
             ~class_:
               "data-[state=on]:bg-transparent data-[state=on]:*:[svg]:fill-blue-500 \
                data-[state=on]:*:[svg]:stroke-blue-500"
             [ Icon.view Bookmark; Node.text "Bookmark" ]
         ]))
      graph
  in
  group.view
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Toggle Group"
    ~description:"A set of two-state buttons that can be toggled on or off."
    ~usage:
      {|Toggle_group.single ~value ~on_change:set_value (fun group ->
  [ Toggle_group.item group ~value:"a" [ Node.text "A" ]
  ; Toggle_group.item group ~value:"b" [ Node.text "B" ]
  ])|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "value"
            , "string option / string list"
            , "The pressed item ([single]) or items ([multiple])." )
          ; ( "on_change"
            , "_ -> unit Effect.t"
            , "Gets the new value when an item is pressed." )
          ; ( "default_value"
            , "string / string list"
            , "What [single_component] or [multiple_component] starts with." )
          ; "variant", "Toggle.Variant.t", "[Default] or [Outline], for every item."
          ; "size", "Toggle.Size.t", "[Default], [Sm] or [Lg], for every item."
          ; ( "spacing"
            , "int"
            , "The gap between items, in Tailwind's spacing unit; 2 by default, 0 \
               joins them." )
          ; ( "orientation"
            , "Roving.Orientation.t"
            , "Lays the items out in a row ([Horizontal], the default) or a column." )
          ; "disabled", "bool", "Greys out every item."
          ; "class_", "string", "More Tailwind classes, merged last."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ; Doc.p
          "The last argument builds the items from the group: [Toggle_group.item group \
           ~value children]. Arrow keys, Home and End move the focus between items."
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Outline" outline
    ; Doc.example ~page "Single" single
    ; Doc.example ~page "Small" small
    ; Doc.example ~page "Large" large
    ; Doc.example ~page "Disabled" disabled
    ; Doc.example ~page "Spacing" spacing
    ]
;;
