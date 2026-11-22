open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "drawer"
let label = Example_form.label
let input = Example_form.input

(*$ Demo *)
let demo (local_ graph) =
  let goal, set_goal = Bonsai.state 350 graph in
  let data = [ 400; 300; 200; 300; 200; 278; 189; 239; 300; 200; 278; 189; 349 ] in
  Drawer.component
    (let%arr.Bonsai goal and set_goal in
     let adjust by = set_goal (Int.max 200 (Int.min 400 (goal + by))) in
     let round_button ~disabled ~on_click icon label =
       Button.view
         ~variant:Outline
         ~size:Icon
         ~class_:"h-8 w-8 shrink-0 rounded-full"
         ~disabled
         ~on_click
         [ Icon.view icon; Node.span ~attrs:[ Attr.class_ "sr-only" ] [ Node.text label ] ]
     in
     fun drawer ->
       [ Drawer.trigger drawer (Button.view ~variant:Outline [ Node.text "Open Drawer" ])
       ; Drawer.content
           drawer
           [ Node.div
               ~attrs:[ Attr.class_ "mx-auto w-full max-w-sm" ]
               [ Drawer.header
                   [ Drawer.title drawer [ Node.text "Move Goal" ]
                   ; Drawer.description drawer [ Node.text "Set your daily activity goal." ]
                   ]
               ; Node.div
                   ~attrs:[ Attr.class_ "p-4 pb-0" ]
                   [ Node.div
                       ~attrs:[ Attr.class_ "flex items-center justify-center space-x-2" ]
                       [ round_button
                           ~disabled:(goal <= 200)
                           ~on_click:(adjust (-10))
                           Minus
                           "Decrease"
                       ; Node.div
                           ~attrs:[ Attr.class_ "flex-1 text-center" ]
                           [ Node.div
                               ~attrs:[ Attr.class_ "text-7xl font-bold tracking-tighter" ]
                               [ Node.text (Int.to_string goal) ]
                           ; Node.div
                               ~attrs:
                                 [ Attr.class_
                                     "text-[0.70rem] text-muted-foreground uppercase"
                                 ]
                               [ Node.text "Calories/day" ]
                           ]
                       ; round_button
                           ~disabled:(goal >= 400)
                           ~on_click:(adjust 10)
                           Plus
                           "Increase"
                       ]
                   ; Node.div
                       ~attrs:[ Attr.class_ "mt-3 flex h-[120px] items-end gap-1" ]
                       (List.map data ~f:(fun g ->
                          Node.div
                            ~attrs:
                              [ Attr.class_ "flex-1 bg-chart-1"
                              ; Attr.style
                                  (Css_gen.height (`Percent (Percent.of_mult (Float.of_int g /. 400.))))
                              ]
                            []))
                   ]
               ; Drawer.footer
                   [ Button.view [ Node.text "Submit" ]
                   ; Drawer.close drawer (Button.view ~variant:Outline [ Node.text "Cancel" ])
                   ]
               ]
           ]
       ])
    graph
(*$*)

(*$ Responsive dialog
   A dialog on a wide screen, a drawer on a narrow one: which, is decided
   when it opens. *)
let responsive_dialog (local_ graph) =
  let opened, set_opened = Bonsai.state_opt graph in
  let%arr.Bonsai opened and set_opened in
  let profile_form ?(class_ = "") () =
    Node.form
      ~attrs:
        [ Attr.class_ (Cn.cn [ "grid items-start gap-6"; class_ ])
        ; Attr.on_submit Dom_util.prevent_default
        ]
      [ Node.div
          ~attrs:[ Attr.class_ "grid gap-3" ]
          [ label ~for_:"email" "Email"
          ; input ~type_:Email ~id:"email" "shadcn@example.com"
          ]
      ; Node.div
          ~attrs:[ Attr.class_ "grid gap-3" ]
          [ label ~for_:"username" "Username"; input ~id:"username" "@shadcn" ]
      ; Button.view ~type_:`Submit [ Node.text "Save changes" ]
      ]
  in
  let on_open_change open_ =
    if open_
    then (
      let desktop =
        Js_of_ocaml.(
          Js.to_bool (Dom_html.window##matchMedia (Js.string "(min-width: 768px)"))##.matches)
      in
      set_opened (Some (if desktop then `Dialog else `Drawer)))
    else set_opened None
  in
  let trigger_button = Button.view ~variant:Outline [ Node.text "Edit Profile" ] in
  let description =
    "Make changes to your profile here. Click save when you're done."
  in
  match opened with
  | Some `Drawer ->
    Drawer.view ~id:"responsive-dialog" ~open_:true ~on_open_change (fun drawer ->
      [ Drawer.trigger drawer trigger_button
      ; Drawer.content
          drawer
          [ Drawer.header
              ~class_:"text-left"
              [ Drawer.title drawer [ Node.text "Edit profile" ]
              ; Drawer.description drawer [ Node.text description ]
              ]
          ; profile_form ~class_:"px-4" ()
          ; Drawer.footer
              ~class_:"pt-2"
              [ Drawer.close drawer (Button.view ~variant:Outline [ Node.text "Cancel" ]) ]
          ]
      ])
  | Some `Dialog | None ->
    Dialog.view
      ~id:"responsive-dialog"
      ~open_:(Option.is_some opened)
      ~on_open_change
      (fun dialog ->
         [ Dialog.trigger dialog trigger_button
         ; Dialog.content
             dialog
             ~class_:"sm:max-w-[425px]"
             [ Dialog.header
                 [ Dialog.title dialog [ Node.text "Edit profile" ]
                 ; Dialog.description dialog [ Node.text description ]
                 ]
             ; profile_form ()
             ]
         ])
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Drawer"
    ~description:"A drawer component for Bonsai."
    ~usage:
      {|Drawer.component
  (return (fun drawer ->
     [ Drawer.trigger drawer (Button.view ~variant:Outline [ Node.text "Open" ])
     ; Drawer.content drawer
         [ Drawer.header
             [ Drawer.title drawer [ Node.text "Are you absolutely sure?" ]
             ; Drawer.description drawer [ Node.text "This action cannot be undone." ]
             ]
         ; Drawer.footer
             [ Button.view [ Node.text "Submit" ]
             ; Drawer.close drawer (Button.view ~variant:Outline [ Node.text "Cancel" ])
             ]
         ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "open_, on_open_change"
            , "bool, bool -> unit Effect.t"
            , "[Drawer.view]: controlled. [Drawer.component] keeps it ([?default_open])." )
          ; ( "direction"
            , "Drawer.Direction.t"
            , "[view], [component]: the edge it comes from ([Bottom])." )
          ]
      ; Doc.p
          "A simplified port of vaul: a modal dialog sliding in from an edge. From the \
           bottom, it shows a handle, and dragging it (or the panel) down a quarter of \
           its height, or flicking it down, closes it; less springs back."
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Responsive dialog" responsive_dialog
    ]
;;
