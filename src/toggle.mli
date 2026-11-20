(** A button that stays pressed ([aria-pressed]), e.g. "bold" in a toolbar. *)

open! Import

module Variant : sig
  type t =
    | Ghost (** no border until pressed *)
    | Outline
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string
end

module Size : sig
  type t =
    | Sm
    | Md
    | Lg
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string
end

(** Controlled. Give an icon-only toggle an [aria-label] in [attrs]. *)
val view
  :  ?attrs:Attr.t list
  -> ?variant:Variant.t
  -> ?size:Size.t
  -> ?disabled:bool
  -> pressed:bool
  -> on_change:(bool -> unit Effect.t)
  -> Node.t list
  -> Node.t

val component
  :  ?attrs:Attr.t list
  -> ?variant:Variant.t
  -> ?size:Size.t
  -> ?disabled:bool
  -> ?default:bool
  -> Node.t list
  -> local_ Bonsai.graph
  -> bool Control.t Bonsai.t

(** The classes of a toggle, for the items of [Toggle_group]. *)
val classes : ?variant:Variant.t -> ?size:Size.t -> unit -> string list
