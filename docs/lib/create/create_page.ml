open! Core
open Bonsai_web
open Bonsai.Let_syntax

let component ~mode:_ ~set_mode:_ ~query ~set_query:_ (local_ _graph) =
  let%arr query in
  Vdom.Node.div
    ~attrs:[ Vdom.Attr.create "data-tool" "create" ]
    [ Vdom.Node.text ("Create: " ^ query) ]
;;
