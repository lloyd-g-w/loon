(** Range selection with minimum and maximum days. Port of shadcn/ui's [calendar-07] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
