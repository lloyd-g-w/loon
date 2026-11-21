(** A sidebar with a sticky site header. Port of shadcn/ui's [sidebar-16] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
