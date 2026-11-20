(** Moving focus within a part of the page (keeping it inside a modal). *)

open! Import

(** The first, or last, focusable element inside the element with id [id]. *)
val first_in : string -> unit Effect.t

val last_in : string -> unit Effect.t

(** An invisible focusable element that, when focused (by Tab leaving the
    modal at one end), sends focus to the other end of the element [id]. *)
val guard : id:string -> [ `Start | `End ] -> Node.t
