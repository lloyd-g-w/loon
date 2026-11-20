open! Core
module Search = Loon_docs.Search

let%expect_test "score" =
  List.iter
    [ "btn", "Button"
    ; "button", "Button"
    ; "but", "Button"
    ; "ton", "Button"
    ; "BUT", "button"
    ; "tg", "Toggle group"
    ; "togg grp", "Toggle group"
    ; "xyz", "Button"
    ; "", "Anything"
    ; "nottub", "Button"
    ]
    ~f:(fun (query, text) -> print_s [%message query text (Search.score ~query text : int option)]);
  [%expect
    {|
    (btn Button ("Search.score ~query text" (55)))
    (button Button ("Search.score ~query text" (229)))
    (but Button ("Search.score ~query text" (107)))
    (ton Button ("Search.score ~query text" (27)))
    (BUT button ("Search.score ~query text" (107)))
    (tg "Toggle group" ("Search.score ~query text" (57)))
    ("togg grp" "Toggle group" ("Search.score ~query text" (173)))
    (xyz Button ("Search.score ~query text" ()))
    ("" Anything ("Search.score ~query text" (-2)))
    (nottub Button ("Search.score ~query text" ()))
    |}]
;;

let pages =
  [ "Introduction", "Getting started"
  ; "Installation", "Getting started"
  ; "Theming", "Getting started"
  ; "Button", "Forms"
  ; "Toggle group", "Forms"
  ; "Tabs", "Navigation"
  ; "Table", "Data display"
  ]
;;

let rank query =
  Search.rank ~query pages ~fields:(fun (title, group) -> [ title; group ])
  |> List.map ~f:fst
  |> String.concat ~sep:", "
  |> print_endline
;;

let%expect_test "rank" =
  rank "";
  rank "tab";
  rank "ta";
  rank "forms";
  rank "intal";
  rank "zzz";
  [%expect
    {|
    Introduction, Installation, Theming, Button, Toggle group, Tabs, Table
    Tabs, Table
    Tabs, Table, Installation, Introduction, Theming
    Button, Toggle group
    Installation
    |}]
;;
