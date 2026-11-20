open! Core
open Bonsai_web
module Node = Vdom.Node
module Attr = Vdom.Attr

module Group = struct
  type t =
    | Guide
    | Forms
    | Overlays
    | Display
    | Navigation
    | Feedback
  [@@deriving enumerate, sexp_of, compare, equal]

  let title = function
    | Guide -> "Getting started"
    | Forms -> "Forms"
    | Overlays -> "Overlays"
    | Display -> "Display"
    | Navigation -> "Navigation"
    | Feedback -> "Feedback"
  ;;
end

module Example = struct
  type t =
    { title : string
    ; source : string
    ; view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
    }
end

module Page = struct
  type t =
    { slug : string
    ; title : string
    ; group : Group.t
    ; description : string
    ; usage : string option
    ; body : Vdom.Node.t list
    ; examples : Example.t list
    }
end

let example ~page title view =
  let source =
    match Example_sources.find ~page ~title with
    | Some source -> source
    | None -> raise_s [%message "no source for example" page title]
  in
  { Example.title; source; view }
;;

let static ~page title node = example ~page title (fun _ -> Bonsai.return node)

let page ?usage ?(body = []) ~slug ~title ~group ~description examples =
  { Page.slug; title; group; description; usage; body; examples }
;;

let h2 text = Node.h2 ~attrs:[ Attr.class_ "docs-h2" ] [ Node.text text ]
let p text = Node.p ~attrs:[ Attr.class_ "docs-p" ] [ Node.text text ]
let code text = Node.code ~attrs:[ Attr.class_ "docs-code-inline" ] [ Node.text text ]

let props rows =
  Node.div
    ~attrs:[ Attr.class_ "docs-props" ]
    [ Node.table
        [ Node.thead
            [ Node.tr
                [ Node.th [ Node.text "Argument" ]
                ; Node.th [ Node.text "Type" ]
                ; Node.th [ Node.text "Description" ]
                ]
            ]
        ; Node.tbody
            (List.map rows ~f:(fun (name, type_, description) ->
               Node.tr
                 [ Node.td [ code name ]
                 ; Node.td [ Node.code [ Node.text type_ ] ]
                 ; Node.td [ Node.text description ]
                 ]))
        ]
    ]
;;
