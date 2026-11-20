(** A row of toggles of which one ([Single], like a segmented control) or
    any number ([Multiple]) are pressed. Tab reaches the group once; arrow
    keys, Home and End move between its items. *)

open! Import

module Item : sig
  type t =
    { value : string
    ; content : Node.t list
    ; label : string option (** [aria-label], for icon-only items *)
    ; disabled : bool
    }

  val create : ?label:string -> ?disabled:bool -> value:string -> Node.t list -> t
  val text : ?disabled:bool -> value:string -> string -> t
  val icon : ?disabled:bool -> value:string -> label:string -> Icon.t -> t
end

(** One pressed at most: pressing it again unpresses it, unless
    [required]. [name] scopes the items' ids. *)
val single
  :  ?attrs:Attr.t list
  -> ?variant:Toggle.Variant.t
  -> ?size:Toggle.Size.t
  -> ?disabled:bool
  -> ?required:bool
  -> name:string
  -> value:string option
  -> on_change:(string option -> unit Effect.t)
  -> Item.t list
  -> Node.t

(** Any number pressed. *)
val multiple
  :  ?attrs:Attr.t list
  -> ?variant:Toggle.Variant.t
  -> ?size:Toggle.Size.t
  -> ?disabled:bool
  -> name:string
  -> value:String.Set.t
  -> on_change:(String.Set.t -> unit Effect.t)
  -> Item.t list
  -> Node.t

val single_component
  :  ?attrs:Attr.t list
  -> ?variant:Toggle.Variant.t
  -> ?size:Toggle.Size.t
  -> ?disabled:bool
  -> ?required:bool
  -> ?default:string
  -> Item.t list
  -> local_ Bonsai.graph
  -> string option Control.t Bonsai.t

val multiple_component
  :  ?attrs:Attr.t list
  -> ?variant:Toggle.Variant.t
  -> ?size:Toggle.Size.t
  -> ?disabled:bool
  -> ?default:String.Set.t
  -> Item.t list
  -> local_ Bonsai.graph
  -> String.Set.t Control.t Bonsai.t
