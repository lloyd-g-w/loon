(** Calendar with disabled days. Port of shadcn/ui's [calendar-08] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
