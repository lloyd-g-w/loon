open! Core

type t =
  | Home
  | Page of string
[@@deriving sexp_of, compare, equal]

let of_hash hash =
  let s = String.chop_prefix_if_exists hash ~prefix:"#" in
  let s = String.chop_prefix_if_exists s ~prefix:"/" in
  let s =
    String.take_while s ~f:(fun c -> not (Char.equal c '/' || Char.equal c '?'))
    |> String.strip
    |> String.lowercase
  in
  if String.is_empty s then Home else Page s
;;

let to_hash = function
  | Home -> "#/"
  | Page slug -> "#/" ^ slug
;;

let anchor hash =
  match String.split (String.chop_prefix_if_exists hash ~prefix:"#/") ~on:'/' with
  | _ :: anchor :: _ when not (String.is_empty anchor) -> Some anchor
  | _ -> None
;;
