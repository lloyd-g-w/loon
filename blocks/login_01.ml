open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let login_form ?(class_ = "") () =
  Node.div
    ~attrs:[ Attr.class_ (Cn.cn [ "flex flex-col gap-6"; class_ ]) ]
    [ Card.root
        [ Card.header
            [ Card.title [ Node.text "Login to your account" ]
            ; Card.description
                [ Node.text "Enter your email below to login to your account" ]
            ]
        ; Card.content
            [ Node.form
                [ Field.group
                    [ Field.root
                        [ Field.label ~for_:"email" [ Node.text "Email" ]
                        ; Input.view
                            ~id:"email"
                            ~type_:Email
                            ~placeholder:"m@example.com"
                            ~required:true
                            ()
                        ]
                    ; Field.root
                        [ Node.div
                            ~attrs:[ Attr.class_ "flex items-center" ]
                            [ Field.label
                                ~for_:"password"
                                [ Node.text "Password" ]
                            ; Node.a
                                ~attrs:
                                  [ Attr.href "#"
                                  ; Attr.class_
                                      "ml-auto inline-block text-sm \
                                       underline-offset-4 hover:underline"
                                  ]
                                [ Node.text "Forgot your password?" ]
                            ]
                        ; Input.view
                            ~id:"password"
                            ~type_:Password
                            ~required:true
                            ()
                        ]
                    ; Field.root
                        [ Button.view ~type_:`Submit [ Node.text "Login" ]
                        ; Button.view
                            ~variant:Outline
                            ~type_:`Button
                            [ Node.text "Login with Google" ]
                        ; Field.description
                            ~class_:"text-center"
                            [ Node.text "Don't have an account? "
                            ; Node.a
                                ~attrs:[ Attr.href "#" ]
                                [ Node.text "Sign up" ]
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
       [ Node.div ~attrs:[ Attr.class_ "w-full max-w-sm" ] [ login_form () ] ])
;;
