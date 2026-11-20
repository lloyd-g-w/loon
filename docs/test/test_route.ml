open! Core
module Route = Loon_docs.Route

let%expect_test "of_hash" =
  List.iter
    [ ""; "#"; "#/"; "#/button"; "#button"; "#/theming/variables"; "#/tabs?x=1"; "#//" ]
    ~f:(fun h -> print_s [%message h (Route.of_hash h : Route.t)]);
  [%expect
    {|
    ("" ("Route.of_hash h" Home))
    (# ("Route.of_hash h" Home))
    (#/ ("Route.of_hash h" Home))
    (#/button ("Route.of_hash h" (Page button)))
    (#button ("Route.of_hash h" (Page button)))
    (#/theming/variables ("Route.of_hash h" (Page theming)))
    (#/tabs?x=1 ("Route.of_hash h" (Page tabs)))
    (#// ("Route.of_hash h" Home))
    |}]
;;

let%expect_test "round trip" =
  List.iter [ Route.Home; Page "button"; Page "data-table" ] ~f:(fun r ->
    let h = Route.to_hash r in
    print_s
      [%message
        h (Route.slug r) ~round_trips:(Route.equal r (Route.of_hash h) : bool)]);
  [%expect
    {|
    (#/ introduction (round_trips true))
    (#/button button (round_trips true))
    (#/data-table data-table (round_trips true))
    |}]
;;
