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
    ; description : string option
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
    ; order : int
    }
end

let example ~page title view =
  let source =
    match Example_sources.find ~page ~title with
    | Some source -> source
    | None -> raise_s [%message "no source for example" page title]
  in
  { Example.title
  ; description = Example_sources.description ~page ~title
  ; source
  ; view
  }
;;

let static ~page title node = example ~page title (fun _ -> Bonsai.return node)

let page ?(order = 100) ?usage ?(body = []) ~slug ~title ~group ~description examples =
  { Page.slug; title; group; description; usage; body; examples; order }
;;

let anchor text =
  String.lowercase text
  |> String.map ~f:(fun c -> if Char.is_alphanum c then c else ' ')
  |> String.split ~on:' '
  |> List.filter ~f:(fun s -> not (String.is_empty s))
  |> String.concat ~sep:"-"
;;

let h2 text =
  Node.h2
    ~attrs:
      [ Attr.class_ "docs-h2"
      ; Attr.id (anchor text)
      ; Attr.create "data-outline" text
      ]
    [ Node.text text ]
;;

let h3 text = Node.h3 ~attrs:[ Attr.class_ "docs-h3" ] [ Node.text text ]
let p text = Node.p ~attrs:[ Attr.class_ "docs-p" ] [ Node.text text ]
let p' nodes = Node.p ~attrs:[ Attr.class_ "docs-p" ] nodes
let text = Node.text
let code text = Node.code ~attrs:[ Attr.class_ "docs-code-inline" ] [ Node.text text ]

let link ~href text =
  let external_ = String.is_prefix href ~prefix:"http" in
  Node.a
    ~attrs:
      ([ Attr.href href; Attr.class_ "docs-link" ]
       @ if external_ then [ Attr.create "target" "_blank"; Attr.create "rel" "noopener" ] else [])
    [ Node.text text ]
;;

let ul items =
  Node.ul ~attrs:[ Attr.class_ "docs-ul" ] (List.map items ~f:(fun item -> Node.li item))
;;

let pre ?lang source = Code_block.view ?lang source

let note ?(tone = "info") ?title children =
  Node.div
    ~attrs:[ Attr.classes [ "docs-note"; "docs-note-" ^ tone ] ]
    ((match title with
      | None -> []
      | Some title -> [ Node.div ~attrs:[ Attr.class_ "docs-note-title" ] [ Node.text title ] ])
     @ [ Node.div ~attrs:[ Attr.class_ "docs-note-body" ] children ])
;;

let table head rows =
  Node.div
    ~attrs:[ Attr.class_ "docs-props" ]
    [ Node.table
        [ Node.thead [ Node.tr (List.map head ~f:(fun h -> Node.th [ Node.text h ])) ]
        ; Node.tbody (List.map rows ~f:(fun cells -> Node.tr (List.map cells ~f:(fun c -> Node.td [ c ]))))
        ]
    ]
;;

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
                 ; Node.td [ Highlight.view type_ ]
                 ; Node.td [ Node.text description ]
                 ]))
        ]
    ]
;;
