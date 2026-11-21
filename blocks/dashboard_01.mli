(** A dashboard with sidebar, charts and data table. Port of shadcn/ui's [dashboard-01] block. *)

open! Core
open Bonsai_web

val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
