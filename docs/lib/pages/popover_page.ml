open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "popover"

(*$ Share a link
   The content is given an effect that closes the popover. *)
let share (local_ graph) =
  Popover.component
    ~trigger:(fun attrs -> Button.view ~attrs ~variant:Outline [ Node.text "Share" ])
    (Bonsai.return (fun ~close ->
       [ Popover.header
           ~description:"Anyone with the link can view this document."
           "Share link"
       ; Node.code [ Node.text "loon.dev/s/k3j9x" ]
       ; Popover.footer
           [ Button.view ~size:Sm ~variant:Ghost ~on_click:close [ Node.text "Done" ]
           ; Button.view ~size:Sm ~on_click:close [ Icon.view Copy; Node.text "Copy link" ]
           ]
       ]))
    graph
(*$*)

(*$ Sides and alignment *)
let sides (local_ graph) =
  let popover side align (local_ graph) =
    Popover.component
      ~side
      ~align
      ~trigger:(fun attrs ->
        Button.view
          ~attrs
          ~variant:Outline
          [ Node.text
              (String.capitalize (Floating.Side.name side)
               ^ ", "
               ^ Floating.Align.name align)
          ])
      (Bonsai.return (fun ~close:_ ->
         [ Popover.header
             ~description:"Placed beside its trigger by CSS alone."
             (String.capitalize (Floating.Side.name side))
         ]))
      graph
  in
  let views =
    List.map
      [ Floating.Side.Bottom, Floating.Align.Start
      ; Top, Center
      ; Right, Start
      ; Bottom, End
      ]
      ~f:(fun (side, align) -> popover side align graph)
    |> Bonsai.all
  in
  let%arr views in
  Node.div ~attrs:[ Attr.class_ "docs-row" ] views
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Popover"
    ~group:Overlays
    ~description:"Rich content in a panel that opens beside its trigger."
    ~usage:
      {|Popover.component
  ~trigger:(fun attrs -> Button.view ~attrs [ Node.text "Open" ])
  (Bonsai.return (fun ~close -> [ ... ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "trigger"
            , "Attr.t list -> Node.t"
            , "The element that opens it, given the attributes that make it a trigger \
               (ids, aria-expanded, the click handler)." )
          ; "side", "Floating.Side.t", "Bottom (default), Top, Left or Right."
          ; "align", "Floating.Align.t", "Start (default), Center or End."
          ; ( "content"
            , "(close:unit Effect.t -> Node.t list) Bonsai.t"
            , "What it shows, given an effect closing it." )
          ]
      ; Doc.p
          "Esc or a click outside closes it, and focus goes back to the trigger. \
           [Popover.view] is the controlled form, for when you keep whether it is open."
      ]
    [ Doc.example ~page "Share a link" share
    ; Doc.example ~page "Sides and alignment" sides
    ]
;;
