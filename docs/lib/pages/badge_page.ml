open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "badge"

(*$ Demo *)
let demo =
  Node.div
    ~attrs:[ Attr.class_ "flex w-full flex-wrap justify-center gap-2" ]
    [ Badge.view [ Node.text "Badge" ]
    ; Badge.view ~variant:Secondary [ Node.text "Secondary" ]
    ; Badge.view ~variant:Destructive [ Node.text "Destructive" ]
    ; Badge.view ~variant:Outline [ Node.text "Outline" ]
    ]
(*$*)

(*$ Secondary *)
let secondary = Badge.view ~variant:Secondary [ Node.text "Secondary" ]
(*$*)

(*$ Destructive *)
let destructive = Badge.view ~variant:Destructive [ Node.text "Destructive" ]
(*$*)

(*$ Outline *)
let outline = Badge.view ~variant:Outline [ Node.text "Outline" ]
(*$*)

(*$ Link
   [Badge.link] is shadcn's [<Badge asChild><a>]. *)
let link =
  Badge.link ~href:"#/badge" [ Node.text "Link"; Icon.view Arrow_up_right ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Badge"
    ~description:"Displays a badge or a component that looks like a badge."
    ~usage:{|Badge.view ~variant:Outline [ Node.text "Badge" ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "variant"
            , "Badge.Variant.t"
            , "[Default], [Secondary], [Destructive], [Outline], [Ghost] or [Link]." )
          ; "class_", "string", "More Tailwind classes, merged last."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ]
    [ Doc.static ~page "Demo" demo
    ; Doc.static ~page "Secondary" secondary
    ; Doc.static ~page "Destructive" destructive
    ; Doc.static ~page "Outline" outline
    ; Doc.static ~page "Link" link
    ]
;;
