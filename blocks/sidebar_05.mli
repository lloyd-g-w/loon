(** A sidebar with collapsible submenus. Port of shadcn/ui's [sidebar-05] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
