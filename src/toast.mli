(** Short, passing messages ("Saved", "Message sent — Undo") stacked in a
    corner of the screen (the bottom of it on phones), each dismissing
    itself after a while. Put a [Toaster]'s view once in the page and give
    its [push] to whatever announces things. *)

open! Import

module Variant : sig
  type t =
    | Neutral
    | Success
    | Info
    | Warning
    | Danger
  [@@deriving enumerate, sexp_of, compare, equal]
end

type t =
  { title : string
  ; description : string option
  ; variant : Variant.t
  ; action : (string * unit Effect.t) option (** a button: its label, what it does *)
  ; duration : Time_ns.Span.t option (** [None]: until dismissed *)
  }

(** [duration] defaults to 5 seconds. *)
val create
  :  ?description:string
  -> ?variant:Variant.t
  -> ?action:string * unit Effect.t
  -> ?duration:Time_ns.Span.t option
  -> string
  -> t

module Position : sig
  type t =
    | Bottom_right
    | Bottom_left
    | Top_right
    | Top_left
    | Bottom_center
    | Top_center
  [@@deriving enumerate, sexp_of, compare, equal]
end

module Toaster : sig
  type toast := t

  type t =
    { view : Node.t
    ; push : toast -> unit Effect.t
    ; dismiss_all : unit Effect.t
    }
end

(** The newest [max_visible] (default 3) toasts show; pressing a toast's
    action runs it and dismisses the toast. *)
val component
  :  ?position:Position.t
  -> ?max_visible:int
  -> local_ Bonsai.graph
  -> Toaster.t Bonsai.t
