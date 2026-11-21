open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "alert"

(*$ Demo *)
let demo =
  Node.div
    ~attrs:[ Attr.class_ "grid w-full max-w-xl items-start gap-4" ]
    [ Alert.root
        [ Icon.view Circle_check
        ; Alert.title [ Node.text "Success! Your changes have been saved" ]
        ; Alert.description
            [ Node.text "This is an alert with icon, title and description." ]
        ]
    ; Alert.root
        [ Icon.view Popcorn
        ; Alert.title [ Node.text "This Alert has a title and an icon. No description." ]
        ]
    ; Alert.root
        ~variant:Destructive
        [ Icon.view Circle_exclamation_point
        ; Alert.title [ Node.text "Unable to process your payment." ]
        ; Alert.description
            [ Node.p [ Node.text "Please verify your billing information and try again." ]
            ; Node.ul
                ~attrs:[ Attr.class_ "list-inside list-disc text-sm" ]
                [ Node.li [ Node.text "Check your card details" ]
                ; Node.li [ Node.text "Ensure sufficient funds" ]
                ; Node.li [ Node.text "Verify billing address" ]
                ]
            ]
        ]
    ]
(*$*)

(*$ Destructive *)
let destructive =
  Alert.root
    ~variant:Destructive
    [ Icon.view Circle_exclamation_point
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
