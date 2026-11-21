(** With Booked/Unavailable Days. Port of shadcn/ui's [calendar-14] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
