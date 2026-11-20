open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node

let page = "tooltip"

(*$ Icon buttons
   Tooltips name buttons that only show an icon. *)
let icon_buttons =
  Node.div
    ~attrs:[ Vdom.Attr.class_ "docs-row" ]
    (List.map
       [ "tip-edit", Icon.Pencil, "Edit"
       ; "tip-copy", Copy, "Copy to clipboard"
       ; "tip-delete", Trash, "Move to trash"
       ]
       ~f:(fun (id, icon, label) ->
         Tooltip.view ~id ~content:label (fun attrs ->
           Button.view
             ~attrs:(Vdom.Attr.create "aria-label" label :: attrs)
             ~variant:Outline
             ~size:Icon
             [ Icon.view icon ])))
;;

(*$*)

(*$ Sides *)
let sides =
  Node.div
    ~attrs:[ Vdom.Attr.class_ "docs-row" ]
    (List.map Floating.Side.all ~f:(fun side ->
       let name = Floating.Side.name side in
       Tooltip.view
         ~side
         ~id:("tip-side-" ^ name)
         ~content:("On the " ^ name)
         (fun attrs -> Button.view ~attrs ~variant:Secondary [ Node.text name ])))
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Tooltip"
    ~group:Overlays
    ~description:
      "A short label shown when the pointer rests on, or the keyboard focuses, \
       an element."
    ~usage:
      {|Tooltip.view ~id:"save-tip" ~content:"Save (Ctrl+S)" (fun attrs ->
  Button.view ~attrs ~size:Icon [ Icon.view Check ])|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "id"
            , "string"
            , "Unique on the page; the trigger is described by it." )
          ; "content", "string", "The label."
          ; "side", "Floating.Side.t", "Top (default), Right, Bottom or Left."
          ]
      ; Doc.p
          "Tooltips are pure CSS: they appear after a short delay on hover and \
           on keyboard focus, and never on touch screens, so do not put \
           anything only in a tooltip."
      ]
    [ Doc.static ~page "Icon buttons" icon_buttons
    ; Doc.static ~page "Sides" sides
    ]
;;
