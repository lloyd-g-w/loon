(** shadcn's [preview] block (the /create preview "02"): a kitchen sink of
    cards — style overview, typography, UI elements, forms and charts. *)

open! Core
open Bonsai_web

val component : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
