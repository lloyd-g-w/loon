open! Core
open Loon

let show search values =
  List.map values ~f:(fun v -> v, Command_score.score v ~search)
  |> List.sort ~compare:(fun (_, a) (_, b) -> Float.compare b a)
  |> List.iter ~f:(fun (v, s) -> printf "%.4f %s\n" s v)
;;

let%expect_test "ranking" =
  show
    "se"
    [ "Search Emoji"
    ; "Settings"
    ; "Calendar"
    ; "Profile"
    ; "Billing"
    ; "Use settings"
    ];
  [%expect
    {|
    0.9899 Search Emoji
    0.9899 Settings
    0.8910 Use settings
    0.0000 Calendar
    0.0000 Profile
    0.0000 Billing
    |}];
  show "ab" [ "ab"; "abc"; "a b"; "xab"; "axb"; "ba"; "AB" ];
  [%expect
    {|
    1.0000 ab
    0.9998 AB
    0.9900 abc
    0.9000 a b
    0.1700 xab
    0.1698 axb
    0.1000 ba
    |}];
  printf
    "%.4f\n"
    (Command_score.score ~keywords:[ "Next.js" ] "next.js" ~search:"Next");
  [%expect {| 0.9899 |}]
;;
