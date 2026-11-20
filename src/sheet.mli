(** A panel that slides in from an edge of the screen: navigation,
    filters, details. On phones, sheets from the left or right come up from
    the bottom instead (unless [keep_side_on_phones]). *)

open! Import

module Side : sig
  type t =
    | Left
    | Right
    | Top
    | Bottom
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string
end

(** Controlled; as {!Dialog.view}. *)
val view
  :  ?attrs:Attr.t list
  -> ?side:Side.t
  -> ?keep_side_on_phones:bool
  -> ?description:string
  -> ?footer:Node.t list
  -> ?trigger:(Attr.t list -> Node.t)
  -> id:string
  -> open_:bool
  -> on_change:(bool -> unit Effect.t)
  -> title:string
  -> Node.t list
  -> Node.t

(** Keeps whether it is open; as {!Dialog.component}. *)
val component
  :  ?attrs:Attr.t list
  -> ?side:Side.t
  -> ?keep_side_on_phones:bool
  -> ?description:string
  -> trigger:(Attr.t list -> Node.t)
  -> title:string
  -> (close:unit Effect.t -> Node.t list * Node.t list) Bonsai.t
  -> local_ Bonsai.graph
  -> Node.t Bonsai.t
