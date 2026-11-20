(** The theme a subtree uses: light or dark, and an accent colour. Wrap the
    app in [root] (or put [attrs] on its outermost element). *)

open! Import

module Mode : sig
  type t =
    | Light
    | Dark
  [@@deriving enumerate, sexp, compare, equal]

  val toggle : t -> t

  (** The browser's preference ([prefers-color-scheme]); [Light] where it
      cannot tell. *)
  val preferred : unit -> t
end

module Accent : sig
  type t =
    | Teal
    | Lake
    | Moss
    | Ember
    | Iris
  [@@deriving enumerate, sexp, compare, equal]

  val name : t -> string
end

val attrs : ?mode:Mode.t -> ?accent:Accent.t -> unit -> Attr.t list

val root
  :  ?attrs:Attr.t list
  -> ?mode:Mode.t
  -> ?accent:Accent.t
  -> Node.t list
  -> Node.t
