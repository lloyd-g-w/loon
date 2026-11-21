(** Date and Time picker. Port of shadcn/ui's [calendar-24] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
