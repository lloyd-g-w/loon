(** The home page's showcase: shadcn's CardsDemo, built from loon's
    components. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
