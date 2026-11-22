open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "accordion"

(*$ Demo *)
let demo (local_ graph) =
  let item acc ~value ~title text =
    Accordion.item
      acc
      ~value
      [ Accordion.trigger [ Node.text title ]; Accordion.content [ Node.text text ] ]
  in
  Accordion.component
    ~type_:Single
    ~collapsible:true
    ~class_:"max-w-lg"
    ~default_value:[ "shipping" ]
    (Bonsai.return (fun acc ->
       [ item
           acc
           ~value:"shipping"
           ~title:"What are your shipping options?"
           "We offer standard (5-7 days), express (2-3 days), and overnight \
            shipping. Free shipping on international orders."
       ; item
           acc
           ~value:"returns"
           ~title:"What is your return policy?"
           "Returns accepted within 30 days. Items must be unused and in original \
            packaging. Refunds processed within 5-7 business days."
       ; item
           acc
           ~value:"support"
           ~title:"How can I contact customer support?"
           "Reach us via email, live chat, or phone. We respond within 24 hours \
            during business days."
       ]))
    graph
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Accordion"
    ~description:
      "A vertically stacked set of interactive headings that each reveal a \
       section of content."
    ~usage:
      {|Accordion.component ~type_:Single ~collapsible:true
  (return (fun acc ->
     [ Accordion.item acc ~value:"item-1"
         [ Accordion.trigger [ Node.text "Is it accessible?" ]
         ; Accordion.content
             [ Node.text "Yes. It adheres to the WAI-ARIA design pattern." ]
         ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "type_"
            , "Accordion.Type.t"
            , "[Single]: one item open at a time; [Multiple]: any number." )
          ; ( "collapsible"
            , "bool"
            , "[Single]: pressing the open item closes it (default [false])." )
          ; ( "default_value"
            , "string list"
            , "[Accordion.component]: the items open at first. \
               [Accordion.view] takes [~value] and [~on_change] instead." )
          ; ( "disabled"
            , "bool"
            , "[Accordion.item], or every item: cannot be opened." )
          ; ( "orientation"
            , "Accordion.Orientation.t"
            , "[Vertical] (default): Up and Down move between triggers; \
               [Horizontal]: Left and Right." )
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.table
          [ "Key"; "Does" ]
          [ [ Doc.text "Space / Enter"
            ; Doc.text "Open or close the focused item."
            ]
          ; [ Doc.text "Arrow Down / Up"
            ; Doc.text "The next or previous trigger."
            ]
          ; [ Doc.text "Home / End"; Doc.text "The first or last trigger." ]
          ]
      ]
    [ Doc.example ~page "Demo" demo ]
;;
