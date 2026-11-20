(** A dialog that interrupts to ask for confirmation of something important
    (often destructive). It closes only through its buttons or Esc, not by a
    click outside; the cancel button has focus first. *)

open! Import

(** Controlled. [on_confirm] runs (and the dialog closes) when the confirm
    button is chosen. [danger] makes that button red. *)
val view
  :  ?attrs:Attr.t list
  -> ?confirm_label:string
  -> ?cancel_label:string
  -> ?danger:bool
  -> ?trigger:(Attr.t list -> Node.t)
  -> id:string
  -> open_:bool
  -> on_change:(bool -> unit Effect.t)
  -> title:string
  -> description:string
  -> on_confirm:unit Effect.t
  -> unit
  -> Node.t

(** Keeps whether it is open. *)
val component
  :  ?attrs:Attr.t list
  -> ?confirm_label:string
  -> ?cancel_label:string
  -> ?danger:bool
  -> trigger:(Attr.t list -> Node.t)
  -> title:string
  -> description:string
  -> unit Effect.t Bonsai.t
  -> local_ Bonsai.graph
  -> Node.t Bonsai.t
