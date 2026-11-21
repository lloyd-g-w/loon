(** An inset sidebar with secondary navigation. Port of shadcn/ui's [sidebar-08] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
