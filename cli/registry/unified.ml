open! Core
module Hunk = Patience_diff_lib.Patience_diff.Hunk
module Range = Patience_diff_lib.Patience_diff.Range

let lines s = Array.of_list (String.split_lines s)

let diff ?(color = false) ~prev_name ~next_name ~prev ~next () =
  if String.equal prev next
  then None
  else (
    let paint code s =
      if color then sprintf "\027[%sm%s\027[0m" code s else s
    in
    let hunks =
      Patience_diff_lib.Patience_diff.String.get_hunks
        ~transform:Fn.id
        ~context:3
        ~prev:(lines prev)
        ~next:(lines next)
        ()
    in
    let buf = Buffer.create 1024 in
    let line s =
      Buffer.add_string buf s;
      Buffer.add_char buf '\n'
    in
    line (paint "1" ("--- " ^ prev_name));
    line (paint "1" ("+++ " ^ next_name));
    List.iter hunks ~f:(fun (h : string Hunk.t) ->
      if not (Hunk.all_same h)
      then (
        (* An empty side starts at the line before, as diff -u has it. *)
        let range start size =
          let start = if size = 0 then start - 1 else start in
          if size = 1 then Int.to_string start else sprintf "%d,%d" start size
        in
        line
          (paint
             "36"
             (sprintf
                "@@ -%s +%s @@"
                (range h.prev_start h.prev_size)
                (range h.next_start h.next_size)));
        List.iter h.ranges ~f:(fun (r : string Range.t) ->
          let removed = Array.iter ~f:(fun l -> line (paint "31" ("-" ^ l))) in
          let added = Array.iter ~f:(fun l -> line (paint "32" ("+" ^ l))) in
          match r with
          | Same ls -> Array.iter ls ~f:(fun (l, _) -> line (" " ^ l))
          | Prev (ls, _) -> removed ls
          | Next (ls, _) -> added ls
          | Replace (p, n, _) ->
            removed p;
            added n
          | Unified (ls, _) -> Array.iter ls ~f:(fun l -> line (" " ^ l)))));
    Some (Buffer.contents buf))
;;

let%expect_test "diff" =
  let prev = String.concat (List.init 10 ~f:(sprintf "%d\n")) in
  let show next =
    print_string
      (Option.value
         ~default:"(same)\n"
         (diff ~prev_name:"a" ~next_name:"b" ~prev ~next ()))
  in
  show prev;
  show (String.substr_replace_first prev ~pattern:"5\n" ~with_:"five\n" ^ "10\n");
  show ("start\n" ^ String.substr_replace_first prev ~pattern:"0\n1\n" ~with_:"");
  print_string
    (Option.value_exn
       (diff ~prev_name:"a" ~next_name:"b" ~prev:"" ~next:"new\n" ()));
  [%expect
    {|
    (same)
    --- a
    +++ b
    @@ -3,8 +3,9 @@
     2
     3
     4
    -5
    +five
     6
     7
     8
     9
    +10
    --- a
    +++ b
    @@ -1,5 +1,4 @@
    -0
    -1
    +start
     2
     3
     4
    --- a
    +++ b
    @@ -0,0 +1 @@
    +new
    |}]
;;
