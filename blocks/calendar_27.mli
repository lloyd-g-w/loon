(** Chart filter. Port of shadcn/ui's [calendar-27] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
