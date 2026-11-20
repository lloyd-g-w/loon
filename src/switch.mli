(** An on/off switch ([role="switch"]), for settings that apply at once. *)

open! Import

module Size : sig
  type t =
    | Sm
    | Md
  [@@deriving enumerate, sexp_of, compare, equal]
end

(** Controlled. With [label], the switch and its text are one [<label>]. *)
val view
  :  ?attrs:Attr.t list
  -> ?size:Size.t
  -> ?disabled:bool
  -> ?label:string
  -> checked:bool
  -> on_change:(bool -> unit Effect.t)
  -> unit
  -> Node.t

val component
  :  ?attrs:Attr.t list
  -> ?size:Size.t
  -> ?disabled:bool
  -> ?label:string
  -> ?default:bool
  -> local_ Bonsai.graph
  -> bool Control.t Bonsai.t
