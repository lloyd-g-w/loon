open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let label ?class_ ~for_ text = Label.view ?class_ ~for_ [ Node.text text ]

(* shadcn's [<Input defaultValue=...>]: the initial value, as an attribute. *)
let input ?attrs ?type_ ~id value =
  Input.view ~attrs:(Attr.create "value" value :: Option.value attrs ~default:[]) ?type_ ~id ()
;;
