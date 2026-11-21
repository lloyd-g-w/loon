(** A sidebar with collapsible sections. Port of shadcn/ui's [sidebar-02] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
