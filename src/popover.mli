(** Rich content in a panel next to its trigger: a form, details, a
    picker. Dismissed by a click outside or Esc. *)

open! Import

(** Controlled. [trigger attrs] is the element that opens it, given the
    attributes that make it one (e.g. [fun attrs -> Button.view ~attrs ...]).
    [id] must be unique on the page. *)
val view
  :  ?attrs:Attr.t list
  -> ?side:Floating.Side.t
  -> ?align:Floating.Align.t
  -> id:string
  -> open_:bool
  -> on_change:(bool -> unit Effect.t)
  -> trigger:(Attr.t list -> Node.t)
  -> Node.t list
  -> Node.t

(** Keeps whether it is open. The content is given an effect closing it. *)
val component
  :  ?attrs:Attr.t list
  -> ?side:Floating.Side.t
  -> ?align:Floating.Align.t
  -> trigger:(Attr.t list -> Node.t)
  -> (close:unit Effect.t -> Node.t list) Bonsai.t
  -> local_ Bonsai.graph
  -> Node.t Bonsai.t

(** A title and a description for the top of a popover. *)
val header : ?description:string -> string -> Node.t

(** A row of buttons at the bottom of a popover, aligned to the end. *)
val footer : Node.t list -> Node.t
