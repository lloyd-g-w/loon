open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "accordion"

(*$ Demo *)
let demo (local_ graph) =
  let item acc ~value ~title paragraphs =
    Accordion.item
      acc
      ~value
      [ Accordion.trigger [ Node.text title ]
      ; Accordion.content
          ~class_:"flex flex-col gap-4 text-balance"
          (List.map paragraphs ~f:(fun p -> Node.p [ Node.text p ]))
      ]
  in
  Accordion.component
    ~type_:Single
    ~collapsible:true
    ~class_:"w-full"
    ~default_value:[ "item-1" ]
    (Bonsai.return (fun acc ->
       [ item
           acc
           ~value:"item-1"
           ~title:"Product Information"
           [ "Our flagship product combines cutting-edge technology with sleek \
              design. Built with premium materials, it offers unparalleled \
              performance and reliability."
           ; "Key features include advanced processing capabilities, and an \
              intuitive user interface designed for both beginners and \
              experts."
           ]
       ; item
           acc
           ~value:"item-2"
           ~title:"Shipping Details"
           [ "We offer worldwide shipping through trusted courier partners. \
              Standard delivery takes 3-5 business days, while express \
              shipping ensures delivery within 1-2 business days."
           ; "All orders are carefully packaged and fully insured. Track your \
              shipment in real-time through our dedicated tracking portal."
           ]
       ; item
           acc
           ~value:"item-3"
           ~title:"Return Policy"
           [ "We stand behind our products with a comprehensive 30-day return \
              policy. If you're not completely satisfied, simply return the \
              item in its original condition."
           ; "Our hassle-free return process includes free return shipping and \
              full refunds processed within 48 hours of receiving the returned \
              item."
           ]
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
