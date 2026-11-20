(** Moving a highlight through a list with the keyboard: arrows (wrapping),
    Home and End, and typeahead (the next item starting with a letter). *)

open! Import
open Js_of_ocaml

(** [items] are the enabled items in order, with their labels. *)
val move
  :  equal:('a -> 'a -> bool)
  -> items:('a * string) list
  -> current:'a option
  -> Dom_html.Keyboard_code.t
  -> 'a option

(** The letter or digit a key types, for typeahead. *)
val letter : Dom_html.Keyboard_code.t -> char option
