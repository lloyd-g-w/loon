open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "alert"

(*$ Variants *)
let variants =
  Node.div
    ~attrs:[ Attr.class_ "docs-stack" ]
    [ Alert.view
        ~title:"Heads up!"
        [ Node.text "You can add components to your app with the loon command." ]
    ; Alert.view
        ~variant:Info
        ~title:"A new version is available"
        [ Node.text "loon 0.2 adds a calendar and toasts." ]
    ; Alert.view
        ~variant:Success
        ~title:"Payment received"
        [ Node.text "Your invoice INV-0042 has been paid in full." ]
    ; Alert.view
        ~variant:Warning
        ~title:"Your trial ends in 3 days"
        [ Node.text "Add a payment method to keep your projects running." ]
    ; Alert.view
        ~variant:Danger
        ~title:"Your session has expired"
        [ Node.text "Please sign in again to continue." ]
    ]
(*$*)

(*$ With an action *)
let with_action =
  Alert.view
    ~variant:Info
    ~icon:(Some Bell)
    ~title:"Turn on notifications"
    ~action:(Button.view ~size:Sm ~variant:Outline [ Node.text "Enable" ])
    [ Node.text "Hear about replies as soon as they happen." ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Alert"
    ~group:Feedback
    ~description:"A callout for something the user should notice."
    ~usage:{|Alert.view ~variant:Warning ~title:"Careful" [ Node.text "This can't be undone." ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "variant", "Alert.Variant.t", "Neutral (default), Info, Success, Warning or Danger."
          ; "icon", "Icon.t option", "Replaces the variant's icon; None hides it."
          ; "title", "string", "A bold first line."
          ; "action", "Vdom.Node.t", "A button or link at the end."
          ; "children", "Vdom.Node.t list", "The description."
          ]
      ; Doc.p
          "Danger and warning alerts have role=\"alert\", so screen readers announce them at once; the others are polite status messages."
      ]
    [ Doc.static ~page "Variants" variants; Doc.static ~page "With an action" with_action ]
;;
