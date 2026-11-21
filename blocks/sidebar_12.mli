(** A sidebar with a calendar. Port of shadcn/ui's [sidebar-12] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
