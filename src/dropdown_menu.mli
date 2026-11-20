(** A menu of actions opened from a button: items with icons and keyboard
    shortcuts, labels, separators, checkbox and radio items. Arrow keys,
    Home/End and typeahead move through it; Enter or Space chooses; Esc
    closes it (WAI-ARIA menu button). *)

open! Import

module Item : sig
  type t

  (** Runs [on_select] and closes the menu. *)
  val action
    :  ?icon:Icon.t
    -> ?shortcut:string
    -> ?disabled:bool
    -> ?danger:bool
    -> on_select:unit Effect.t
    -> string
    -> t

  (** A check mark that toggles; the menu stays open. *)
  val checkbox
    :  ?disabled:bool
    -> checked:bool
    -> on_change:(bool -> unit Effect.t)
    -> string
    -> t

  (** One of a set of choices (a dot marks the [selected] one); the menu
      stays open. *)
  val radio
    :  ?disabled:bool
    -> selected:bool
    -> on_select:unit Effect.t
    -> string
    -> t

  (** A heading for the items after it. *)
  val label : string -> t

  val separator : t
end

module State : sig
  (** Closed, or open with the index (among all the items) of the
      highlighted one. *)
  type t =
    | Closed
    | Open of { highlighted : int option }
  [@@deriving sexp_of, equal]
end

(** Controlled. [trigger attrs] is the button opening it, given the
    attributes that make it one. [id] must be unique on the page. *)
val view
  :  ?attrs:Attr.t list
  -> ?side:Floating.Side.t
  -> ?align:Floating.Align.t
  -> id:string
  -> state:State.t
  -> on_change:(State.t -> unit Effect.t)
  -> trigger:(Attr.t list -> Node.t)
  -> Item.t list
  -> Node.t

(** Keeps whether it is open and the highlighted item. *)
val component
  :  ?attrs:Attr.t list
  -> ?side:Floating.Side.t
  -> ?align:Floating.Align.t
  -> trigger:(Attr.t list -> Node.t)
  -> Item.t list Bonsai.t
  -> local_ Bonsai.graph
  -> Node.t Bonsai.t
