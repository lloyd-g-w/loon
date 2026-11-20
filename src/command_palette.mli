(** A command palette: a search box over a grouped list of actions,
    fuzzy-filtered as you type. Arrow keys move, Enter runs. Shown inline,
    in a popover (see Combobox), or as a palette in a dialog opened by
    Ctrl+K or Cmd+K ({!dialog}). *)

open! Import

module Item : sig
  type t =
    { value : string (** unique among the items *)
    ; label : string
    ; keywords : string list (** also searched *)
    ; icon : Icon.t option
    ; shortcut : string option
    ; disabled : bool
    ; on_select : unit Effect.t
    }

  (** [value] defaults to the label. *)
  val create
    :  ?value:string
    -> ?keywords:string list
    -> ?icon:Icon.t
    -> ?shortcut:string
    -> ?disabled:bool
    -> on_select:unit Effect.t
    -> string
    -> t
end

module Group : sig
  type t =
    { heading : string option
    ; items : Item.t list
    }

  val create : ?heading:string -> Item.t list -> t
end

module State : sig
  (** What is typed, and the value of the item highlighted ([None]: the
      first shown). *)
  type t =
    { query : string
    ; highlighted : string option
    }
  [@@deriving sexp_of, equal]

  val empty : t
end

(** The groups' items matching [query], best first within each group;
    groups with none left out. *)
val filter : query:string -> Group.t list -> Group.t list

(** Controlled. [id] must be unique on the page; [empty] is shown when
    nothing matches; [autofocus] focuses the search box when shown. *)
val view
  :  ?attrs:Attr.t list
  -> ?placeholder:string
  -> ?empty:string
  -> ?autofocus:bool
  -> id:string
  -> state:State.t
  -> on_state:(State.t -> unit Effect.t)
  -> Group.t list
  -> Node.t

(** Keeps what is typed and highlighted. *)
val component
  :  ?attrs:Attr.t list
  -> ?placeholder:string
  -> ?empty:string
  -> Group.t list Bonsai.t
  -> local_ Bonsai.graph
  -> Node.t Bonsai.t

(** The palette in a dialog, opened by Ctrl+K or Cmd+K anywhere on the page
    (when [shortcut], the default) or by the effect returned; choosing an
    item closes it first. *)
val dialog
  :  ?placeholder:string
  -> ?empty:string
  -> ?shortcut:bool
  -> Group.t list Bonsai.t
  -> local_ Bonsai.graph
  -> (Node.t * unit Effect.t) Bonsai.t
