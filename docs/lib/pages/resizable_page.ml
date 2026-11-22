open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "resizable"

(*$ Demo *)
let demo (local_ graph) =
  let cell ~class_ text =
    Node.div
      ~attrs:[ Attr.class_ class_ ]
      [ Node.span ~attrs:[ Attr.class_ "font-semibold" ] [ Node.text text ] ]
  in
  let inner =
    Resizable.component
      ~orientation:Vertical
      (return
         [ Resizable.panel
             ~default_size:25.
             [ cell ~class_:"flex h-full items-center justify-center p-6" "Two"
             ]
         ; Resizable.handle ~with_handle:true ()
         ; Resizable.panel
             ~default_size:75.
             [ cell
                 ~class_:"flex h-full items-center justify-center p-6"
                 "Three"
             ]
         ])
      graph
  in
  Resizable.component
    ~orientation:Horizontal
    ~class_:"max-w-sm rounded-lg border"
    (let%arr inner in
     [ Resizable.panel
         ~default_size:50.
         [ cell ~class_:"flex h-[200px] items-center justify-center p-6" "One" ]
     ; Resizable.handle ~with_handle:true ()
     ; Resizable.panel ~default_size:50. [ inner ]
     ])
    graph
;;

(*$*)

(*$ Demo with handle *)
let demo_with_handle (local_ graph) =
  let cell ~class_ text =
    Node.div
      ~attrs:[ Attr.class_ class_ ]
      [ Node.span ~attrs:[ Attr.class_ "font-semibold" ] [ Node.text text ] ]
  in
  let inner =
    Resizable.component
      ~orientation:Vertical
      (return
         [ Resizable.panel
             ~default_size:25.
             [ cell ~class_:"flex h-full items-center justify-center p-6" "Two"
             ]
         ; Resizable.handle ~with_handle:true ()
         ; Resizable.panel
             ~default_size:75.
             [ cell
                 ~class_:"flex h-full items-center justify-center p-6"
                 "Three"
             ]
         ])
      graph
  in
  Resizable.component
    ~orientation:Horizontal
    ~class_:"max-w-md rounded-lg border md:min-w-[450px]"
    (let%arr inner in
     [ Resizable.panel
         ~default_size:50.
         [ cell ~class_:"flex h-[200px] items-center justify-center p-6" "One" ]
     ; Resizable.handle ~with_handle:true ()
     ; Resizable.panel ~default_size:50. [ inner ]
     ])
    graph
;;

(*$*)

(*$ Vertical *)
let vertical (local_ graph) =
  Resizable.component
    ~orientation:Vertical
    ~class_:"min-h-[200px] max-w-md rounded-lg border md:min-w-[450px]"
    (return
       [ Resizable.panel
           ~default_size:25.
           [ Node.div
               ~attrs:
                 [ Attr.class_ "flex h-full items-center justify-center p-6" ]
               [ Node.span
                   ~attrs:[ Attr.class_ "font-semibold" ]
                   [ Node.text "Header" ]
               ]
           ]
       ; Resizable.handle ()
       ; Resizable.panel
           ~default_size:75.
           [ Node.div
               ~attrs:
                 [ Attr.class_ "flex h-full items-center justify-center p-6" ]
               [ Node.span
                   ~attrs:[ Attr.class_ "font-semibold" ]
                   [ Node.text "Content" ]
               ]
           ]
       ])
    graph
;;

(*$*)

(*$ Handle *)
let handle (local_ graph) =
  Resizable.component
    ~orientation:Horizontal
    ~class_:"min-h-[200px] max-w-md rounded-lg border md:min-w-[450px]"
    (return
       [ Resizable.panel
           ~default_size:25.
           [ Node.div
               ~attrs:
                 [ Attr.class_ "flex h-full items-center justify-center p-6" ]
               [ Node.span
                   ~attrs:[ Attr.class_ "font-semibold" ]
                   [ Node.text "Sidebar" ]
               ]
           ]
       ; Resizable.handle ~with_handle:true ()
       ; Resizable.panel
           ~default_size:75.
           [ Node.div
               ~attrs:
                 [ Attr.class_ "flex h-full items-center justify-center p-6" ]
               [ Node.span
                   ~attrs:[ Attr.class_ "font-semibold" ]
                   [ Node.text "Content" ]
               ]
           ]
       ])
    graph
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Resizable"
    ~description:
      "Accessible resizable panel groups and layouts with keyboard support."
    ~usage:
      {|Resizable.component ~orientation:Horizontal
  (return
     [ Resizable.panel [ Node.text "One" ]
     ; Resizable.handle ()
     ; Resizable.panel [ Node.text "Two" ]
     ])
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "orientation"
            , "Resizable.Orientation.t"
            , "[Horizontal] (side by side) or [Vertical] (stacked)." )
          ; ( "default_size"
            , "float"
            , "[panel]: its size at first, a percentage of the group (by \
               default, an equal share of what the others leave)." )
          ; ( "min_size / max_size"
            , "float"
            , "[panel]: its limits (0 and 100 by default)." )
          ; "with_handle", "bool", "[handle]: show a grip."
          ; "disabled", "bool", "[handle]: cannot be moved."
          ; ( "layout"
            , "float list"
            , "[Resizable.view]: the panels' sizes, with [~on_layout_change]; \
               [Resizable.component] keeps them." )
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.table
          [ "Key"; "Does" ]
          [ [ Doc.text "Arrow keys"; Doc.text "Move the focused handle by 5%." ]
          ; [ Doc.text "Home / End"
            ; Doc.text
                "Shrink or grow the panel before the handle as far as it goes."
            ]
          ; [ Doc.text "F6"
            ; Doc.text "Focus the group's next handle (Shift: previous)."
            ]
          ]
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Demo with handle" demo_with_handle
    ; Doc.example ~page "Vertical" vertical
    ; Doc.example ~page "Handle" handle
    ]
;;
