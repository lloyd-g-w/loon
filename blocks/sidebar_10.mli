(** A sidebar in a popover. Port of shadcn/ui's [sidebar-10] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
