open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node

let page = "alert_dialog"

(*$ Demo *)
let demo =
  Alert_dialog.component
    (Bonsai.return (fun dialog ->
       [ Alert_dialog.trigger
           dialog
           (Button.view ~variant:Outline [ Node.text "Show Dialog" ])
       ; Alert_dialog.content
           dialog
           [ Alert_dialog.header
               [ Alert_dialog.title
                   dialog
                   [ Node.text "Are you absolutely sure?" ]
               ; Alert_dialog.description
                   dialog
                   [ Node.text
                       "This action cannot be undone. This will permanently \
                        delete your account and remove your data from our \
                        servers."
                   ]
               ]
           ; Alert_dialog.footer
               [ Alert_dialog.cancel dialog [ Node.text "Cancel" ]
               ; Alert_dialog.action dialog [ Node.text "Continue" ]
               ]
           ]
       ]))
;;

(*$*)

(*$ Small, with media *)
let small =
  Alert_dialog.component
    (Bonsai.return (fun dialog ->
       [ Alert_dialog.trigger
           dialog
           (Button.view ~variant:Outline [ Node.text "Delete chat" ])
       ; Alert_dialog.content
           dialog
           ~size:Sm
           [ Alert_dialog.header
               [ Alert_dialog.media
                   ~class_:
                     "bg-destructive/10 text-destructive dark:bg-destructive/20"
                   [ Icon.view Trash ]
               ; Alert_dialog.title dialog [ Node.text "Delete chat?" ]
               ; Alert_dialog.description
                   dialog
                   [ Node.text
                       "This will permanently delete this chat conversation."
                   ]
               ]
           ; Alert_dialog.footer
               [ Alert_dialog.cancel dialog [ Node.text "Cancel" ]
               ; Alert_dialog.action
                   dialog
                   ~variant:Destructive
                   [ Node.text "Delete" ]
               ]
           ]
       ]))
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Alert dialog"
    ~group:Overlays
    ~description:
      "A modal dialog that interrupts the user with important content and \
       expects a response."
    ~usage:
      {|Alert_dialog.component
  (return (fun dialog ->
     [ Alert_dialog.trigger dialog (Button.view ~variant:Outline [ Node.text "Open" ])
     ; Alert_dialog.content dialog
         [ Alert_dialog.header
             [ Alert_dialog.title dialog [ Node.text "Are you absolutely sure?" ]
             ; Alert_dialog.description dialog [ Node.text "This action cannot be undone." ]
             ]
         ; Alert_dialog.footer
             [ Alert_dialog.cancel dialog [ Node.text "Cancel" ]
             ; Alert_dialog.action dialog ~on_click:delete [ Node.text "Continue" ]
             ]
         ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "open_, on_open_change"
            , "bool, bool -> unit Effect.t"
            , "[Alert_dialog.view]: controlled. [Alert_dialog.component] keeps \
               it ([?default_open])." )
          ; "size", "Alert_dialog.Size.t", "[content]: [Default] or [Sm]."
          ; ( "on_click"
            , "unit Effect.t"
            , "[action]: what it does; the dialog closes after it." )
          ; ( "variant, size"
            , "Button.Variant.t, Button.Size.t"
            , "[action] (default variant) and [cancel] (outline) are buttons." )
          ]
      ; Doc.p
          "Unlike a dialog, a click outside does not close it; it opens with \
           the focus on Cancel, and Esc closes it."
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Small, with media" small
    ]
;;
