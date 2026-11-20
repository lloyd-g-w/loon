(** Where the docs are: a page, by its slug, in the URL's hash ([#/button]). *)

open! Core

type t =
  | Home
  | Page of string
[@@deriving sexp_of, compare, equal]

(** [""], ["#"] and ["#/"] are [Home]; ["#/button"] (or ["#button"]) is
    [Page "button"]. Anything after a second slash or a [?] is ignored. *)
val of_hash : string -> t

val to_hash : t -> string

(** The slug of the page shown: [Home] is the introduction. *)
val slug : t -> string

val home_slug : string
