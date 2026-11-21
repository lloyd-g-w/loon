(** A signup page with form and image. Port of shadcn/ui's [signup-04] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
