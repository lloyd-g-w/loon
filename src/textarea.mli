(** A multi-line text field. *)

open! Import

val view
  :  ?attrs:Attr.t list
  -> ?placeholder:string
  -> ?rows:int
  -> ?disabled:bool
  -> ?invalid:bool
  -> value:string
  -> on_input:(string -> unit Effect.t)
  -> unit
  -> Node.t

val component
  :  ?attrs:Attr.t list
  -> ?placeholder:string
  -> ?rows:int
  -> ?disabled:bool
  -> ?default:string
  -> local_ Bonsai.graph
  -> string Control.t Bonsai.t
