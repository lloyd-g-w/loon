(** Content floating next to a trigger (popovers, menus, selects): placed by
    CSS beside the trigger, over a transparent layer that dismisses it when
    clicked outside; Esc dismisses it too and returns focus to the trigger. *)

open! Import

module Side : sig
  type t =
    | Top
    | Right
    | Bottom
    | Left
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string
end

module Align : sig
  type t =
    | Start
    | Center
    | End
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string
end

(** The ids of the trigger and of the content of the floating element [id]. *)
val trigger_id : string -> string

val content_id : string -> string

(** The trigger's attributes: its id, [aria-haspopup] ([haspopup], e.g.
    ["menu"]), [aria-expanded], [aria-controls], and [on_toggle] on click. *)
val trigger_attrs
  :  id:string
  -> haspopup:string
  -> open_:bool
  -> on_toggle:unit Effect.t
  -> Attr.t list

(** [effect], then focus back on the trigger of [id]. *)
val and_refocus : id:string -> unit Effect.t -> unit Effect.t

(** Focuses the element when it is added to the page (the content of an
    overlay that just opened). *)
val focus_on_mount : Attr.t

(** The trigger, and while [open_] the content (with [content_attrs] and
    [content]); [on_dismiss] runs on a click outside or Esc. [match_width]
    makes the content at least as wide as the trigger. *)
val view
  :  ?attrs:Attr.t list
  -> ?side:Side.t
  -> ?align:Align.t
  -> ?match_width:bool
  -> ?content_attrs:Attr.t list
  -> id:string
  -> open_:bool
  -> on_dismiss:unit Effect.t
  -> trigger:Node.t
  -> Node.t list
  -> Node.t
