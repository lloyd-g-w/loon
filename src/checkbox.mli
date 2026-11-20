(** A checkbox ([role="checkbox"]): checked, unchecked, or indeterminate
    (some of a group checked). Space toggles it. *)

open! Import

module State : sig
  type t =
    | Checked
    | Unchecked
    | Indeterminate
  [@@deriving enumerate, sexp_of, compare, equal]

  val of_bool : bool -> t
end

(** Controlled. With [label], the box and its text are one [<label>], so a
    click on the text toggles it too. [on_change] gets the new value:
    [true] from [Unchecked] and [Indeterminate]. *)
val view
  :  ?attrs:Attr.t list
  -> ?disabled:bool
  -> ?label:string
  -> state:State.t
  -> on_change:(bool -> unit Effect.t)
  -> unit
  -> Node.t

(** Keeps whether it is checked; [default] [false]. *)
val component
  :  ?attrs:Attr.t list
  -> ?disabled:bool
  -> ?label:string
  -> ?default:bool
  -> local_ Bonsai.graph
  -> bool Control.t Bonsai.t
