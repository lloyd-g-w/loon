(** A vertical stack of headings, each revealing a section of content.
    Up/Down, Home and End move between the headings (WAI-ARIA accordion). *)

open! Import

module Item : sig
  type t =
    { id : string
    ; title : Node.t
    ; content : Node.t
    ; disabled : bool
    }

  val create : ?disabled:bool -> id:string -> title:string -> Node.t -> t
end

module Kind : sig
  type t =
    | Single of { collapsible : bool }
    (** One open at a time; [collapsible]: it can be closed, leaving none. *)
    | Multiple
  [@@deriving sexp_of, compare, equal]
end

(** The items open after the item [id] is pressed, from [open_]. *)
val toggled : Kind.t -> open_:string list -> string -> string list

(** Controlled: [open_] lists the open items' ids. [name] scopes the ids. *)
val view
  :  ?attrs:Attr.t list
  -> ?kind:Kind.t
  -> name:string
  -> open_:string list
  -> on_change:(string list -> unit Effect.t)
  -> Item.t list
  -> Node.t

(** Keeps which items are open ([default], none at first). [kind] defaults
    to [Single { collapsible = true }]. *)
val component
  :  ?attrs:Attr.t list
  -> ?kind:Kind.t
  -> ?default:string list
  -> Item.t list Bonsai.t
  -> local_ Bonsai.graph
  -> Node.t Bonsai.t
