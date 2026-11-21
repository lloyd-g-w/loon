(** A sidebar that collapses to icons. Port of shadcn/ui's [sidebar-07] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
