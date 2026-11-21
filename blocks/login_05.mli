(** A simple email-only login page. Port of shadcn/ui's [login-05] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
