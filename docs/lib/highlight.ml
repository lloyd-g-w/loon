open! Core
open Bonsai_web
module Node = Vdom.Node
module Attr = Vdom.Attr

module Lang = struct
  type t =
    | Ocaml
    | Dune
    | Shell
    | Css
    | Plain
  [@@deriving sexp_of, compare, equal]
end

module Kind = struct
  type t =
    | Plain
    | Keyword
    | String
    | Comment
    | Module
    | Constructor
    | Number
    | Ppx
    | Label
    | Operator
    | Punctuation
  [@@deriving sexp_of, compare, equal]

  let class_ t = "hl-" ^ String.lowercase (Sexp.to_string (sexp_of_t t))
end

let ocaml_keywords =
  String.Set.of_list
    [ "and"; "as"; "assert"; "begin"; "class"; "constraint"; "do"; "done"; "downto"
    ; "else"; "end"; "exception"; "external"; "false"; "for"; "fun"; "function"
    ; "functor"; "if"; "in"; "include"; "inherit"; "initializer"; "lazy"; "let"
    ; "match"; "method"; "module"; "mutable"; "new"; "nonrec"; "object"; "of"
    ; "open"; "private"; "rec"; "sig"; "struct"; "then"; "to"; "true"; "try"
    ; "type"; "val"; "virtual"; "when"; "while"; "with"; "local_"; "global_"
    ; "exclave_"; "mod"; "land"; "lor"; "lxor"; "lsl"; "lsr"; "asr"; "or"
    ]
;;

let is_ident_char c = Char.is_alphanum c || Char.equal c '_' || Char.equal c '\''
let is_operator_char c = String.mem "!$&*+-./:<=>?@^|~#" c

(* Each scanner returns the kind and the length of the token at [i]. *)

let scan_string s i =
  (* s.[i] = '"' *)
  let n = String.length s in
  let rec go j =
    if j >= n
    then n
    else (
      match s.[j] with
      | '\\' -> go (j + 2)
      | '"' -> j + 1
      | _ -> go (j + 1))
  in
  min n (go (i + 1)) - i
;;

(* {|...|} and {id|...|id} *)
let scan_quoted_string s i =
  let n = String.length s in
  let j = ref (i + 1) in
  while !j < n && (Char.is_lowercase s.[!j] || Char.equal s.[!j] '_') do
    incr j
  done;
  if !j < n && Char.equal s.[!j] '|'
  then (
    let id = String.sub s ~pos:(i + 1) ~len:(!j - i - 1) in
    let close = "|" ^ id ^ "}" in
    match String.substr_index s ~pattern:close ~pos:(!j + 1) with
    | Some k -> Some (k + String.length close - i)
    | None -> Some (n - i))
  else None
;;

let scan_ocaml_comment s i =
  let n = String.length s in
  let rec go j depth =
    if j >= n
    then n
    else if j + 1 < n && Char.equal s.[j] '(' && Char.equal s.[j + 1] '*'
    then go (j + 2) (depth + 1)
    else if j + 1 < n && Char.equal s.[j] '*' && Char.equal s.[j + 1] ')'
    then if depth = 1 then j + 2 else go (j + 2) (depth - 1)
    else go (j + 1) depth
  in
  go i 0 - i
;;

let scan_while s i ~f =
  let n = String.length s in
  let j = ref i in
  while !j < n && f s.[!j] do
    incr j
  done;
  !j - i
;;

let scan_number s i =
  scan_while s i ~f:(fun c -> Char.is_alphanum c || Char.equal c '_' || Char.equal c '.')
;;

let ocaml_token s i : Kind.t * int =
  let n = String.length s in
  let c = s.[i] in
  let next k = if i + k < n then Some s.[i + k] else None in
  match c with
  | '(' when Option.equal Char.equal (next 1) (Some '*')
             && not (Option.equal Char.equal (next 2) (Some ')')) ->
    Comment, scan_ocaml_comment s i
  | '"' -> String, scan_string s i
  | '{' ->
    (match scan_quoted_string s i with
     | Some len -> String, len
     | None -> Punctuation, 1)
  | '\'' ->
    (* a character literal, or a type variable *)
    if i + 2 < n && Char.equal s.[i + 2] '\'' && not (Char.equal s.[i + 1] '\\')
    then String, 3
    else if i + 3 < n && Char.equal s.[i + 1] '\\'
    then (
      match String.index_from s (i + 2) '\'' with
      | Some k when k - i <= 6 -> String, k - i + 1
      | _ -> Plain, 1)
    else Plain, 1 + scan_while s (i + 1) ~f:is_ident_char
  | '[' when Option.equal Char.equal (next 1) (Some '%')
             || Option.equal Char.equal (next 1) (Some '@') ->
    let marks = scan_while s (i + 1) ~f:(fun c -> Char.equal c '%' || Char.equal c '@') in
    let name =
      scan_while s (i + 1 + marks) ~f:(fun c -> is_ident_char c || Char.equal c '.')
    in
    Ppx, 1 + marks + name
  | '~' | '?' when i + 1 < n && Char.is_lowercase s.[i + 1] ->
    Label, 1 + scan_while s (i + 1) ~f:is_ident_char
  | c when Char.is_digit c -> Number, scan_number s i
  | c when Char.is_uppercase c ->
    let len = scan_while s i ~f:is_ident_char in
    if i + len < n && Char.equal s.[i + len] '.' then Module, len else Constructor, len
  | c when Char.is_lowercase c || Char.equal c '_' ->
    let len = scan_while s i ~f:is_ident_char in
    let word = String.sub s ~pos:i ~len in
    if i + len < n && Char.equal s.[i + len] '%'
       && Set.mem ocaml_keywords word
    then Ppx, len + 1 + scan_while s (i + len + 1) ~f:is_ident_char
    else if Set.mem ocaml_keywords word
    then Keyword, len
    else Plain, len
  | c when is_operator_char c -> Operator, scan_while s i ~f:is_operator_char
  | '(' | ')' | '[' | ']' | '}' | ';' | ',' -> Punctuation, 1
  | _ -> Plain, 1
;;

let line_comment ~marker s i =
  if String.is_substring_at s ~pos:i ~substring:marker
  then Some (scan_while s i ~f:(fun c -> not (Char.equal c '\n')))
  else None
;;

let dune_token s i : Kind.t * int =
  match line_comment ~marker:";" s i with
  | Some len -> Comment, len
  | None ->
    (match s.[i] with
     | '"' -> String, scan_string s i
     | '(' when i + 1 < String.length s && Char.is_alpha s.[i + 1] ->
       (* the head of a form: (library, (name, ... *)
       Keyword, 1 + scan_while s (i + 1) ~f:(fun c -> is_ident_char c || Char.equal c '-')
     | '(' | ')' -> Punctuation, 1
     | '%' -> Ppx, scan_while s i ~f:(fun c -> not (Char.is_whitespace c || Char.equal c ')'))
     | c when Char.is_digit c -> Number, scan_number s i
     | c when is_ident_char c || Char.equal c '-' || Char.equal c '.' ->
       Plain, scan_while s i ~f:(fun c -> is_ident_char c || String.mem "-./" c)
     | _ -> Plain, 1)
;;

let shell_token s i ~line_start : Kind.t * int =
  match line_comment ~marker:"#" s i with
  | Some len when line_start || Char.is_whitespace s.[i - 1] -> Comment, len
  | _ ->
    (match s.[i] with
     | '"' | '\'' ->
       let quote = s.[i] in
       let len =
         match String.index_from s (i + 1) quote with
         | Some k -> k - i + 1
         | None -> String.length s - i
       in
       String, len
     | '$' -> Operator, 1
     | '-' when (not line_start) && Char.is_whitespace s.[i - 1] ->
       Label, scan_while s i ~f:(fun c -> is_ident_char c || String.mem "-=" c)
     | c when line_start && (Char.is_alpha c || Char.equal c '.') ->
       Keyword, scan_while s i ~f:(fun c -> not (Char.is_whitespace c))
     | c when Char.is_whitespace c -> Plain, scan_while s i ~f:Char.is_whitespace
     | _ -> Plain, scan_while s i ~f:(fun c -> not (String.mem " \t\n\"'$#" c)) |> max 1)
;;

let css_token s i : Kind.t * int =
  let n = String.length s in
  if String.is_substring_at s ~pos:i ~substring:"/*"
  then (
    match String.substr_index s ~pattern:"*/" ~pos:(i + 2) with
    | Some k -> Comment, k + 2 - i
    | None -> Comment, n - i)
  else (
    match s.[i] with
    | '"' -> String, scan_string s i
    | '-' when i + 1 < n && Char.equal s.[i + 1] '-' ->
      Label, scan_while s i ~f:(fun c -> is_ident_char c || Char.equal c '-')
    | c when Char.is_digit c -> Number, scan_while s i ~f:(fun c -> Char.is_alphanum c || Char.equal c '.' || Char.equal c '%')
    | '.' | '#' | ':' -> Keyword, 1 + scan_while s (i + 1) ~f:(fun c -> is_ident_char c || Char.equal c '-')
    | '{' | '}' | ';' | '(' | ')' | ',' -> Punctuation, 1
    | c when is_ident_char c || Char.equal c '-' ->
      Plain, scan_while s i ~f:(fun c -> is_ident_char c || Char.equal c '-')
    | _ -> Plain, 1)
;;

let tokenize (lang : Lang.t) s =
  let n = String.length s in
  let rec go i line_start acc =
    if i >= n
    then List.rev acc
    else (
      let kind, len =
        match lang with
        | Plain -> Kind.Plain, n - i
        | Ocaml -> ocaml_token s i
        | Dune -> dune_token s i
        | Css -> css_token s i
        | Shell ->
          if Char.is_whitespace s.[i] && not (Char.equal s.[i] '\n')
          then Plain, scan_while s i ~f:(fun c -> Char.is_whitespace c && not (Char.equal c '\n'))
          else if Char.equal s.[i] '\n'
          then Plain, 1
          else shell_token s i ~line_start
      in
      let len = max 1 (min len (n - i)) in
      let text = String.sub s ~pos:i ~len in
      let line_start =
        match lang with
        | Shell -> String.is_suffix text ~suffix:"\n" || (line_start && String.for_all text ~f:Char.is_whitespace)
        | _ -> false
      in
      let acc =
        match acc with
        | (k, prev) :: rest when Kind.equal k kind -> (k, prev ^ text) :: rest
        | _ -> (kind, text) :: acc
      in
      go (i + len) line_start acc)
  in
  go 0 true []
;;

let span (kind, text) =
  match (kind : Kind.t) with
  | Plain -> Node.text text
  | kind -> Node.span ~attrs:[ Attr.class_ (Kind.class_ kind) ] [ Node.text text ]
;;

let tokens ?(lang = Lang.Ocaml) s =
  Node.span ~attrs:[ Attr.class_ "hl" ] (List.map (tokenize lang s) ~f:span)
;;

(* The tokens of each line (a token over several lines is cut at their
   ends). *)
let lines tokens =
  let finish line acc = List.rev line :: acc in
  let line, acc =
    List.fold tokens ~init:([], []) ~f:(fun (line, acc) (kind, text) ->
      match String.split text ~on:'\n' with
      | [] -> line, acc
      | first :: rest ->
        let add line t = if String.is_empty t then line else (kind, t) :: line in
        let line = add line first in
        List.fold rest ~init:(line, acc) ~f:(fun (line, acc) t ->
          add [] t, finish line acc))
  in
  List.rev (finish line acc)
;;

let lang_name : Lang.t -> string = function
  | Ocaml -> "ocaml"
  | Dune -> "dune"
  | Shell -> "bash"
  | Css -> "css"
  | Plain -> "text"
;;

let view ?(lang = Lang.Ocaml) ?(line_numbers = false) s =
  let lines = lines (tokenize lang s) in
  Node.code
    ~attrs:
      ([ Attr.class_ "hl"; Attr.create "data-language" (lang_name lang) ]
       @ if line_numbers then [ Attr.create "data-line-numbers" "" ] else [])
    (List.concat_mapi lines ~f:(fun i line ->
       let line =
         Node.span ~attrs:[ Attr.create "data-line" "" ] (List.map line ~f:span)
       in
       if i = 0 then [ line ] else [ Node.text "\n"; line ]))
;;
