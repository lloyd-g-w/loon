open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "alert"

(*$ Demo *)
let demo =
  Node.div
    ~attrs:[ Attr.class_ "grid w-full max-w-md items-start gap-4" ]
    [ Alert.root
        [ Icon.view Circle_check
        ; Alert.title [ Node.text "Payment successful" ]
        ; Alert.description
            [ Node.text
                "Your payment of $29.99 has been processed. A receipt has been sent \
                 to your email address."
            ]
        ]
    ; Alert.root
        [ Icon.view Info
        ; Alert.title [ Node.text "New feature available" ]
        ; Alert.description
            [ Node.text
                "We've added dark mode support. You can enable it in your account \
                 settings."
            ]
        ]
    ]
(*$*)

(*$ Destructive *)
let destructive =
  Alert.root
    ~variant:Destructive
    [ Icon.view Circle_alert
    ; Alert.title [ Node.text "Error" ]
    ; Alert.description [ Node.text "Your session has expired. Please log in again." ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Alert"
    ~description:"Displays a callout for user attention."
    ~usage:
      {|Alert.root
  [ Icon.view Terminal
  ; Alert.title [ Node.text "Heads up!" ]
  ; Alert.description
      [ Node.text "You can add components and dependencies to your app using the cli." ]
  ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "variant", "Alert.Variant.t", "[Alert.root]: [Default] or [Destructive]."
          ; "class_", "string", "More Tailwind classes, merged last."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ]
    [ Doc.static ~page "Demo" demo; Doc.static ~page "Destructive" destructive ]
;;
