open! Core
module Q = Loon_docs.Customize_query

let%expect_test "of_hash, to_hash" =
  List.iter [ ""; "#/create"; "#/create?preset=b0"; "#/typeset?body=inter&x" ] ~f:(fun h ->
    print_s [%message h (Q.of_hash h)]);
  print_endline (Q.to_hash ~slug:"create" "");
  print_endline (Q.to_hash ~slug:"create" "preset=b0");
  [%expect
    {|
    ("" "")
    (#/create "")
    (#/create?preset=b0 preset=b0)
    (#/typeset?body=inter&x body=inter&x)
    #/create
    #/create?preset=b0
    |}]
;;

let%expect_test "parse, to_string" =
  let kvs = Q.parse "a=1&b=two%20words+more&&c&d=%zz&e=50%" in
  print_s [%sexp (kvs : (string * string) list)];
  print_endline (Q.to_string [ "item", "preview-02"; "q", "a b&c=d/é" ]);
  print_s [%sexp (Q.parse (Q.to_string [ "q", "a b&c=d/é" ]) : (string * string) list)];
  [%expect
    {|
    ((a 1) (b "two words more") (c "") (d %zz) (e 50%))
    item=preview-02&q=a%20b%26c%3Dd%2F%C3%A9
    ((q "a b&c=d/\195\169"))
    |}]
;;
