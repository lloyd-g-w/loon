(** Tabs: a row of triggers, one panel shown at a time. Arrow keys, Home and
    End move between the triggers (WAI-ARIA tabs). *)

open! Import

module Tab : sig
  type t =
    { id : string
    ; label : Node.t
    ; content : Node.t
    ; disabled : bool
    }

  val create : ?disabled:bool -> id:string -> label:string -> Node.t -> t
end

module Variant : sig
  type t =
    | Segmented
    | Underline
  [@@deriving enumerate, sexp_of, compare, equal]
end

(** Controlled: [active] is the id of the tab shown. [name] scopes the
    elements' ids (one per tabs on a page). *)
val view
  :  ?attrs:Attr.t list
  -> ?variant:Variant.t
  -> name:string
  -> active:string
  -> on_change:(string -> unit Effect.t)
  -> Tab.t list
  -> Node.t

(** Keeps which tab is shown; [default] (or the first tab) at first. *)
val component
  :  ?attrs:Attr.t list
  -> ?variant:Variant.t
  -> ?default:string
  -> Tab.t list Bonsai.t
  -> local_ Bonsai.graph
  -> Node.t Bonsai.t
