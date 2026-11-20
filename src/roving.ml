open! Import

module Orientation = struct
  type t =
    | Horizontal
    | Vertical
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let move ~enabled ~current (key : Js_of_ocaml.Dom_html.Keyboard_code.t) =
  let n = List.length enabled in
  let enabled = Array.of_list enabled in
  let rec step i delta remaining =
    if remaining = 0
    then None
    else (
      let i = (i + delta + n) % n in
      if enabled.(i) then Some i else step i delta (remaining - 1))
  in
  let first () = step (-1) 1 n in
  let last () = step n (-1) n in
  if n = 0
  then None
  else (
    match key with
    | ArrowRight | ArrowDown -> step current 1 n
    | ArrowLeft | ArrowUp -> step current (-1) n
    | Home -> first ()
    | End -> last ()
    | _ -> None)
;;
