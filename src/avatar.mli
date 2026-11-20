(** A person's picture, or their initials where there is none (or it fails
    to load), and groups of them. *)

open! Import

module Size : sig
  type t =
    | Xs
    | Sm
    | Md
    | Lg
    | Xl
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string
end

module Shape : sig
  type t =
    | Circle
    | Square
  [@@deriving enumerate, sexp_of, compare, equal]
end

(** Up to two letters: the first letters of the first and last words of
    [name] ("Ada Lovelace" is "AL", "plato" is "P"). *)
val initials : string -> string

(** [name] is the image's alt text and the source of the initials. The
    initials are drawn underneath, so they show while the image loads and if
    it fails. *)
val view
  :  ?attrs:Attr.t list
  -> ?size:Size.t
  -> ?shape:Shape.t
  -> ?src:string
  -> ?status:[ `Online | `Busy | `Away | `Offline ]
  -> string
  -> Node.t

(** Overlapping avatars; past [max], the rest are counted in a "+N". *)
val group : ?attrs:Attr.t list -> ?size:Size.t -> ?max:int -> Node.t list -> Node.t
