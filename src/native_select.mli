(** The browser's own [<select>], styled to match: the best choice on phones,
    whose pickers are native. *)

open! Import

module Item : sig
  type t =
    { value : string
    ; label : string
    ; disabled : bool
    }

  val create : ?disabled:bool -> value:string -> string -> t
end

(** Controlled. [placeholder] is shown (and not choosable) while [value]
    matches no item. *)
val view
  :  ?attrs:Attr.t list
  -> ?disabled:bool
  -> ?invalid:bool
  -> ?placeholder:string
  -> value:string
  -> on_change:(string -> unit Effect.t)
  -> Item.t list
  -> Node.t

val component
  :  ?attrs:Attr.t list
  -> ?disabled:bool
  -> ?placeholder:string
  -> ?default:string
  -> Item.t list
  -> local_ Bonsai.graph
  -> string Control.t Bonsai.t
