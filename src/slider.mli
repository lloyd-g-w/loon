(** A value on a range, chosen by dragging a thumb (a styled
    [<input type="range">]: arrow keys, Page Up/Down, Home and End work). *)

open! Import

(** Controlled. [show_value] prints the value beside the track, through
    [format] (default: as few decimals as [step] needs). *)
val view
  :  ?attrs:Attr.t list
  -> ?min:float
  -> ?max:float
  -> ?step:float
  -> ?disabled:bool
  -> ?show_value:bool
  -> ?format:(float -> string)
  -> value:float
  -> on_change:(float -> unit Effect.t)
  -> unit
  -> Node.t

val component
  :  ?attrs:Attr.t list
  -> ?min:float
  -> ?max:float
  -> ?step:float
  -> ?disabled:bool
  -> ?show_value:bool
  -> ?format:(float -> string)
  -> ?default:float
  -> local_ Bonsai.graph
  -> float Control.t Bonsai.t
