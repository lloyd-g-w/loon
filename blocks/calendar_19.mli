(** With presets. Port of shadcn/ui's [calendar-19] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
