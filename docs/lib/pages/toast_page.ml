open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "toast"

(*$ Toasts
   Put a toaster's view once in your page, and pass its push to whatever announces things. *)
let toasts (local_ graph) =
  let toaster = Toast.component graph in
  let%arr { Toast.Toaster.view; push; dismiss_all = _ } = toaster in
  Node.div
    ~attrs:[ Attr.class_ "docs-row" ]
    [ Button.view
        ~variant:Outline
        ~on_click:
          (push
             (Toast.create
                ~description:"Friday 20 November 2026 at 5:57 pm"
                "Event has been created"))
        [ Node.text "Show a toast" ]
    ; Button.view
        ~variant:Outline
        ~on_click:
          (push
             (Toast.create
                ~variant:Success
                ~description:"Your changes are live."
                "Deployed to production"))
        [ Node.text "Success" ]
    ; Button.view
        ~variant:Outline
        ~on_click:
          (push
             (Toast.create
                ~variant:Danger
                ~description:"There was a problem with your request."
                "Uh oh! Something went wrong"))
        [ Node.text "Error" ]
    ; Button.view
        ~variant:Outline
        ~on_click:
          (push
             (Toast.create
                ~duration:None
                ~action:("Undo", Effect.Ignore)
                ~description:"It's in the bin for 30 days."
                "Message deleted"))
        [ Node.text "With an action" ]
    ; view
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Toast"
    ~group:Feedback
    ~description:"Short, passing messages in a corner of the screen."
    ~usage:{|push (Toast.create ~variant:Success "Saved")|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "Toast.create title", "string", "The message."
          ; "description", "string", "A second line."
          ; "variant", "Toast.Variant.t", "Neutral (default), Success, Info, Warning or Danger."
          ; "action", "string * unit Effect.t", "A button; pressing it also dismisses the toast."
          ; "duration", "Time_ns.Span.t option", "How long it stays (default 5 s); None until dismissed."
          ; "Toast.component ~position", "Toast.Position.t", "Which corner (default Bottom_right); phones always use the bottom."
          ; "max_visible", "int", "How many show at once (default 3)."
          ]
      ]
    [ Doc.example ~page "Toasts" toasts ]
;;
