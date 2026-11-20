(** A callout for a message the user should notice: an icon, a title and a
    description. *)

open! Import

module Variant : sig
  type t =
    | Neutral
    | Info
    | Success
    | Warning
    | Danger
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string

  (** The icon an alert of this variant shows unless given another. *)
  val icon : t -> Icon.t
end

(** [role="alert"] for [Danger] and [Warning] (announced at once),
    [role="status"] otherwise. [icon:None] hides the icon. *)
val view
  :  ?attrs:Attr.t list
  -> ?variant:Variant.t
  -> ?icon:Icon.t option
  -> ?title:string
  -> ?action:Node.t
  -> Node.t list
  -> Node.t
