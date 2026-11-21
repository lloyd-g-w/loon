open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "introduction"

(*$ A taste
   Components compose like any other Vdom: this card is a Card, Badges,
   Buttons and Tabs. *)
let taste (local_ graph) =
  let member ~name ~email ~role ~(variant : Badge.Variant.t) =
    Node.div
      ~attrs:[ Attr.class_ "flex items-center gap-3" ]
      [ Node.div
          ~attrs:
            [ Attr.class_
                "flex size-9 items-center justify-center rounded-full bg-muted text-sm \
                 font-medium"
            ]
          [ Node.text (String.prefix name 1) ]
      ; Node.div
          ~attrs:[ Attr.class_ "grid flex-1 gap-0.5" ]
          [ Node.div ~attrs:[ Attr.class_ "text-sm font-medium leading-none" ] [ Node.text name ]
          ; Node.div ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ] [ Node.text email ]
          ]
      ; Badge.view ~variant [ Node.text role ]
      ]
  in
  let tabs =
    Tabs.component
      ~default_value:"members"
      (Bonsai.return (fun tabs ->
         [ Tabs.list
             tabs
             [ Tabs.trigger ~value:"members" [ Node.text "Members" ]
             ; Tabs.trigger ~value:"activity" [ Node.text "Activity" ]
             ]
         ; Tabs.content
             tabs
             ~value:"members"
             ~class_:"grid gap-4 pt-2"
             [ member ~name:"Ada Lovelace" ~email:"ada@example.com" ~role:"Owner" ~variant:Default
             ; member ~name:"Grace Hopper" ~email:"grace@example.com" ~role:"Admin" ~variant:Secondary
             ; member ~name:"Alan Turing" ~email:"alan@example.com" ~role:"Invited" ~variant:Outline
             ]
         ; Tabs.content
             tabs
             ~value:"activity"
             ~class_:"pt-2"
             [ Node.p
                 ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ]
                 [ Node.text "Grace deployed main to production 3 minutes ago." ]
             ]
         ]))
      graph
  in
  let%arr tabs in
  Card.root
    ~class_:"w-full max-w-md"
    [ Card.header
        [ Card.title [ Node.text "Your team" ]
        ; Card.description [ Node.text "Invite people to collaborate on this project." ]
        ; Card.action [ Badge.view ~variant:Outline [ Node.text "Live" ] ]
        ]
    ; Card.content [ tabs ]
    ; Card.footer
        ~class_:"justify-end gap-2"
        [ Button.view ~variant:Ghost [ Node.text "Cancel" ]
        ; Button.view [ Icon.view Plus; Node.text "Invite" ]
        ]
    ]
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
