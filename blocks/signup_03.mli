(** A signup page with a muted background color. Port of shadcn/ui's [signup-03] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
