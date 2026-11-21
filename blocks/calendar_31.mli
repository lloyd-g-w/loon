(** With event slots. Port of shadcn/ui's [calendar-31] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
