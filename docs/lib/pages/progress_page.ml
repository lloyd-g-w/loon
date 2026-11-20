open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "progress"

(*$ Uploading
   The bar animates between values. *)
let uploading (local_ graph) =
  let value, set_value = Bonsai.state 35. graph in
  let%arr value and set_value in
  Node.div
    ~attrs:[ Attr.class_ "docs-stack"; Attr.create "style" "max-width: 24rem; width: 100%" ]
    [ Node.div
        ~attrs:[ Attr.create "style" "display: flex; justify-content: space-between; font-size: 0.875rem" ]
        [ Node.text "photos.zip"
        ; Node.span
            ~attrs:[ Attr.create "style" "color: var(--loon-muted-foreground)" ]
            [ Node.textf "%.0f%%" value ]
        ]
    ; Progress.view ~label:"Uploading photos.zip" ~value ()
    ; Node.div
        ~attrs:[ Attr.class_ "docs-row" ]
        [ Button.view
            ~size:Sm
            ~variant:Outline
            ~on_click:(set_value (Float.max 0. (value -. 15.)))
            [ Node.text "−15" ]
        ; Button.view
            ~size:Sm
            ~variant:Outline
            ~on_click:(set_value (Float.min 100. (value +. 15.)))
            [ Node.text "+15" ]
        ]
    ]
(*$*)

(*$ Tones, sizes and unknown progress *)
let tones =
  Node.div
    ~attrs:[ Attr.class_ "docs-stack"; Attr.create "style" "max-width: 24rem; width: 100%" ]
    [ Progress.view ~size:Sm ~tone:Accent ~value:20. ()
    ; Progress.view ~tone:Success ~value:100. ()
    ; Progress.view ~tone:Warning ~value:70. ()
    ; Progress.view ~size:Lg ~tone:Danger ~value:90. ()
    ; Progress.view ~label:"Loading" ()
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Progress"
    ~group:Feedback
    ~description:"How far along a task is, or that it is under way."
    ~usage:{|Progress.view ~label:"Upload" ~value:42. ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "value", "float", "Out of max; absent for an indeterminate bar."
          ; "max", "float", "Default 100."
          ; "tone", "Progress.Tone.t", "Primary (default), Accent, Success, Warning or Danger."
          ; "size", "Progress.Size.t", "Sm, Md (default) or Lg."
          ; "label", "string", "The bar's name for screen readers."
          ]
      ]
    [ Doc.example ~page "Uploading" uploading
    ; Doc.static ~page "Tones, sizes and unknown progress" tones
    ]
;;
