(** Multiple months with range selection. Port of shadcn/ui's [calendar-05] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
