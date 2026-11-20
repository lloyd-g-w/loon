(** A short label shown when the pointer rests on, or the keyboard focuses,
    its trigger, after a short delay. CSS only: no state. *)

open! Import

(** [trigger attrs] is the element described, given the attribute linking
    it to the tooltip ([aria-describedby]); [id] must be unique on the
    page. *)
val view
  :  ?attrs:Attr.t list
  -> ?side:Floating.Side.t
  -> id:string
  -> content:string
  -> (Attr.t list -> Node.t)
  -> Node.t
