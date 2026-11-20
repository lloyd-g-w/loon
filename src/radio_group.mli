(** A set of options of which one is chosen ([role="radiogroup"]). Tab
    reaches the chosen option; arrow keys, Home and End choose another. *)

open! Import

module Item : sig
  type t =
    { value : string
    ; label : string
    ; description : string option
    ; disabled : bool
    }

  val create : ?description:string -> ?disabled:bool -> value:string -> string -> t
end

(** Controlled; [value] is the chosen item's, [None] before any is chosen.
    [name] scopes the elements' ids (one per group on a page). *)
val view
  :  ?attrs:Attr.t list
  -> ?orientation:Roving.Orientation.t
  -> ?disabled:bool
  -> name:string
  -> value:string option
  -> on_change:(string -> unit Effect.t)
  -> Item.t list
  -> Node.t

val component
  :  ?attrs:Attr.t list
  -> ?orientation:Roving.Orientation.t
  -> ?disabled:bool
  -> ?default:string
  -> Item.t list
  -> local_ Bonsai.graph
  -> string option Control.t Bonsai.t
