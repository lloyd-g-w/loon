open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let handle sexp_of component =
  Render.handle (fun graph ->
    Bonsai_web.Bonsai.map (component graph) ~f:(fun (c : _ Control.t) ->
      Node.div
        [ Node.span [ Node.text ("value: " ^ Sexp.to_string (sexp_of c.value)) ]
        ; c.view
        ]))
;;
