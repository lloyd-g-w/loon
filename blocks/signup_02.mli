(** A two column signup page with a cover image. Port of shadcn/ui's [signup-02] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
