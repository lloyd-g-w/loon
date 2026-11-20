(** Roving focus in a group of items (radios, toggle groups): which item an
    arrow key, Home or End moves to, skipping disabled ones. *)

open! Import
open Js_of_ocaml

module Orientation : sig
  type t =
    | Horizontal
    | Vertical
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string
end

(** [move ~enabled ~current key]: the index (into the list of
    items, whose [enabled] flags are given) that [key] moves to from
    [current]; arrows wrap. Both arrow axes move in a [Horizontal] group
    and a [Vertical] one alike, as WAI-ARIA radio groups do. *)
val move
  :  enabled:bool list
  -> current:int
  -> Dom_html.Keyboard_code.t
  -> int option
