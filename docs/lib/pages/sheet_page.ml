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
  let lorem =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod \
     tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, \
     quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo \
     consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse \
     cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non \
     proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
  in
  let sheet (side : Sheet.Side.t) =
    Sheet.component
      (Bonsai.return (fun sheet ->
         [ Sheet.trigger
             sheet
             (Button.view
                ~variant:Outline
                ~class_:"capitalize"
                [ Node.text (Sheet.Side.name side) ])
         ; Sheet.content
             sheet
             ~side
             ~class_:"data-[side=bottom]:max-h-[50vh] data-[side=top]:max-h-[50vh]"
             [ Sheet.header
                 [ Sheet.title sheet [ Node.text "Edit profile" ]
                 ; Sheet.description
                     sheet
                     [ Node.text
                         "Make changes to your profile here. Click save when you're done."
                     ]
                 ]
             ; Node.div
                 ~attrs:[ Attr.class_ "no-scrollbar overflow-y-auto px-4" ]
                 (List.init 10 ~f:(fun _ ->
                    Node.p ~attrs:[ Attr.class_ "mb-2 leading-relaxed" ] [ Node.text lorem ]))
             ; Sheet.footer
                 [ Button.view ~type_:`Submit [ Node.text "Save changes" ]
                 ; Sheet.close sheet (Button.view ~variant:Outline [ Node.text "Cancel" ])
                 ]
             ]
         ]))
      graph
  in
  let sheets =
    Bonsai.all (List.map Sheet.Side.[ Top; Right; Bottom; Left ] ~f:sheet)
  in
  let%arr.Bonsai sheets in
  Node.div ~attrs:[ Attr.class_ "flex flex-wrap gap-2" ] sheets
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Sheet"
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
