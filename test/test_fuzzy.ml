open! Core
open Loon

let%expect_test "fuzzy scores: in order, word starts and runs first" =
  let texts =
    [ "Settings"
    ; "Search files"
    ; "Send feedback"
    ; "Sign out"
    ; "Open recent"
    ; "Inbox"
    ]
  in
  List.iter [ ""; "se"; "sf"; "set"; "xyz"; "o r"; "in" ] ~f:(fun query ->
    let ranked =
      List.filter_map texts ~f:(fun t ->
        Fuzzy.score ~query t |> Option.map ~f:(fun s -> s, t))
      |> List.sort ~compare:(fun (a, _) (b, _) -> Int.compare b a)
      |> List.map ~f:snd
    in
    print_s [%message query (ranked : string list)]);
  [%expect
    {|
    (""
     (ranked
      (Settings "Search files" "Send feedback" "Sign out" "Open recent" Inbox)))
    (se (ranked (Settings "Search files" "Send feedback")))
    (sf (ranked ("Search files" "Send feedback")))
    (set (ranked (Settings)))
    (xyz (ranked ()))
    ("o r" (ranked ("Open recent")))
    (in (ranked (Inbox Settings "Sign out")))
    |}]
;;

let%expect_test "list navigation wraps, jumps and types ahead" =
  let items = [ 0, "Apple"; 1, "Banana"; 2, "Blueberry"; 3, "Cherry" ] in
  let move current key = List_nav.move ~equal:Int.equal ~items ~current key in
  print_s
    [%message
      ""
        ~down_from_none:(move None ArrowDown : int option)
        ~up_from_none:(move None ArrowUp : int option)
        ~down_from_last:(move (Some 3) ArrowDown : int option)
        ~up_from_first:(move (Some 0) ArrowUp : int option)
        ~end_:(move (Some 0) End : int option)
        ~home:(move (Some 2) Home : int option)
        ~b_from_apple:(move (Some 0) KeyB : int option)
        ~b_from_banana:(move (Some 1) KeyB : int option)
        ~b_from_blueberry:(move (Some 2) KeyB : int option)
        ~z:(move (Some 0) KeyZ : int option)
        ~shift:(move (Some 0) ShiftLeft : int option)];
  [%expect
    {|
    ((down_from_none (0)) (up_from_none (3)) (down_from_last (0))
     (up_from_first (3)) (end_ (3)) (home (0)) (b_from_apple (1))
     (b_from_banana (2)) (b_from_blueberry (1)) (z ()) (shift ()))
    |}]
;;
