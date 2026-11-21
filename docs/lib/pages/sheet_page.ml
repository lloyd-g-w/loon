open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node

let page = "sheet"

(*$ Sides
   On phones, sheets from the left or right come up from the bottom. *)
let sides (local_ graph) =
  let sheet side (local_ graph) =
    let name = String.capitalize (Sheet.Side.name side) in
    Sheet.component
      ~side
      ~title:"Filters"
      ~description:"Narrow down the results. Changes apply right away."
      ~trigger:(fun attrs -> Button.view ~attrs ~variant:Outline [ Node.text name ])
      (Bonsai.return (fun ~close ->
         ( [ Node.div
               ~attrs:[ Vdom.Attr.class_ "flex flex-col gap-3" ]
               (List.map [ "Inbox"; "Starred"; "Sent"; "Archive" ] ~f:(fun l ->
                  Node.div [ Node.text l ]))
           ]
         , [ Button.view ~variant:Outline ~on_click:close [ Node.text "Reset" ]
           ; Button.view ~on_click:close [ Node.text "Apply" ]
           ] )))
      graph
  in
  let views = Bonsai.all (List.map Sheet.Side.all ~f:(fun side -> sheet side graph)) in
  let%arr views in
  Node.div ~attrs:[ Vdom.Attr.class_ "flex flex-wrap items-center justify-center gap-3" ] views
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Sheet"
    ~description:"A panel that slides in from an edge of the screen."
    ~usage:
      {|Sheet.component
  ~side:Left
  ~title:"Navigation"
  ~trigger:(fun attrs -> Button.view ~attrs ~size:Icon [ Icon.view Menu ])
  (Bonsai.return (fun ~close -> [ nav ], []))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "side", "Sheet.Side.t", "Right (default), Left, Top or Bottom."
          ; ( "keep_side_on_phones"
            , "bool"
            , "Keep a left or right sheet at its side on narrow screens." )
          ; "title, description", "string", "As a dialog's."
          ]
      ; Doc.p "A sheet is a dialog: it keeps focus, and Esc or a click outside closes it."
      ]
    [ Doc.example ~page "Sides" sides ]
;;
