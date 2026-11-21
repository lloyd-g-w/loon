open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "progress"

(*$ Demo
   13%, then 66% half a second later. *)
let demo (local_ graph) =
  let progress, set_progress = Bonsai.state 13. graph in
  let sleep = Bonsai.Clock.sleep graph in
  Bonsai.Edge.lifecycle
    ~on_activate:
      (let%arr set_progress and sleep in
       let%bind.Effect () = sleep (Time_ns.Span.of_int_ms 500) in
       set_progress 66.)
    graph;
  let%arr progress in
  Progress.view ~value:progress ~class_:"w-[60%]" ()
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Progress"
    ~group:Feedback
    ~description:
      "Displays an indicator showing the completion progress of a task, typically \
       displayed as a progress bar."
    ~usage:{|Progress.view ~value:33. ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "value", "float", "How far along, out of [max]; absent: indeterminate."
          ; "max", "float", "100 by default."
          ; "class_", "string", "More Tailwind classes, merged last."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ]
    [ Doc.example ~page "Demo" demo ]
;;
