open! Core
module Entry = Loon_scan.Entry

let all = Data.all

let canonical name =
  let name = String.lowercase (String.strip name) in
  let name =
    List.fold [ ".mli"; ".ml"; ".css" ] ~init:name ~f:(fun name suffix ->
      String.chop_suffix name ~suffix |> Option.value ~default:name)
  in
  String.map name ~f:(function
    | '-' | ' ' -> '_'
    | c -> c)
;;

let find_in entries name =
  let name = canonical name in
  List.find entries ~f:(fun (e : Entry.t) -> String.equal e.name name)
;;

let find = find_in all

let closure ?(entries = all) names =
  let lookup name =
    match find_in entries name with
    | Some e -> e
    | None -> raise_s [%message "unknown component" (name : string)]
  in
  (* Depth-first, dependencies first; the theme's first of all. *)
  let seen = Hash_set.create (module String) in
  let order = Queue.create () in
  let rec visit (e : Entry.t) =
    if not (Hash_set.mem seen e.name)
    then (
      Hash_set.add seen e.name;
      List.iter e.deps ~f:(fun d -> visit (lookup d));
      Queue.enqueue order e)
  in
  let roots = List.map names ~f:lookup in
  if
    List.exists roots ~f:(fun e ->
      List.mem e.deps Entry.theme ~equal:String.equal)
  then Option.iter (find_in entries Entry.theme) ~f:visit;
  List.iter roots ~f:visit;
  Queue.to_list order
;;

let edit_distance a b =
  let m = String.length a
  and n = String.length b in
  let prev = Array.init (n + 1) ~f:Fn.id in
  let cur = Array.create ~len:(n + 1) 0 in
  for i = 1 to m do
    cur.(0) <- i;
    for j = 1 to n do
      let cost = if Char.equal a.[i - 1] b.[j - 1] then 0 else 1 in
      cur.(j)
      <- Int.min (Int.min (prev.(j) + 1) (cur.(j - 1) + 1)) (prev.(j - 1) + cost)
    done;
    Array.blit ~src:cur ~src_pos:0 ~dst:prev ~dst_pos:0 ~len:(n + 1)
  done;
  prev.(n)
;;

let suggest ?(entries = all) name =
  let name = canonical name in
  let limit = Int.max 2 (String.length name / 3) in
  List.filter_map entries ~f:(fun (e : Entry.t) ->
    let d = edit_distance name e.name in
    if d <= limit
    then Some (d, e.name)
    else if
      String.length name >= 3
      && (String.is_substring e.name ~substring:name
          || String.is_substring name ~substring:e.name)
    then Some (limit + 1, e.name)
    else None)
  |> List.sort ~compare:[%compare: int * string]
  |> List.map ~f:snd
  |> fun l -> List.take l 3
;;

module Css = struct
  (* The text before the first section (kept as it is), then the sections. *)
  type t =
    { preamble : string
    ; sections : (string * string) list
    }
  [@@deriving sexp_of]

  let header name = sprintf "/* loon: %s */" name

  let parse_header line =
    let line = String.strip line in
    match
      String.chop_prefix line ~prefix:"/* loon: "
      |> Option.bind ~f:(String.chop_suffix ~suffix:" */")
    with
    | Some name when (not (String.is_empty name)) && not (String.mem name ' ')
      -> Some name
    | _ -> None
  ;;

  let parse text =
    let lines = String.split_lines text in
    let rec go preamble sections current = function
      | [] ->
        let sections =
          match current with
          | None -> sections
          | Some (name, body) -> (name, body) :: sections
        in
        preamble, List.rev sections
      | line :: rest ->
        (match parse_header line, current with
         | Some name, None -> go preamble sections (Some (name, [])) rest
         | Some name, Some (prev, body) ->
           go preamble ((prev, body) :: sections) (Some (name, [])) rest
         | None, None -> go (line :: preamble) sections None rest
         | None, Some (name, body) ->
           go preamble sections (Some (name, line :: body)) rest)
    in
    let preamble, sections = go [] [] None lines in
    let join lines = String.concat ~sep:"\n" (List.rev lines) in
    { preamble = join preamble
    ; sections =
        List.map sections ~f:(fun (name, body) ->
          name, String.strip ~drop:(Char.equal '\n') (join body))
    }
  ;;

  let to_string t =
    let parts =
      (if String.is_empty (String.strip t.preamble)
       then []
       else [ String.rstrip t.preamble ])
      @ List.map t.sections ~f:(fun (name, body) -> header name ^ "\n" ^ body)
    in
    String.concat ~sep:"\n\n" parts ^ "\n"
  ;;

  let body (e : Entry.t) =
    List.map e.css ~f:(fun f -> String.strip ~drop:(Char.equal '\n') f.contents)
    |> String.concat ~sep:"\n\n"
  ;;

  let of_entries entries =
    { preamble = ""
    ; sections =
        List.filter_map entries ~f:(fun (e : Entry.t) ->
          Option.some_if (not (List.is_empty e.css)) (e.name, body e))
    }
  ;;

  let section t name = List.Assoc.find t.sections name ~equal:String.equal
  let names t = List.map t.sections ~f:fst

  let merge t entries ~overwrite =
    List.fold
      entries
      ~init:(t, String.Map.empty)
      ~f:(fun (t, report) (e : Entry.t) ->
        if List.is_empty e.css
        then t, report
        else (
          let body = body e in
          match section t e.name with
          | Some current when String.equal current body ->
            t, Map.set report ~key:e.name ~data:`Same
          | Some _ when not overwrite ->
            t, Map.set report ~key:e.name ~data:`Skipped
          | Some _ ->
            ( { t with
                sections =
                  List.map t.sections ~f:(fun (name, b) ->
                    if String.equal name e.name then name, body else name, b)
              }
            , Map.set report ~key:e.name ~data:`Replaced )
          | None ->
            let sections =
              if String.equal e.name Entry.theme
              then (e.name, body) :: t.sections
              else t.sections @ [ e.name, body ]
            in
            { t with sections }, Map.set report ~key:e.name ~data:`Added))
  ;;

  let full () =
    let theme, rest =
      List.partition_tf all ~f:(fun e -> String.equal e.name Entry.theme)
    in
    to_string (of_entries (theme @ rest))
  ;;
end

module%test _ = struct
  let file name contents = { Entry.File.name; contents }

  let entry ?(css = []) ?(deps = [ Entry.theme ]) name =
    { Entry.name
    ; kind = Component
    ; description = ""
    ; sources = [ file (name ^ ".ml") "" ]
    ; css
    ; deps
    }
  ;;

  let entries =
    [ entry "import" ~deps:[]
    ; entry
        "theme"
        ~deps:[ "import" ]
        ~css:[ file "00-tokens.css" ":root { }\n" ]
    ; entry "icon" ~deps:[ "import"; "theme" ]
    ; entry
        "button"
        ~deps:[ "icon"; "import"; "theme" ]
        ~css:[ file "button.css" ".loon-button { }\n" ]
    ; entry
        "tabs"
        ~deps:[ "button"; "dom_util"; "theme" ]
        ~css:[ file "tabs.css" ".loon-tabs { }" ]
    ; entry "dom_util" ~deps:[ "import"; "theme" ]
    ]
  ;;

  let names l = List.map l ~f:(fun (e : Entry.t) -> e.name)

  let%expect_test "closure" =
    let show l = print_s [%sexp (names (closure ~entries l) : string list)] in
    show [ "tabs" ];
    show [ "Button"; "dom-util"; "button.ml" ];
    show [ "import" ];
    [%expect
      {|
        (import theme icon button dom_util tabs)
        (import theme icon button dom_util)
        (import)
        |}];
    Expect_test_helpers_base.require_does_raise (fun () ->
      closure ~entries [ "buton" ]);
    [%expect {| ("unknown component" (name buton)) |}]
  ;;

  let%expect_test "suggest" =
    List.iter
      [ "buton"; "tab"; "Dom-utils"; "xyzzy"; "icons"; "butt" ]
      ~f:(fun n ->
        print_s [%sexp (n : string), (suggest ~entries n : string list)]);
    [%expect
      {|
        (buton (button))
        (tab (tabs))
        (Dom-utils (dom_util))
        (xyzzy ())
        (icons (icon))
        (butt (button))
        |}]
  ;;

  let%expect_test "Css: merge keeps the user's sections and edits" =
    let css = Css.of_entries (closure ~entries [ "button" ]) in
    print_string (Css.to_string css);
    [%expect
      {|
        /* loon: theme */
        :root { }

        /* loon: button */
        .loon-button { }
        |}];
    let edited =
      Css.parse
        ("/* my tweaks first */\n"
         ^ String.substr_replace_all
             (Css.to_string css)
             ~pattern:".loon-button { }"
             ~with_:".loon-button { color: red }")
    in
    let show ~overwrite =
      let merged, report =
        Css.merge edited (closure ~entries [ "tabs" ]) ~overwrite
      in
      print_string (Css.to_string merged);
      print_s
        [%sexp
          (report : [ `Added | `Replaced | `Skipped | `Same ] String.Map.t)]
    in
    show ~overwrite:false;
    [%expect
      {|
        /* my tweaks first */

        /* loon: theme */
        :root { }

        /* loon: button */
        .loon-button { color: red }

        /* loon: tabs */
        .loon-tabs { }
        ((button Skipped) (tabs Added) (theme Same))
        |}];
    show ~overwrite:true;
    [%expect
      {|
        /* my tweaks first */

        /* loon: theme */
        :root { }

        /* loon: button */
        .loon-button { }

        /* loon: tabs */
        .loon-tabs { }
        ((button Replaced) (tabs Added) (theme Same))
        |}]
  ;;

  let%expect_test "the real registry" =
    let theme = Option.value_exn (find "theme") in
    print_s [%sexp (List.map theme.css ~f:(fun f -> f.name) : string list)];
    [%expect {|
      (00-tailwind.css 01-tw-animate.css 02-shadcn.css 03-theme.css)
      |}];
    (* Every dependency is an entry. *)
    List.iter all ~f:(fun e ->
      List.iter e.deps ~f:(fun d ->
        if Option.is_none (find d) then print_s [%message "missing" e.name d]));
    let closure = names (closure [ "button" ]) in
    print_s [%sexp (List.take closure 2 : string list)];
    [%expect {| (import theme) |}];
    print_s [%sexp (List.last closure : string option)];
    [%expect {| (button) |}]
  ;;
end
