open! Core
module Node = Virtual_dom.Vdom.Node

let handle ?(classes = false) sexp_of component =
  Render.handle ~classes (fun (local_ graph) ->
    Bonsai_web.Bonsai.map (component graph) ~f:(fun (c : _ Loon.Control.t) ->
      Node.div
        [ c.view
        ; Node.create "output" [ Node.text (Sexp.to_string (sexp_of c.value)) ]
        ]))
;;
