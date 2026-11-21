open! Core
open Bonsai_web
module Node = Vdom.Node
module Attr = Vdom.Attr

let title = "The Foundation for your Design System"

let description =
  "A set of beautifully designed components that you can customize, extend, and build \
   on. shadcn/ui, ported to Bonsai on OxCaml. Open Source. Open Code."
;;

(* shadcn's Announcement. *)
let announcement =
  Loon.Badge.link
    ~variant:Secondary
    ~class_:"bg-muted"
    ~href:"#/introduction"
    [ Node.text "shadcn/ui, ported to OxCaml"; Loon.Icon.view Arrow_right ]
;;

let view (local_ graph) =
  let cards = Home_cards.view graph in
  Bonsai.map cards ~f:(fun cards ->
    Node.div
      ~attrs:[ Attr.class_ "flex flex-1 flex-col"; Attr.create "data-page" "home" ]
      [ Site.page_header
          ~class_:"md:**:[.container]:pb-8 lg:**:[.container]:pb-12"
          ~before:[ announcement ]
          ~title
          ~description:[ Node.text description ]
          ~actions:
            [ Loon.Button.link
                ~class_:"h-[35px]"
                ~href:"#/installation"
                [ Node.text "Get Started" ]
            ; Loon.Button.link
                ~variant:Secondary
                ~href:"#/components"
                [ Node.text "View Components" ]
            ]
          ()
      ; Node.div
          ~attrs:[ Attr.class_ "container-wrapper flex-1 p-0" ]
          [ Node.div
              ~attrs:[ Attr.class_ "container overflow-hidden md:px-0 lg:max-w-none" ]
              [ Node.section ~attrs:[ Attr.class_ "md:block" ] [ cards ] ]
          ]
      ])
;;
