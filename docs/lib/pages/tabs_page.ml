open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node

let page = "tabs"

(*$ Segmented *)
let segmented (local_ graph) =
  Tabs.component
    (Bonsai.return
       [ Tabs.Tab.create ~id:"account" ~label:"Account"
           (Card.view ~title:"Account" ~description:"Make changes to your account here." [])
       ; Tabs.Tab.create ~id:"password" ~label:"Password"
           (Card.view ~title:"Password" ~description:"Change your password here." [])
       ; Tabs.Tab.create ~disabled:true ~id:"billing" ~label:"Billing" Node.none
       ])
    graph
(*$*)

(*$ Underline *)
let underline (local_ graph) =
  Tabs.component
    ~variant:Underline
    (Bonsai.return
       [ Tabs.Tab.create ~id:"overview" ~label:"Overview" (Node.p [ Node.text "Overview" ])
       ; Tabs.Tab.create ~id:"activity" ~label:"Activity" (Node.p [ Node.text "Activity" ])
       ; Tabs.Tab.create ~id:"settings" ~label:"Settings" (Node.p [ Node.text "Settings" ])
       ])
    graph
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Tabs"
    ~group:Navigation
    ~description:"Layered panels of content, shown one at a time."
    [ Doc.example ~page "Segmented" segmented; Doc.example ~page "Underline" underline ]
;;
