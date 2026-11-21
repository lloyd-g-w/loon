open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "card"

(*$ Demo *)
let demo (local_ graph) =
  let email =
    Input.component
      ~id:"email"
      ~type_:Email
      ~placeholder:"m@example.com"
      ~required:true
      graph
  in
  let password = Input.component ~id:"password" ~type_:Password ~required:true graph in
  let%arr email and password in
  Card.root
    ~class_:"w-full max-w-sm"
    [ Card.header
        [ Card.title [ Node.text "Login to your account" ]
        ; Card.description [ Node.text "Enter your email below to login to your account" ]
        ; Card.action [ Button.view ~variant:Link [ Node.text "Sign Up" ] ]
        ]
    ; Card.content
        [ Node.form
            [ Node.div
                ~attrs:[ Attr.class_ "flex flex-col gap-6" ]
                [ Node.div
                    ~attrs:[ Attr.class_ "grid gap-2" ]
                    [ Label.view ~for_:"email" [ Node.text "Email" ]; email.view ]
                ; Node.div
                    ~attrs:[ Attr.class_ "grid gap-2" ]
                    [ Node.div
                        ~attrs:[ Attr.class_ "flex items-center" ]
                        [ Label.view ~for_:"password" [ Node.text "Password" ]
                        ; Node.a
                            ~attrs:
                              [ Attr.href "#/card"
                              ; Attr.class_
                                  "ml-auto inline-block text-sm underline-offset-4 \
                                   hover:underline"
                              ]
                            [ Node.text "Forgot your password?" ]
                        ]
                    ; password.view
                    ]
                ]
            ]
        ]
    ; Card.footer
        ~class_:"flex-col gap-2"
        [ Button.view ~type_:`Submit ~class_:"w-full" [ Node.text "Login" ]
        ; Button.view ~variant:Outline ~class_:"w-full" [ Node.text "Login with Google" ]
        ]
    ]
(*$*)

(*$ Simple *)
let simple =
  Card.root
    ~class_:"w-full max-w-sm"
    [ Card.header
        [ Card.title [ Node.text "Notifications" ]
        ; Card.description [ Node.text "You have 3 unread messages." ]
        ]
    ; Card.content
        [ Node.p
            ~attrs:[ Attr.class_ "text-sm" ]
            [ Node.text "Your call has been confirmed for 5:00 PM today." ]
        ]
    ; Card.footer
        ~class_:"border-t"
        [ Button.view ~class_:"w-full" [ Icon.view Check; Node.text "Mark all as read" ] ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Card"
    ~group:Display
    ~description:"Displays a card with header, content, and footer."
    ~usage:
      {|Card.root
  [ Card.header
      [ Card.title [ Node.text "Card Title" ]
      ; Card.description [ Node.text "Card Description" ]
      ; Card.action [ Button.view ~variant:Link [ Node.text "Card Action" ] ]
      ]
  ; Card.content [ Node.p [ Node.text "Card Content" ] ]
  ; Card.footer [ Node.p [ Node.text "Card Footer" ] ]
  ]|}
    ~body:
      [ Doc.h2 "Parts"
      ; Doc.props
          [ "Card.root", "Node.t list -> Node.t", "The card: a bordered, rounded column."
          ; "Card.header", "", "Holds the title, the description and an optional action."
          ; "Card.title", "", "The card's heading."
          ; "Card.description", "", "Muted text under the title."
          ; "Card.action", "", "Top-right of the header (e.g. a button)."
          ; "Card.content", "", "The body."
          ; ( "Card.footer"
            , ""
            , "A row at the bottom; [~class_:\"border-t\"] adds a rule above it." )
          ]
      ; Doc.p "Every part takes [?class_] (merged last) and [?attrs]."
      ]
    [ Doc.example ~page "Demo" demo; Doc.static ~page "Simple" simple ]
;;
