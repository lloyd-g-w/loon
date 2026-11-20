open! Core
module Node_helpers = Virtual_dom_test_helpers.Node_helpers

let html ?selector node =
  let node = Node_helpers.unsafe_convert_exn node in
  let nodes =
    match selector with
    | None -> [ node ]
    | Some selector -> Node_helpers.select node ~selector
  in
  List.iter nodes ~f:(fun node -> print_endline (Node_helpers.to_string_html node))
;;

let handle component =
  Bonsai_web_test.Handle.create (Bonsai_web_test.Result_spec.vdom Fn.id) component
;;
