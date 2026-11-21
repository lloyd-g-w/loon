(** A simple login form. Port of shadcn/ui's [login-01] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
