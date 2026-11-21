(** A sidebar in a dialog. Port of shadcn/ui's [sidebar-13] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
