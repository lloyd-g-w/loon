(** Choosing one value from a list that opens beside its trigger: grouped
    options, a check mark on the chosen one, typeahead and arrow keys
    (WAI-ARIA select-only combobox). For a native [<select>], see
    Native_select. *)

open! Import

module Option_ : sig
  type t =
    { value : string
    ; label : string
    ; icon : Icon.t option
    ; disabled : bool
    }

  val create : ?icon:Icon.t -> ?disabled:bool -> ?label:string -> string -> t
end

module Group : sig
  (** Options under an optional heading. *)
  type t =
    { label : string option
    ; options : Option_.t list
    }

  val create : ?label:string -> Option_.t list -> t
end

module State : sig
  type t =
    | Closed
    | Open of { highlighted : string option }
  [@@deriving sexp_of, equal]
end

(** Controlled: [value] is the chosen option's value. [id] must be unique
    on the page. *)
val view
  :  ?attrs:Attr.t list
  -> ?placeholder:string
  -> ?disabled:bool
  -> ?invalid:bool
  -> ?side:Floating.Side.t
  -> id:string
  -> value:string option
  -> on_change:(string -> unit Effect.t)
  -> state:State.t
  -> on_state:(State.t -> unit Effect.t)
  -> Group.t list
  -> Node.t

(** Keeps the value (initially [default]) and whether it is open; returns
    the value and the view. *)
val component
  :  ?attrs:Attr.t list
  -> ?placeholder:string
  -> ?disabled:bool
  -> ?side:Floating.Side.t
  -> ?default:string
  -> Group.t list Bonsai.t
  -> local_ Bonsai.graph
  -> (string option * Node.t) Bonsai.t
