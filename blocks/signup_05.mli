(** A simple signup form with social providers. Port of shadcn/ui's [signup-05] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
