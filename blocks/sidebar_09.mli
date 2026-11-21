(** Collapsible nested sidebars. Port of shadcn/ui's [sidebar-09] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
