open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "button"

(*$ Demo *)
let demo =
  Node.div
    ~attrs:[ Attr.class_ "flex flex-wrap items-center gap-2 md:flex-row" ]
    [ Button.view ~variant:Outline [ Node.text "Button" ]
    ; Button.view
        ~variant:Outline
        ~size:Icon
        ~attrs:[ Attr.create "aria-label" "Submit" ]
        [ Icon.view Arrow_up ]
    ]
(*$*)

(*$ Size *)
let size =
  let row children = Node.div ~attrs:[ Attr.class_ "flex items-start gap-2" ] children in
  let icon size =
    Button.view
      ~size
      ~variant:Outline
      ~attrs:[ Attr.create "aria-label" "Submit" ]
      [ Icon.view Arrow_up_right ]
  in
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col items-start gap-8 sm:flex-row" ]
    [ row [ Button.view ~size:Sm ~variant:Outline [ Node.text "Small" ]; icon Icon_sm ]
    ; row [ Button.view ~variant:Outline [ Node.text "Default" ]; icon Icon ]
    ; row [ Button.view ~size:Lg ~variant:Outline [ Node.text "Large" ]; icon Icon_lg ]
    ]
(*$*)

(*$ Default *)
let default = Button.view [ Node.text "Button" ]
(*$*)

(*$ Outline *)
let outline = Button.view ~variant:Outline [ Node.text "Outline" ]
(*$*)

(*$ Secondary *)
let secondary = Button.view ~variant:Secondary [ Node.text "Secondary" ]
(*$*)

(*$ Ghost *)
let ghost = Button.view ~variant:Ghost [ Node.text "Ghost" ]
(*$*)

(*$ Destructive *)
let destructive = Button.view ~variant:Destructive [ Node.text "Destructive" ]
(*$*)

(*$ Link *)
let link = Button.view ~variant:Link [ Node.text "Link" ]
(*$*)

(*$ Icon *)
let icon = Button.view ~variant:Outline ~size:Icon [ Icon.view Circle_fading_arrow_up ]
(*$*)

(*$ With Icon
   Put an icon before the text; the button sizes it and tightens its padding. *)
let with_icon =
  Button.view ~variant:Outline ~size:Sm [ Icon.view Git_branch; Node.text "New Branch" ]
(*$*)

(*$ Rounded *)
let rounded =
  Button.view ~variant:Outline ~size:Icon ~class_:"rounded-full" [ Icon.view Arrow_up ]
(*$*)

(*$ Spinner *)
let spinner =
  Button.view
    ~size:Sm
    ~variant:Outline
    ~disabled:true
    [ Icon.view ~class_:"size-4 animate-spin" Loader_circle; Node.text "Submit" ]
(*$*)

(*$ Link as a button
   [Button.link] is shadcn's [<Button asChild><a>]: a link that looks like a
   button. *)
let as_link = Button.link ~href:"#/button" [ Node.text "Login" ]
(*$*)

(*$ Counter
   Buttons take the effect to run when clicked. *)
let counter (local_ graph) =
  let count, set_count = Bonsai.state 0 graph in
  let%arr count and set_count in
  Node.div
    ~attrs:[ Attr.class_ "flex items-center gap-2" ]
    [ Button.view
        ~variant:Outline
        ~size:Icon_sm
        ~on_click:(set_count (count - 1))
        [ Icon.view Minus ]
    ; Node.span ~attrs:[ Attr.class_ "w-8 text-center tabular-nums" ] [ Node.textf "%d" count ]
    ; Button.view
        ~variant:Outline
        ~size:Icon_sm
        ~on_click:(set_count (count + 1))
        [ Icon.view Plus ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Button"
    ~group:Forms
    ~description:"Displays a button or a component that looks like a button."
    ~usage:{|Button.view ~variant:Outline ~on_click:save [ Node.text "Button" ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "variant"
            , "Button.Variant.t"
            , "[Default], [Destructive], [Outline], [Secondary], [Ghost] or [Link]." )
          ; ( "size"
            , "Button.Size.t"
            , "[Default], [Xs], [Sm], [Lg], or square: [Icon], [Icon_xs], [Icon_sm], \
               [Icon_lg]." )
          ; "disabled", "bool", "Greys it out and ignores clicks."
          ; "type_", "[`Button | `Submit | `Reset]", "The button's type; [`Button] by default."
          ; "on_click", "unit Effect.t", "What a click does."
          ; "class_", "string", "More Tailwind classes, merged last (they win conflicts)."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ; Doc.p
          "[Button.classes ~variant ~size ()] gives the classes alone, for other \
           elements that should look like a button."
      ]
    [ Doc.static ~page "Demo" demo
    ; Doc.static ~page "Size" size
    ; Doc.static ~page "Default" default
    ; Doc.static ~page "Outline" outline
    ; Doc.static ~page "Secondary" secondary
    ; Doc.static ~page "Ghost" ghost
    ; Doc.static ~page "Destructive" destructive
    ; Doc.static ~page "Link" link
    ; Doc.static ~page "Icon" icon
    ; Doc.static ~page "With Icon" with_icon
    ; Doc.static ~page "Rounded" rounded
    ; Doc.static ~page "Spinner" spinner
    ; Doc.static ~page "Link as a button" as_link
    ; Doc.example ~page "Counter" counter
    ]
;;
