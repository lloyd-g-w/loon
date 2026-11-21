open! Core
module Node_helpers = Virtual_dom_test_helpers.Node_helpers

let filter ~classes ~key ~data:_ = classes || not (String.equal key "class")

let html ?(classes = true) ?selector node =
  let node = Node_helpers.unsafe_convert_exn node in
  let nodes =
    match selector with
    | None -> [ node ]
    | Some selector -> Node_helpers.select node ~selector
  in
  List.iter nodes ~f:(fun node ->
    print_endline
      (Node_helpers.to_string_html ~filter_printed_attributes:(filter ~classes) node))
;;

let handle ?(classes = true) component =
  Bonsai_web_test.Handle.create
    (Bonsai_web_test.Result_spec.vdom ~filter_printed_attributes:(filter ~classes) Fn.id)
    component
;;
