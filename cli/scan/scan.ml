open! Core

module Token = struct
  type t =
    | Ident of string (* capitalised, maybe followed by a dot: see [dotted] *)
    | Dotted of string
    | Word of string
    | String of string
    | Other
end

(* A small OCaml lexer: enough to skip comments (nested, with strings in
   them), strings (with escapes, and quoted strings {id|...|id}) and
   character literals, and to see identifiers. *)
let tokens (s : string) =
  let n = String.length s in
  let out = Queue.create () in
  let is_ident c =
    Char.is_alphanum c || Char.equal c '_' || Char.equal c '\''
  in
  let rec skip_string i buf =
    if i >= n
    then i
    else (
      match s.[i] with
      | '"' -> i + 1
      | '\\' when i + 1 < n ->
        Buffer.add_char buf s.[i + 1];
        skip_string (i + 2) buf
      | c ->
        Buffer.add_char buf c;
        skip_string (i + 1) buf)
  in
  (* At a quoted string's opening brace: the index after its bar and the
     closing delimiter. *)
  let quoted_string_start i =
    let rec id j =
      if j < n && (Char.is_lowercase s.[j] || Char.equal s.[j] '_')
      then id (j + 1)
      else j
    in
    let j = id (i + 1) in
    if j < n && Char.equal s.[j] '|'
    then Some (j + 1, "|" ^ String.sub s ~pos:(i + 1) ~len:(j - i - 1) ^ "}")
    else None
  in
  let skip_quoted i close =
    match String.substr_index s ~pos:i ~pattern:close with
    | None -> n, String.drop_prefix s i
    | Some k -> k + String.length close, String.sub s ~pos:i ~len:(k - i)
  in
  let rec skip_comment i depth =
    if i >= n
    then i
    else if i + 1 < n && Char.equal s.[i] '(' && Char.equal s.[i + 1] '*'
    then skip_comment (i + 2) (depth + 1)
    else if i + 1 < n && Char.equal s.[i] '*' && Char.equal s.[i + 1] ')'
    then if depth = 1 then i + 2 else skip_comment (i + 2) (depth - 1)
    else if Char.equal s.[i] '"'
    then skip_comment (skip_string (i + 1) (Buffer.create 0)) depth
    else skip_comment (i + 1) depth
  in
  let rec go i =
    if i < n
    then (
      let c = s.[i] in
      if i + 1 < n && Char.equal c '(' && Char.equal s.[i + 1] '*'
      then go (skip_comment (i + 2) 1)
      else if Char.equal c '"'
      then (
        let buf = Buffer.create 16 in
        let j = skip_string (i + 1) buf in
        Queue.enqueue out (Token.String (Buffer.contents buf));
        go j)
      else if Char.equal c '{' && Option.is_some (quoted_string_start i)
      then (
        let start, close = Option.value_exn (quoted_string_start i) in
        let j, contents = skip_quoted start close in
        Queue.enqueue out (Token.String contents);
        go j)
      else if Char.equal c '\''
      then
        (* a character literal: 'x' or an escape '\n', '\'' ... *)
        if i + 2 < n && Char.equal s.[i + 1] '\\'
        then (
          match String.index_from s (i + 3) '\'' with
          | Some k -> go (k + 1)
          | None -> go n)
        else if i + 2 < n && Char.equal s.[i + 2] '\''
        then go (i + 3)
        else go (i + 1)
      else if Char.is_alpha c || Char.equal c '_'
      then (
        let j =
          let rec ident j =
            if j < n && is_ident s.[j] then ident (j + 1) else j
          in
          ident (i + 1)
        in
        let word = String.sub s ~pos:i ~len:(j - i) in
        let token : Token.t =
          if not (Char.is_uppercase c)
          then Word word
          else if j < n && Char.equal s.[j] '.'
          then Dotted word
          else Ident word
        in
        Queue.enqueue out token;
        go j)
      else if Char.is_whitespace c
      then go (i + 1)
      else (
        Queue.enqueue out Token.Other;
        go (i + 1)))
  in
  go 0;
  Queue.to_list out
;;

let module_refs source =
  (* [module X = struct] defines X here: [X.y] then means this one. *)
  let rec go acc ~local ~after_open = function
    | [] -> Set.diff acc local
    | (Token.Dotted m : Token.t) :: rest ->
      go (Set.add acc m) ~local ~after_open:false rest
    | Ident m :: rest when after_open ->
      go (Set.add acc m) ~local ~after_open:false rest
    | Word "module" :: Ident m :: rest ->
      (* [module X = Button] names Button as [open Button] does. *)
      let rest =
        match rest with
        | Other :: rest -> rest
        | rest -> rest
      in
      go acc ~local:(Set.add local m) ~after_open:true rest
    | Word ("open" | "include") :: Other :: rest ->
      (* [open!] *)
      go acc ~local ~after_open:true rest
    | Word ("open" | "include") :: rest -> go acc ~local ~after_open:true rest
    | _ :: rest -> go acc ~local ~after_open:false rest
  in
  go String.Set.empty ~local:String.Set.empty ~after_open:false (tokens source)
;;

let is_class_char c = Char.is_alphanum c || Char.equal c '-' || Char.equal c '_'

let class_literals source =
  List.fold (tokens source) ~init:String.Set.empty ~f:(fun acc -> function
    | String s ->
      String.split_on_chars s ~on:[ ' '; '\t'; '\n' ]
      |> List.filter ~f:(fun w ->
        String.is_prefix w ~prefix:"loon-" && String.for_all w ~f:is_class_char)
      |> List.fold ~init:acc ~f:Set.add
    | _ -> acc)
;;

let css_classes css =
  (* Drop comments, then take every ".loon-..." *)
  let without_comments =
    let buf = Buffer.create (String.length css) in
    let n = String.length css in
    let rec go i =
      if i < n
      then
        if i + 1 < n && Char.equal css.[i] '/' && Char.equal css.[i + 1] '*'
        then (
          match String.substr_index css ~pos:(i + 2) ~pattern:"*/" with
          | None -> ()
          | Some k -> go (k + 2))
        else (
          Buffer.add_char buf css.[i];
          go (i + 1))
    in
    go 0;
    Buffer.contents buf
  in
  let n = String.length without_comments in
  let rec go i acc =
    match String.substr_index without_comments ~pos:i ~pattern:".loon-" with
    | None -> acc
    | Some k ->
      let rec stop j =
        if j < n && is_class_char without_comments.[j] then stop (j + 1) else j
      in
      let j = stop (k + 1) in
      go
        j
        (Set.add
           acc
           (String.sub without_comments ~pos:(k + 1) ~len:(j - k - 1)))
  in
  go 0 String.Set.empty
;;

let literal_matches ~literal ~class_ =
  String.equal literal class_
  || (String.is_suffix literal ~suffix:"-"
      && String.is_prefix class_ ~prefix:literal)
;;

let description source =
  let s = String.lstrip source in
  if not (String.is_prefix s ~prefix:"(**")
  then None
  else (
    match String.substr_index s ~pattern:"*)" with
    | None -> None
    | Some k ->
      let text =
        String.sub s ~pos:3 ~len:(k - 3)
        |> String.filter ~f:(fun c ->
          not (Char.equal c '[' || Char.equal c ']'))
        |> String.split_on_chars ~on:[ ' '; '\n'; '\t' ]
        |> List.filter ~f:(Fn.non String.is_empty)
        |> String.concat ~sep:" "
      in
      let first_sentence =
        match String.substr_index text ~pattern:". " with
        | None -> text
        | Some k -> String.prefix text (k + 1)
      in
      Option.some_if (not (String.is_empty first_sentence)) first_sentence)
;;

let%expect_test "module_refs" =
  let show s = print_s [%sexp (module_refs s : String.Set.t)] in
  show
    {|open! Import
(* Tabs.view is in a comment, as is "Card.x" *)
let x = "Badge.view in a string" ^ {q|Alert.x|q}
let c = '"' and d = '\'' and e = 'a'
let y = Button.view ~variant:Outline [ Icon.view Plus ]
let z : Dom_util.t = t.Tab.id
include Theme
type 'a t = 'a Foo.t
module Command = struct type t = Create end
let w : Command.t = Command.Create
module B = Badge
module type S = sig end|};
  [%expect {| (Badge Button Dom_util Foo Icon Import Tab Theme) |}]
;;

let%expect_test "class_literals and css_classes" =
  print_s
    [%sexp
      (class_literals
         {|let c = [ "loon-button"; "loon-button-" ^ name; "not-loon"; "loon-a loon-b" ]|}
       : String.Set.t)];
  [%expect {| (loon-a loon-b loon-button loon-button-) |}];
  print_s
    [%sexp
      (css_classes
         {|/* .loon-comment */
.loon-button:hover:not(.loon-x), .loon-dark [data-a] .loon-button-sm { }|}
       : String.Set.t)];
  [%expect {| (loon-button loon-button-sm loon-dark loon-x) |}];
  print_s
    [%sexp
      (List.map
         [ "loon-button"; "loon-button-sm"; "loon-buttons" ]
         ~f:(fun class_ -> literal_matches ~literal:"loon-button-" ~class_)
       : bool list)];
  [%expect {| (false true false) |}]
;;

let%expect_test "description" =
  let show s = print_s [%sexp (description s : string option)] in
  show
    "(** Tabs: a row of triggers, one panel shown at a time. Arrow keys\n\
    \ move. *)";
  show "(** A [view] for\n    things *)\nopen! Import";
  show "open! Import\n(** later *)";
  [%expect
    {|
    ("Tabs: a row of triggers, one panel shown at a time.")
    ("A view for things")
    ()
    |}]
;;
