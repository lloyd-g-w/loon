open! Core
open Bonsai_web
module Node = Vdom.Node
module Attr = Vdom.Attr

module Section = struct
  type t =
    | Get_started
    | Components
    | Forms
    | Blocks
    | Charts
    | Create
    | Typeset
  [@@deriving enumerate, sexp_of, compare, equal]

  let title = function
    | Get_started -> "Get Started"
    | Components -> "Components"
    | Forms -> "Forms"
    | Blocks -> "Blocks"
    | Charts -> "Charts"
    | Create -> "Create"
    | Typeset -> "Typeset"
  ;;

  let is_docs = function
    | Get_started | Components | Forms -> true
    | Blocks | Charts | Create | Typeset -> false
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
    ; section : Section.t
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

let page
      ?(order = 100)
      ?(section = Section.Components)
      ?usage
      ?(body = [])
      ~slug
      ~title
      ~description
      examples
  =
  { Page.slug; title; section; description; usage; body; examples; order }
;;

let anchor text =
  String.lowercase text
  |> String.map ~f:(fun c -> if Char.is_alphanum c then c else ' ')
  |> String.split ~on:' '
  |> List.filter ~f:(fun s -> not (String.is_empty s))
  |> String.concat ~sep:"-"
;;

let h2 text =
  let id = anchor text in
  Node.h2
    ~attrs:[ Attr.id id; Attr.create "data-outline" text ]
    [ Node.text text ]
;;

let h3 text =
  let id = anchor text in
  Node.h3 ~attrs:[ Attr.id id; Attr.create "data-outline" text ] [ Node.text text ]
;;

let text = Node.text
let code text = Node.code [ Node.text text ]

(* Splits on the outermost brackets, so [[ `A | `B ]] is one piece of code. *)
let inline s =
  let pieces = ref [] in
  let buf = Buffer.create (String.length s) in
  let flush f =
    if Buffer.length buf > 0 then pieces := f (Buffer.contents buf) :: !pieces;
    Buffer.clear buf
  in
  let depth = ref 0 in
  String.iter s ~f:(fun c ->
    match c with
    | '[' when !depth = 0 ->
      flush text;
      depth := 1
    | ']' when !depth = 1 ->
      flush code;
      depth := 0
    | '[' ->
      incr depth;
      Buffer.add_char buf c
    | ']' when !depth > 1 ->
      decr depth;
      Buffer.add_char buf c
    | c -> Buffer.add_char buf c);
  if !depth > 0 then flush (fun s -> text ("[" ^ s)) else flush text;
  List.rev !pieces
;;

let p text = Node.p (inline text)
let p' nodes = Node.p nodes

let link ~href text =
  let external_ = String.is_prefix href ~prefix:"http" in
  Node.a
    ~attrs:
      (Attr.href href
       :: (if external_
           then [ Attr.create "target" "_blank"; Attr.create "rel" "noreferrer" ]
           else []))
    [ Node.text text ]
;;

let ul items = Node.ul (List.map items ~f:(fun item -> Node.li item))
let pre ?lang source = Code_block.view ?lang source

(* shadcn's Callout. *)
let note ?(tone = "default") ?title children =
  Loon.Alert.root
    ~attrs:[ Attr.create "data-variant" tone ]
    ~class_:
      "not-typeset mt-6 w-auto rounded-2xl border-surface bg-surface \
       text-surface-foreground md:-mx-1 **:[a]:font-medium **:[a]:underline \
       **:[a]:decoration-current/30 **:[a]:hover:decoration-current **:[code]:border"
    ((match title with
      | None -> []
      | Some title -> [ Loon.Alert.title [ Node.text title ] ])
     @ [ Loon.Alert.description ~class_:"text-card-foreground/80" children ])
;;

(* shadcn's mdx table: a typeset table in a scroller. *)
let scroll_table table =
  Node.div
    ~attrs:[ Attr.class_ "typeset-scroll scroll-fade-x scrollbar-none *:[table]:w-full" ]
    [ table ]
;;

let table head rows =
  scroll_table
    (Node.table
       [ Node.thead [ Node.tr (List.map head ~f:(fun h -> Node.th [ Node.text h ])) ]
       ; Node.tbody
           (List.map rows ~f:(fun cells ->
              Node.tr (List.map cells ~f:(fun c -> Node.td [ c ]))))
       ])
;;

let props rows =
  scroll_table
    (Node.table
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
                ; Node.td [ Node.code [ Highlight.tokens type_ ] ]
                ; Node.td (inline description)
                ]))
       ])
;;

let coming_soon () =
  Loon.Empty.root
    ~attrs:[ Attr.create "data-slot" "coming-soon"; Attr.create "data-not-typeset" "" ]
    ~class_:"my-12 border border-dashed bg-background"
    [ Loon.Empty.header
        [ Loon.Empty.media ~variant:Icon [ Loon.Icon.view Square_dashed ]
        ; Loon.Empty.title [ Node.text "Coming soon" ]
        ; Loon.Empty.description
            [ Node.text "This part of loon is being ported. Check back soon." ]
        ]
    ; Loon.Empty.content
        [ Loon.Button.link
            ~variant:Outline
            ~size:Sm
            ~href:"#/components"
            [ Node.text "Browse the components" ]
        ]
    ]
;;
