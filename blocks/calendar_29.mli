(** Natural language date picker. Port of shadcn/ui's [calendar-29] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t

(** chrono-node's [parseDate], for a few phrases ("tomorrow", "in 2 days",
    "next week", "friday", "3 days ago") and the dates [Date] parses;
    relative to [today] (by default, today). *)
val parse_date : ?today:Date.t -> string -> Date.t option
