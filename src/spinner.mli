(** A spinning indicator that something is loading. *)

open! Import

module Size : sig
  type t =
    | Sm
    | Md
    | Lg
  [@@deriving enumerate, sexp_of, compare, equal]
end

(** [label] (default "Loading") is read by screen readers. *)
val view : ?attrs:Attr.t list -> ?size:Size.t -> ?label:string -> unit -> Node.t
