open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "dialog"
let label = Example_form.label
let input = Example_form.input

(*$ Demo *)
let demo =
  Dialog.component
    (Bonsai.return (fun dialog ->
       [ Dialog.trigger
           dialog
           (Button.view ~variant:Outline [ Node.text "Open Dialog" ])
       ; Dialog.content
           dialog
           ~class_:"sm:max-w-[425px]"
           [ Dialog.header
               [ Dialog.title dialog [ Node.text "Edit profile" ]
               ; Dialog.description
                   dialog
                   [ Node.text
                       "Make changes to your profile here. Click save when \
                        you're done."
                   ]
               ]
           ; Node.div
               ~attrs:[ Attr.class_ "grid gap-4" ]
               [ Node.div
                   ~attrs:[ Attr.class_ "grid gap-3" ]
                   [ label ~for_:"name-1" "Name"
                   ; input ~id:"name-1" "Pedro Duarte"
                   ]
               ; Node.div
                   ~attrs:[ Attr.class_ "grid gap-3" ]
                   [ label ~for_:"username-1" "Username"
                   ; input ~id:"username-1" "@peduarte"
                   ]
               ]
           ; Dialog.footer
               [ Dialog.close
                   dialog
                   (Button.view ~variant:Outline [ Node.text "Cancel" ])
               ; Button.view ~type_:`Submit [ Node.text "Save changes" ]
               ]
           ]
       ]))
;;

(*$*)

(*$ Custom close button *)
let close_button =
  Dialog.component
    (Bonsai.return (fun dialog ->
       [ Dialog.trigger
           dialog
           (Button.view ~variant:Outline [ Node.text "Share" ])
       ; Dialog.content
           dialog
           ~class_:"sm:max-w-md"
           [ Dialog.header
               [ Dialog.title dialog [ Node.text "Share link" ]
               ; Dialog.description
                   dialog
                   [ Node.text
                       "Anyone who has this link will be able to view this."
                   ]
               ]
           ; Node.div
               ~attrs:[ Attr.class_ "flex items-center gap-2" ]
               [ Node.div
                   ~attrs:[ Attr.class_ "grid flex-1 gap-2" ]
                   [ label ~class_:"sr-only" ~for_:"link" "Link"
                   ; input
                       ~attrs:[ Attr.create "readonly" "" ]
                       ~id:"link"
                       "https://ui.shadcn.com/docs/installation"
                   ]
               ]
           ; Dialog.footer
               ~class_:"sm:justify-start"
               [ Dialog.close
                   dialog
                   (Button.view ~variant:Secondary [ Node.text "Close" ])
               ]
           ]
       ]))
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Dialog"
    ~group:Overlays
    ~description:
      "A window overlaid on either the primary window or another dialog \
       window, rendering the content underneath inert."
    ~usage:
      {|Dialog.component
  (return (fun dialog ->
     [ Dialog.trigger dialog (Button.view ~variant:Outline [ Node.text "Open" ])
     ; Dialog.content dialog
         [ Dialog.header
             [ Dialog.title dialog [ Node.text "Are you absolutely sure?" ]
             ; Dialog.description dialog [ Node.text "This action cannot be undone." ]
             ]
         ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "open_, on_open_change"
            , "bool, bool -> unit Effect.t"
            , "[Dialog.view]: controlled. [Dialog.component] keeps it \
               ([?default_open])." )
          ; ( "trigger, close"
            , "Dialog.t -> Node.t -> Node.t"
            , "Give an element (a [Button.view]) the part's attributes: \
               Radix's [asChild]." )
          ; ( "show_close_button"
            , "bool"
            , "[content]: the X in the corner (default [true]). [footer \
               ~show_close_button:dialog] adds a Close button." )
          ; ( "initial_focus"
            , "string"
            , "[content]: a selector for the element to focus when it opens \
               (default: the first focusable one)." )
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.table
          [ "Key"; "Does" ]
          [ [ Doc.text "Space / Enter"; Doc.text "On the trigger: open it." ]
          ; [ Doc.text "Tab / Shift+Tab"
            ; Doc.text "Move between its focusable elements, cycling."
            ]
          ; [ Doc.text "Esc"
            ; Doc.text "Close it, returning focus to the trigger."
            ]
          ]
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Custom close button" close_button
    ]
;;
