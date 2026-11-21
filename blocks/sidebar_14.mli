(** A sidebar on the right. Port of shadcn/ui's [sidebar-14] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
