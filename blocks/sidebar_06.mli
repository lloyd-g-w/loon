(** A sidebar with submenus as dropdowns. Port of shadcn/ui's [sidebar-06] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
