(** A sidebar with a collapsible file tree. Port of shadcn/ui's [sidebar-11] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
