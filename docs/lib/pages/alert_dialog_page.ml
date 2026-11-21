open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node

let page = "alert_dialog"

(*$ Delete account *)
let delete_account (local_ graph) =
  let deleted, set_deleted = Bonsai.state false graph in
  let dialog =
    Alert_dialog.component
      ~danger:true
      ~confirm_label:"Delete account"
      ~title:"Are you absolutely sure?"
      ~description:
        "This cannot be undone. It will permanently delete your account and remove your \
         data from our servers."
      ~trigger:(fun attrs ->
        Button.view ~attrs ~variant:Destructive [ Icon.view Trash; Node.text "Delete account" ])
      (let%arr set_deleted in
       set_deleted true)
      graph
  in
  let%arr dialog and deleted in
  Node.div
    ~attrs:[ Vdom.Attr.class_ "flex flex-wrap items-center justify-center gap-3" ]
    [ dialog
    ; (if deleted then Badge.view ~variant:Destructive [ Node.text "Deleted" ] else Node.none)
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Alert dialog"
    ~description:"Asks for confirmation before something important, often destructive."
    ~usage:
      {|Alert_dialog.component
  ~danger:true
  ~title:"Discard changes?"
  ~description:"Your edits will be lost."
  ~trigger:(fun attrs -> Button.view ~attrs [ Node.text "Discard" ])
  discard
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "title", "string", "The question."
          ; "description", "string", "What happens if confirmed."
          ; "confirm_label", "string", "Default \"Continue\"."
          ; "cancel_label", "string", "Default \"Cancel\"."
          ; "danger", "bool", "Makes the confirm button red."
          ; "on_confirm", "unit Effect.t Bonsai.t", "What confirming does."
          ]
      ; Doc.p
          "Unlike a dialog it is not closed by a click outside, and the cancel button has \
           focus when it opens, so Enter does not confirm by accident."
      ]
    [ Doc.example ~page "Delete account" delete_account ]
;;
