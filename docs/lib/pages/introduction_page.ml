open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "introduction"

(*$ A taste
   Components compose like any other Vdom: this card is a Card, Badges,
   Buttons and Tabs. Switch the accent and theme from the top bar. *)
let taste (local_ graph) =
  let member ~name ~email ~role ~variant =
    Node.div
      ~attrs:[ Attr.class_ "docs-member" ]
      [ Node.div
          ~attrs:[ Attr.class_ "docs-member-avatar" ]
          [ Node.text (String.prefix name 1) ]
      ; Node.div
          ~attrs:[ Attr.class_ "docs-member-who" ]
          [ Node.div ~attrs:[ Attr.class_ "docs-member-name" ] [ Node.text name ]
          ; Node.div ~attrs:[ Attr.class_ "docs-member-email" ] [ Node.text email ]
          ]
      ; Badge.view ~variant [ Node.text role ]
      ]
  in
  let team =
    Node.div
      ~attrs:[ Attr.class_ "docs-stack" ]
      [ member ~name:"Ada Lovelace" ~email:"ada@example.com" ~role:"Owner" ~variant:Accent
      ; member ~name:"Grace Hopper" ~email:"grace@example.com" ~role:"Admin" ~variant:Neutral
      ; member ~name:"Alan Turing" ~email:"alan@example.com" ~role:"Invited" ~variant:Outline
      ]
  in
  let tabs =
    Tabs.component
      (Bonsai.return
         [ Tabs.Tab.create ~id:"members" ~label:"Members" team
         ; Tabs.Tab.create
             ~id:"activity"
             ~label:"Activity"
             (Node.p
                ~attrs:[ Attr.class_ "docs-member-email" ]
                [ Node.text "Grace deployed main to production 3 minutes ago." ])
         ])
      graph
  in
  let%arr tabs in
  Card.view
    ~attrs:[ Attr.style (Css_gen.max_width (`Rem 26.)) ]
    ~title:"Your team"
    ~description:"Invite people to collaborate on this project."
    ~action:(Badge.view ~variant:Success ~dot:true [ Node.text "Live" ])
    ~footer:
      [ Button.view ~variant:Ghost [ Node.text "Cancel" ]
      ; Button.with_icon Plus "Invite"
      ]
    [ tabs ]
(*$*)

let page =
  Doc.page
    ~order:0
    ~slug:page
    ~title:"Introduction"
    ~group:Guide
    ~description:"Calm, well-made components for Bonsai_web."
    ~body:
      [ Doc.h2 "What loon is"
      ; Doc.p'
          [ Doc.text "loon is a component library for "
          ; Doc.link ~href:"https://github.com/janestreet/bonsai" "Bonsai_web"
          ; Doc.text
              ", built on OxCaml. It follows the idea that made shadcn/ui popular: \
               components are not a black box. Each one is a single, readable OCaml \
               module and a small stylesheet, so you can use loon as a library or copy \
               a component into your project and change whatever you like."
          ]
      ; Doc.ul
          [ [ Doc.text "Accessible by default: WAI-ARIA roles, keyboard support and \
                        visible focus rings." ]
          ; [ Doc.text "Themed entirely by "; Doc.code "--loon-*"
            ; Doc.text " CSS variables, with a dark mode and five accents." ]
          ; [ Doc.text "Plain Bonsai: stateless parts are functions returning "
            ; Doc.code "Vdom.Node.t"
            ; Doc.text "; stateful ones come both controlled and as Bonsai components." ]
          ; [ Doc.text "Tested: every component has expect tests, and this site is \
                        checked in Chromium, Firefox and WebKit, on desktops and phones." ]
          ]
      ; Doc.h2 "Where next"
      ; Doc.ul
          [ [ Doc.link ~href:"#/installation" "Installation"
            ; Doc.text ": add loon to a dune project, with nix." ]
          ; [ Doc.link ~href:"#/theming" "Theming"
            ; Doc.text ": colours, radius, fonts, dark mode and accents." ]
          ; [ Doc.link ~href:"#/cli" "The loon CLI"
            ; Doc.text ": copy components into your project and own them." ]
          ]
      ]
    [ Doc.example ~page "A taste" taste ]
;;
