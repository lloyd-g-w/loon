open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let signup_form ?attrs ?class_ () =
  Card.root
    ?attrs
    ?class_
    [ Card.header
        [ Card.title [ Node.text "Create an account" ]
        ; Card.description
            [ Node.text "Enter your information below to create your account" ]
        ]
    ; Card.content
        [ Node.form
            [ Field.group
                [ Field.root
                    [ Field.label ~for_:"name" [ Node.text "Full Name" ]
                    ; Input.view
                        ~id:"name"
                        ~type_:Text
                        ~placeholder:"John Doe"
                        ~required:true
                        ()
                    ]
                ; Field.root
                    [ Field.label ~for_:"email" [ Node.text "Email" ]
                    ; Input.view
                        ~id:"email"
                        ~type_:Email
                        ~placeholder:"m@example.com"
                        ~required:true
                        ()
                    ; Field.description
                        [ Node.text
                            "We'll use this to contact you. We will not share \
                             your email with anyone else."
                        ]
                    ]
                ; Field.root
                    [ Field.label ~for_:"password" [ Node.text "Password" ]
                    ; Input.view
                        ~id:"password"
                        ~type_:Password
                        ~required:true
                        ()
                    ; Field.description
                        [ Node.text "Must be at least 8 characters long." ]
                    ]
                ; Field.root
                    [ Field.label
                        ~for_:"confirm-password"
                        [ Node.text "Confirm Password" ]
                    ; Input.view
                        ~id:"confirm-password"
                        ~type_:Password
                        ~required:true
                        ()
                    ; Field.description
                        [ Node.text "Please confirm your password." ]
                    ]
                ; Field.group
                    [ Field.root
                        [ Button.view
                            ~type_:`Submit
                            [ Node.text "Create Account" ]
                        ; Button.view
                            ~variant:Outline
                            ~type_:`Button
                            [ Node.text "Sign up with Google" ]
                        ; Field.description
                            ~class_:"px-6 text-center"
                            [ Node.text "Already have an account? "
                            ; Node.a
                                ~attrs:[ Attr.href "#" ]
                                [ Node.text "Sign in" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    ]
;;

let view _graph__LOCAL =
  Bonsai.return
    (Node.div
       ~attrs:
         [ Attr.class_
             "flex min-h-svh w-full items-center justify-center p-6 md:p-10"
         ]
       [ Node.div ~attrs:[ Attr.class_ "w-full max-w-sm" ] [ signup_form () ] ])
;;
