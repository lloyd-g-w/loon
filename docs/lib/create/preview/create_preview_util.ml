open! Core
open Bonsai_web
open Loon
open Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

type card = local_ Bonsai.graph -> Node.t Bonsai.t

let static node (local_ _graph) = Bonsai.return node
let text = Node.text

let el tag ?(attrs = []) ?class_ children =
  let class_attr =
    match class_ with
    | None -> []
    | Some c -> [ Attr.class_ c ]
  in
  Node.create tag ~attrs:(class_attr @ attrs) children
;;

let div = el "div"
let span = el "span"
let tspan class_ s = span ~class_ [ text s ]
let icon ?class_ i = Icon.view ?class_ i

let close_button () =
  Button.view ~variant:Ghost ~size:Icon_sm ~class_:"bg-muted" [ icon X ]
;;

let empty_card ?(media_in_header = false) ~media ~title ~description ~button () =
  let media = Empty.media ~variant:Icon [ media ] in
  let header =
    Empty.header
      ((if media_in_header then [ media ] else [])
       @ [ Empty.title [ text title ]; Empty.description [ text description ] ])
  in
  Empty.root
    ~class_:"p-4"
    ((if media_in_header then [] else [ media ]) @ [ header; Empty.content [ button ] ])
;;

let default_value v = Attr.create "value" v

let select_trigger_id id = id ^ "-trigger"

let select ?class_ ?content_class ?placeholder ~id ~default_value items (local_ graph) =
  let value, set_value = Bonsai.state default_value graph in
  let state, set_state = Bonsai.state Select.State.closed graph in
  let%arr value and set_value and state and set_state in
  Select.view
    ~id
    ~value:(Some value)
    ~on_value_change:set_value
    ~state
    ~on_state_change:set_state
    (Select.trigger ?class_ ?placeholder ())
    (Select.content
       ?class_:content_class
       [ Select.group
           (List.map items ~f:(fun (value, label) -> Select.item ~value [ Node.text label ]))
       ])
;;

let slider_state default (local_ graph) =
  let value, set = Bonsai.state default graph in
  let%arr value and set in
  value, set
;;

let dropdown ?(align = Popper.Align.End) ?(group = false) ~trigger items (local_ graph) =
  Dropdown_menu.component
    (Bonsai.return (fun menu ->
       let items =
         List.map items ~f:(function
           | None -> Dropdown_menu.separator ()
           | Some s -> Dropdown_menu.item [ Node.text s ])
       in
       [ Dropdown_menu.trigger menu trigger
       ; Dropdown_menu.content
           menu
           ~align
           (if group then [ Dropdown_menu.group items ] else items)
       ]))
    graph
;;

let chart (local_ graph) = Chart.component graph
let num = sprintf "%g"
