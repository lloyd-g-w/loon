(** A thin line between groups of content, optionally with a label in it
    ("or"). Decorative unless [semantic]. *)

open! Import

module Orientation : sig
  type t =
    | Horizontal
    | Vertical
  [@@deriving enumerate, sexp_of, compare, equal]
end

val view
  :  ?attrs:Attr.t list
  -> ?orientation:Orientation.t
  -> ?semantic:bool
  -> ?label:string
  -> unit
  -> Node.t
