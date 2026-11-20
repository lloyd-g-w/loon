(** A select with a search box: choose one of many options by typing to
    filter them (a Command_palette in a popover). *)

open! Import

module State : sig
  type t =
    | Closed
    | Open of Command_palette.State.t
  [@@deriving sexp_of, equal]
end

(** Controlled. Options are Select's; [id] must be unique on the page. *)
val view
  :  ?attrs:Attr.t list
  -> ?placeholder:string
  -> ?search_placeholder:string
  -> ?empty:string
  -> ?disabled:bool
  -> ?invalid:bool
  -> id:string
  -> value:string option
  -> on_change:(string -> unit Effect.t)
  -> state:State.t
  -> on_state:(State.t -> unit Effect.t)
  -> Select.Group.t list
  -> Node.t

(** Keeps the value (initially [default]) and the search; returns the value
    and the view. *)
val component
  :  ?attrs:Attr.t list
  -> ?placeholder:string
  -> ?search_placeholder:string
  -> ?empty:string
  -> ?disabled:bool
  -> ?default:string
  -> Select.Group.t list Bonsai.t
  -> local_ Bonsai.graph
  -> (string option * Node.t) Bonsai.t
