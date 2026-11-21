(** Start and end of month. Port of shadcn/ui's [calendar-11] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
