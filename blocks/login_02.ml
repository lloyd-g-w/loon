open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let github_logo =
  Node.create_svg
    "svg"
    ~attrs:
      [ Attr.create "xmlns" "http://www.w3.org/2000/svg"
      ; Attr.create "viewBox" "0 0 24 24"
      ]
    [ Node.create_svg
        "path"
        ~attrs:
          [ Attr.create
              "d"
              "M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 \
               11.385.6.113.82-.258.82-.577 \
               0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 \
               18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 \
               1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 \
               3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 \
               0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 \
               1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 \
               3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 \
               3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 \
               5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 \
               .315.21.69.825.57C20.565 22.092 24 17.592 24 \
               12.297c0-6.627-5.373-12-12-12"
          ; Attr.create "fill" "currentColor"
          ]
        []
    ]
;;

let login_form ?(class_ = "") () =
  Node.form
    ~attrs:[ Attr.class_ (Cn.cn [ "flex flex-col gap-6"; class_ ]) ]
    [ Field.group
        [ Node.div
            ~attrs:
              [ Attr.class_ "flex flex-col items-center gap-1 text-center" ]
            [ Node.h1
                ~attrs:[ Attr.class_ "text-2xl font-bold" ]
                [ Node.text "Login to your account" ]
            ; Node.p
                ~attrs:
                  [ Attr.class_ "text-sm text-balance text-muted-foreground" ]
                [ Node.text "Enter your email below to login to your account" ]
            ]
        ; Field.root
            [ Field.label ~for_:"email" [ Node.text "Email" ]
            ; Input.view
                ~id:"email"
                ~type_:Email
                ~placeholder:"m@example.com"
                ~required:true
                ~class_:"bg-background"
                ()
            ]
        ; Field.root
            [ Node.div
                ~attrs:[ Attr.class_ "flex items-center" ]
                [ Field.label ~for_:"password" [ Node.text "Password" ]
                ; Node.a
                    ~attrs:
                      [ Attr.href "#"
                      ; Attr.class_
                          "ml-auto text-sm underline-offset-4 hover:underline"
                      ]
                    [ Node.text "Forgot your password?" ]
                ]
            ; Input.view
                ~id:"password"
                ~type_:Password
                ~required:true
                ~class_:"bg-background"
                ()
            ]
        ; Field.root [ Button.view ~type_:`Submit [ Node.text "Login" ] ]
        ; Field.separator [ Node.text "Or continue with" ]
        ; Field.root
            [ Button.view
                ~variant:Outline
                ~type_:`Button
                [ github_logo; Node.text "Login with GitHub" ]
            ; Field.description
                ~class_:"text-center"
                [ Node.text "Don't have an account? "
                ; Node.a
                    ~attrs:
                      [ Attr.href "#"
                      ; Attr.class_ "underline underline-offset-4"
                      ]
                    [ Node.text "Sign up" ]
                ]
            ]
        ]
    ]
;;

let view _graph__LOCAL =
  Bonsai.return
    (Node.div
       ~attrs:[ Attr.class_ "grid min-h-svh lg:grid-cols-2" ]
       [ Node.div
           ~attrs:[ Attr.class_ "flex flex-col gap-4 p-6 md:p-10" ]
           [ Node.div
               ~attrs:
                 [ Attr.class_ "flex justify-center gap-2 md:justify-start" ]
               [ Node.a
                   ~attrs:
                     [ Attr.href "#"
                     ; Attr.class_ "flex items-center gap-2 font-medium"
                     ]
                   [ Node.div
                       ~attrs:
                         [ Attr.class_
                             "flex size-6 items-center justify-center \
                              rounded-md bg-primary text-primary-foreground"
                         ]
                       [ Icon.view ~class_:"size-4" Gallery_vertical_end ]
                   ; Node.text "Acme Inc."
                   ]
               ]
           ; Node.div
               ~attrs:[ Attr.class_ "flex flex-1 items-center justify-center" ]
               [ Node.div
                   ~attrs:[ Attr.class_ "w-full max-w-xs" ]
                   [ login_form () ]
               ]
           ]
       ; Node.div
           ~attrs:[ Attr.class_ "relative hidden bg-muted lg:block" ]
           [ Node.img
               ~attrs:
                 [ Attr.src "placeholder.svg"
                 ; Attr.alt "Image"
                 ; Attr.class_
                     "absolute inset-0 h-full w-full object-cover \
                      dark:brightness-[0.2] dark:grayscale"
                 ]
               ()
           ]
       ])
;;
