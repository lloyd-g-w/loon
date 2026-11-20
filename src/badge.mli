(** A small label: a status, a count, a tag. *)

open! Import

module Variant : sig
  type t =
    | Neutral
    | Primary
    | Outline
    | Accent
    | Success
    | Warning
    | Danger
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string
end

val view : ?attrs:Attr.t list -> ?variant:Variant.t -> ?dot:bool -> Node.t list -> Node.t
