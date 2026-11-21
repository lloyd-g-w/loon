open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "sheet"
let label = Example_form.label
let input = Example_form.input

(*$ Demo *)
let demo =
  Sheet.component
    (Bonsai.return (fun sheet ->
       [ Sheet.trigger sheet (Button.view ~variant:Outline [ Node.text "Open" ])
       ; Sheet.content
           sheet
           [ Sheet.header
               [ Sheet.title sheet [ Node.text "Edit profile" ]
               ; Sheet.description
                   sheet
                   [ Node.text
                       "Make changes to your profile here. Click save when you're done."
                   ]
               ]
           ; Node.div
               ~attrs:[ Attr.class_ "grid flex-1 auto-rows-min gap-6 px-4" ]
               [ Node.div
                   ~attrs:[ Attr.class_ "grid gap-3" ]
                   [ label ~for_:"sheet-demo-name" "Name"
                   ; input ~id:"sheet-demo-name" "Pedro Duarte"
                   ]
               ; Node.div
                   ~attrs:[ Attr.class_ "grid gap-3" ]
                   [ label ~for_:"sheet-demo-username" "Username"
                   ; input ~id:"sheet-demo-username" "@peduarte"
                   ]
               ]
           ; Sheet.footer
               [ Button.view ~type_:`Submit [ Node.text "Save changes" ]
               ; Sheet.close sheet (Button.view ~variant:Outline [ Node.text "Close" ])
               ]
           ]
       ]))
(*$*)

(*$ Side
   [~side] on [content]: [Top], [Right] (the default), [Bottom] or [Left]. *)
let side (local_ graph) =
  let sheet (side : Sheet.Side.t) =
    let name = Sheet.Side.name side in
    Sheet.component
      (Bonsai.return (fun sheet ->
         [ Sheet.trigger sheet (Button.view ~variant:Outline [ Node.text name ])
         ; Sheet.content
             sheet
             ~side
             [ Sheet.header
                 [ Sheet.title sheet [ Node.text "Edit profile" ]
                 ; Sheet.description
                     sheet
                     [ Node.text
                         "Make changes to your profile here. Click save when you're done."
                     ]
                 ]
             ; Node.div
                 ~attrs:[ Attr.class_ "grid gap-4 py-4" ]
                 [ Node.div
                     ~attrs:[ Attr.class_ "grid grid-cols-4 items-center gap-4" ]
                     [ label ~class_:"text-right" ~for_:("name-" ^ name) "Name"
                     ; input
                         ~attrs:[ Attr.class_ "col-span-3" ]
                         ~id:("name-" ^ name)
                         "Pedro Duarte"
                     ]
                 ; Node.div
                     ~attrs:[ Attr.class_ "grid grid-cols-4 items-center gap-4" ]
                     [ label ~class_:"text-right" ~for_:("username-" ^ name) "Username"
                     ; input
                         ~attrs:[ Attr.class_ "col-span-3" ]
                         ~id:("username-" ^ name)
                         "@peduarte"
                     ]
                 ]
             ; Sheet.footer
                 [ Sheet.close sheet (Button.view ~type_:`Submit [ Node.text "Save changes" ])
                 ]
             ]
         ]))
      graph
  in
  let sheets = Bonsai.all (List.map Sheet.Side.all ~f:sheet) in
  let%arr.Bonsai sheets in
  Node.div ~attrs:[ Attr.class_ "grid grid-cols-2 gap-2" ] sheets
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Sheet"
    ~group:Overlays
    ~description:
      "Extends the Dialog component to display content that complements the main \
       content of the screen."
    ~usage:
      {|Sheet.component
  (return (fun sheet ->
     [ Sheet.trigger sheet (Button.view ~variant:Outline [ Node.text "Open" ])
     ; Sheet.content sheet
         [ Sheet.header
             [ Sheet.title sheet [ Node.text "Are you absolutely sure?" ]
             ; Sheet.description sheet [ Node.text "This action cannot be undone." ]
             ]
         ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "open_, on_open_change"
            , "bool, bool -> unit Effect.t"
            , "[Sheet.view]: controlled. [Sheet.component] keeps it ([?default_open])." )
          ; "side", "Sheet.Side.t", "[content]: the edge it slides in from ([Right])."
          ; "show_close_button", "bool", "[content]: the X in the corner (default [true])."
          ]
      ; Doc.p
          "As a dialog: the focus moves into it and stays there, Esc or a click outside \
           closes it, and the focus returns to the trigger."
      ]
    [ Doc.example ~page "Demo" demo; Doc.example ~page "Side" side ]
;;
