open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "toggle"

(*$ Demo *)
let demo (local_ graph) =
  let%arr toggle =
    Toggle.component
      ~attrs:[ Attr.create "aria-label" "Toggle bookmark" ]
      ~size:Sm
      ~variant:Outline
      [ Icon.view ~class_:"group-data-[state=on]/toggle:fill-foreground" Bookmark
      ; Node.text "Bookmark"
      ]
      graph
  in
  toggle.view
(*$*)

(*$ Outline *)
let outline (local_ graph) =
  let%arr toggle =
    Toggle.component
      ~variant:Outline
      ~attrs:[ Attr.create "aria-label" "Toggle italic" ]
      [ Icon.view Italic ]
      graph
  in
  toggle.view
(*$*)

(*$ With Text *)
let with_text (local_ graph) =
  let%arr toggle =
    Toggle.component
      ~attrs:[ Attr.create "aria-label" "Toggle italic" ]
      [ Icon.view Italic; Node.text "Italic" ]
      graph
  in
  toggle.view
(*$*)

(*$ Small *)
let small (local_ graph) =
  let%arr toggle =
    Toggle.component
      ~size:Sm
      ~attrs:[ Attr.create "aria-label" "Toggle italic" ]
      [ Icon.view Italic ]
      graph
  in
  toggle.view
(*$*)

(*$ Large *)
let large (local_ graph) =
  let%arr toggle =
    Toggle.component
      ~size:Lg
      ~attrs:[ Attr.create "aria-label" "Toggle italic" ]
      [ Icon.view Italic ]
      graph
  in
  toggle.view
(*$*)

(*$ Disabled *)
let disabled =
  Toggle.view
    ~attrs:[ Attr.create "aria-label" "Toggle italic" ]
    ~disabled:true
    ~pressed:false
    ~on_change:(fun _ -> Effect.Ignore)
    [ Icon.view ~class_:"h-4 w-4" Underline ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Toggle"
    ~description:"A two-state button that can be either on or off."
    ~usage:
      {|Toggle.view ~attrs:[ Attr.create "aria-label" "Toggle italic" ] ~pressed
  ~on_change:set_pressed [ Icon.view Italic ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "pressed", "bool", "Whether it is on ([aria-pressed], [data-state=on])."
          ; "on_change", "bool -> unit Effect.t", "Gets the new state when clicked."
          ; ( "default_pressed"
            , "bool"
            , "Whether [Toggle.component] starts on; [false] by default." )
          ; "variant", "Toggle.Variant.t", "[Default] or [Outline]."
          ; "size", "Toggle.Size.t", "[Default], [Sm] or [Lg]."
          ; "disabled", "bool", "Greys it out and ignores clicks."
          ; "class_", "string", "More Tailwind classes, merged last."
          ; ( "attrs"
            , "Vdom.Attr.t list"
            , "Extra attributes: give an icon-only toggle an aria-label." )
          ]
      ; Doc.p
          "[Toggle.classes ~variant ~size ()] gives the classes alone, for other \
           elements that should look like a toggle."
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Outline" outline
    ; Doc.example ~page "With Text" with_text
    ; Doc.example ~page "Small" small
    ; Doc.example ~page "Large" large
    ; Doc.static ~page "Disabled" disabled
    ]
;;
