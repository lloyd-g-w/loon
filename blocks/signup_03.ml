open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let signup_form ?(class_ = "") () =
  Node.div
    ~attrs:[ Attr.class_ (Cn.cn [ "flex flex-col gap-6"; class_ ]) ]
    [ Card.root
        [ Card.header
            ~class_:"text-center"
            [ Card.title ~class_:"text-xl" [ Node.text "Create your account" ]
            ; Card.description
                [ Node.text "Enter your email below to create your account" ]
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
                        ]
                    ; Field.root
                        [ Field.root
                            ~class_:"grid grid-cols-2 gap-4"
                            [ Field.root
                                [ Field.label
                                    ~for_:"password"
                                    [ Node.text "Password" ]
                                ; Input.view
                                    ~id:"password"
                                    ~type_:Password
                                    ~required:true
                                    ()
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
                                ]
                            ]
                        ; Field.description
                            [ Node.text "Must be at least 8 characters long." ]
                        ]
                    ; Field.root
                        [ Button.view
                            ~type_:`Submit
                            [ Node.text "Create Account" ]
                        ; Field.description
                            ~class_:"text-center"
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
    ; Field.description
        ~class_:"px-6 text-center"
        [ Node.text "By clicking continue, you agree to our "
        ; Node.a ~attrs:[ Attr.href "#" ] [ Node.text "Terms of Service" ]
        ; Node.text " and "
        ; Node.a ~attrs:[ Attr.href "#" ] [ Node.text "Privacy Policy" ]
        ; Node.text "."
        ]
    ]
;;

let view _graph__LOCAL =
  Bonsai.return
    (Node.div
       ~attrs:
         [ Attr.class_
             "flex min-h-svh flex-col items-center justify-center gap-6 \
              bg-muted p-6 md:p-10"
         ]
       [ Node.div
           ~attrs:[ Attr.class_ "flex w-full max-w-sm flex-col gap-6" ]
           [ Node.a
               ~attrs:
                 [ Attr.href "#"
                 ; Attr.class_ "flex items-center gap-2 self-center font-medium"
                 ]
               [ Node.div
                   ~attrs:
                     [ Attr.class_
                         "flex size-6 items-center justify-center rounded-md \
                          bg-primary text-primary-foreground"
                     ]
                   [ Icon.view ~class_:"size-4" Gallery_vertical_end ]
               ; Node.text "Acme Inc."
               ]
           ; signup_form ()
           ]
       ])
;;
