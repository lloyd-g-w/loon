(** Where the docs are: the home page, or a page by its slug, in the URL's
    hash ([#/button]); [#/button/usage] is the heading [usage] on it. *)

open! Core

type t =
  | Home
  | Page of string
[@@deriving sexp_of, compare, equal]

(** [""], ["#"] and ["#/"] are [Home]; ["#/button"] (or ["#button"]) is
    [Page "button"]. Anything after a second slash or a [?] is ignored. *)
val of_hash : string -> t

val to_hash : t -> string

(** The heading a hash points at: ["#/theming/variables"] is
    [Some "variables"]. *)
val anchor : string -> string option
