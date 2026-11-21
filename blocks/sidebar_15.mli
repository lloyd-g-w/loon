(** A left and right sidebar. Port of shadcn/ui's [sidebar-15] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
