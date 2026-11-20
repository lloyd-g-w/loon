(** A bar showing how far along a task is, or that it is under way when
    that is unknown ([value] absent). *)

open! Import

module Tone : sig
  type t =
    | Primary
    | Accent
    | Success
    | Warning
    | Danger
  [@@deriving enumerate, sexp_of, compare, equal]
end

module Size : sig
  type t =
    | Sm
    | Md
    | Lg
  [@@deriving enumerate, sexp_of, compare, equal]
end

(** [value] out of [max] (default 100), clamped. [label] names it for screen
    readers. *)
val view
  :  ?attrs:Attr.t list
  -> ?tone:Tone.t
  -> ?size:Size.t
  -> ?max:float
  -> ?label:string
  -> ?value:float
  -> unit
  -> Node.t
