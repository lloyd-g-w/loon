open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "pagination"

(*$ Demo *)
let demo =
  Pagination.root
    [ Pagination.content
        [ Pagination.item [ Pagination.previous ~href:"#/pagination" () ]
        ; Pagination.item
            [ Pagination.link ~href:"#/pagination" [ Node.text "1" ] ]
        ; Pagination.item
            [ Pagination.link
                ~href:"#/pagination"
                ~is_active:true
                [ Node.text "2" ]
            ]
        ; Pagination.item
            [ Pagination.link ~href:"#/pagination" [ Node.text "3" ] ]
        ; Pagination.item [ Pagination.ellipsis () ]
        ; Pagination.item [ Pagination.next ~href:"#/pagination" () ]
        ]
    ]
;;

(*$*)

(*$ With state
   [Pagination.entries] picks the page numbers to show around the current
   one; [on_click] changes page without following the link. *)
let with_state (local_ graph) =
  let current, set_current = Bonsai.state 5 graph in
  let%arr current
  and set_current in
  let pages = 20 in
  let go p = set_current (Int.clamp_exn p ~min:1 ~max:pages) in
  Pagination.root
    [ Pagination.content
        ([ Pagination.item
             [ Pagination.previous ~href:"#" ~on_click:(go (current - 1)) () ]
         ]
         @ List.map (Pagination.entries ~page:current ~pages ()) ~f:(function
           | Ellipsis -> Pagination.item [ Pagination.ellipsis () ]
           | Page p ->
             Pagination.item
               [ Pagination.link
                   ~href:"#"
                   ~is_active:(p = current)
                   ~on_click:(go p)
                   [ Node.text (Int.to_string p) ]
               ])
         @ [ Pagination.item
               [ Pagination.next ~href:"#" ~on_click:(go (current + 1)) () ]
           ])
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Pagination"
    ~group:Navigation
    ~description:"Pagination with page navigation, next and previous links."
    ~usage:
      {|Pagination.root
  [ Pagination.content
      [ Pagination.item [ Pagination.previous ~href:"#" () ]
      ; Pagination.item [ Pagination.link ~href:"#" [ Node.text "1" ] ]
      ; Pagination.item [ Pagination.ellipsis () ]
      ; Pagination.item [ Pagination.next ~href:"#" () ]
      ]
  ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "is_active"
            , "bool"
            , "[Pagination.link]: the current page (outlined, \
               [aria-current=\"page\"])." )
          ; "size", "Button.Size.t", "[Pagination.link]: [Icon] by default."
          ; "href", "string", "Where the link goes."
          ; ( "on_click"
            , "unit Effect.t"
            , "Runs instead of following [href] (for pages kept in state)." )
          ]
      ]
    [ Doc.static ~page "Demo" demo; Doc.example ~page "With state" with_state ]
;;
