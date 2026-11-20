(** Buttons, and links that look like them. *)

open! Import

module Variant : sig
  type t =
    | Primary
    | Secondary
    | Outline
    | Ghost
    | Accent
    | Danger
    | Link
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string
end

module Size : sig
  type t =
    | Sm
    | Md
    | Lg
    | Icon
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string
end

(** A [<button type="button">]. [loading] shows a spinner and disables it. *)
val view
  :  ?attrs:Attr.t list
  -> ?variant:Variant.t
  -> ?size:Size.t
  -> ?disabled:bool
  -> ?loading:bool
  -> ?type_:[ `Button | `Submit | `Reset ]
  -> ?on_click:unit Effect.t
  -> Node.t list
  -> Node.t

(** A button with a leading icon. *)
val with_icon
  :  ?attrs:Attr.t list
  -> ?variant:Variant.t
  -> ?size:Size.t
  -> ?disabled:bool
  -> ?on_click:unit Effect.t
  -> Icon.t
  -> string
  -> Node.t

(** An [<a>] styled as a button. *)
val link
  :  ?attrs:Attr.t list
  -> ?variant:Variant.t
  -> ?size:Size.t
  -> href:string
  -> Node.t list
  -> Node.t

(** The classes a button of this variant and size has, for other elements
    that should look like one (e.g. a dialog's trigger). *)
val classes : ?variant:Variant.t -> ?size:Size.t -> unit -> string list
