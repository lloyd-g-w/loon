(** Sample data for the chart examples. *)

open! Core

val visitors_by_day : Loon.Chart.row list

(** "Apr 1" (with [~year:true], "Apr 1, 2024") for "2024-04-01". *)
val short_date : ?year:bool -> string -> string

(** The rows of [visitors_by_day] on or after [days] days before 2024-06-30. *)
val last_days : int -> Loon.Chart.row list

(** An example's card at the width the docs show it: a gallery column, or
    with [~wide:true] the preview's full width. *)
val frame
  :  ?wide:bool
  -> (local_ Bonsai_web.Bonsai.graph -> Bonsai_web.Vdom.Node.t Bonsai_web.Bonsai.t)
  -> local_ Bonsai_web.Bonsai.graph
  -> Bonsai_web.Vdom.Node.t Bonsai_web.Bonsai.t
