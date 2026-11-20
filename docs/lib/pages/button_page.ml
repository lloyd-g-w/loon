open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node

let page = "button"

(*$ Variants *)
let variants =
  Node.div
    ~attrs:[ Vdom.Attr.class_ "docs-row" ]
    (List.map Button.Variant.all ~f:(fun variant ->
       Button.view ~variant [ Node.text (Button.Variant.name variant) ]))
(*$*)

(*$ Sizes *)
let sizes =
  Node.div
    ~attrs:[ Vdom.Attr.class_ "docs-row" ]
    [ Button.view ~size:Sm [ Node.text "Small" ]
    ; Button.view ~size:Md [ Node.text "Medium" ]
    ; Button.view ~size:Lg [ Node.text "Large" ]
    ; Button.view ~size:Icon ~variant:Outline [ Icon.view Plus ]
    ]
(*$*)

(*$ With an icon *)
let with_icon =
  Node.div
    ~attrs:[ Vdom.Attr.class_ "docs-row" ]
    [ Button.with_icon Mail "Sign in with email"
    ; Button.with_icon ~variant:Outline Github "GitHub"
    ; Button.view ~loading:true [ Node.text "Please wait" ]
    ]
(*$*)

(*$ Counter
   Buttons take the effect to run when clicked. *)
let counter (local_ graph) =
  let count, set_count = Bonsai.state 0 graph in
  let%arr count and set_count in
  Node.div
    ~attrs:[ Vdom.Attr.class_ "docs-row" ]
    [ Button.view ~variant:Outline ~size:Icon ~on_click:(set_count (count - 1)) [ Icon.view Minus ]
    ; Node.span ~attrs:[ Vdom.Attr.class_ "docs-count" ] [ Node.textf "%d" count ]
    ; Button.view ~variant:Outline ~size:Icon ~on_click:(set_count (count + 1)) [ Icon.view Plus ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Button"
    ~group:Forms
    ~description:"Triggers an action, or looks like it does."
    ~usage:{|Button.view ~variant:Outline ~on_click:save [ Node.text "Save" ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "variant", "Button.Variant.t", "Primary (default), Secondary, Outline, Ghost, Accent, Danger or Link."
          ; "size", "Button.Size.t", "Sm, Md (default), Lg, or Icon for a square button."
          ; "disabled", "bool", "Greys it out and ignores clicks."
          ; "loading", "bool", "Shows a spinner and disables it."
          ; "on_click", "unit Effect.t", "What a click does."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes; classes and styles merge."
          ]
      ]
    [ Doc.static ~page "Variants" variants
    ; Doc.static ~page "Sizes" sizes
    ; Doc.static ~page "With an icon" with_icon
    ; Doc.example ~page "Counter" counter
    ]
;;
