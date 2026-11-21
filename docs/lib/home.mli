(** The home page: shadcn's hero, and its showcase of cards. *)

open! Core
open Bonsai_web

val title : string
val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
