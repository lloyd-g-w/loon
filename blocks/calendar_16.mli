(** With time picker. Port of shadcn/ui's [calendar-16] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
