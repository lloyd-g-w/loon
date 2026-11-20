(** Scrolling an element into view. *)

open! Import

(** Scrolls the first element matching [selector] the least needed to show
    it (after the next render). *)
val into_view : string -> unit Effect.t
