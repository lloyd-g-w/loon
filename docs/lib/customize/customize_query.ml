open! Core

let of_hash hash =
  match String.lsplit2 hash ~on:'?' with
  | None -> ""
  | Some (_, q) -> q
;;

let to_hash ~slug query =
  if String.is_empty query then "#/" ^ slug else sprintf "#/%s?%s" slug query
;;

let hex c =
  match c with
  | '0' .. '9' -> Some (Char.to_int c - Char.to_int '0')
  | 'a' .. 'f' -> Some (Char.to_int c - Char.to_int 'a' + 10)
  | 'A' .. 'F' -> Some (Char.to_int c - Char.to_int 'A' + 10)
  | _ -> None
;;

let decode s =
  let b = Buffer.create (String.length s) in
  let n = String.length s in
  let rec go i =
    if i < n
    then (
      match s.[i] with
      | '+' ->
        Buffer.add_char b ' ';
        go (i + 1)
      | '%' when i + 2 < n ->
        (match Option.both (hex s.[i + 1]) (hex s.[i + 2]) with
         | Some (h, l) ->
           Buffer.add_char b (Char.of_int_exn ((h * 16) + l));
           go (i + 3)
         | None ->
           Buffer.add_char b '%';
           go (i + 1))
      | c ->
        Buffer.add_char b c;
        go (i + 1))
  in
  go 0;
  Buffer.contents b
;;

let encode s =
  String.concat_map s ~f:(fun c ->
    match c with
    | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '-' | '_' | '.' | '~' -> String.of_char c
    | c -> sprintf "%%%02X" (Char.to_int c))
;;

let parse q =
  String.split q ~on:'&'
  |> List.filter_map ~f:(fun part ->
    if String.is_empty part
    then None
    else (
      match String.lsplit2 part ~on:'=' with
      | None -> Some (decode part, "")
      | Some (k, v) -> Some (decode k, decode v)))
;;

let to_string kvs =
  List.map kvs ~f:(fun (k, v) -> encode k ^ "=" ^ encode v) |> String.concat ~sep:"&"
;;

let find kvs key = List.Assoc.find kvs ~equal:String.equal key
