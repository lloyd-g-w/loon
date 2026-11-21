(** [Label] and [Input] as the overlays' examples' forms use them. *)

open! Core
open Bonsai_web

val label : ?class_:string -> for_:string -> string -> Vdom.Node.t

(** An input with id [id], initially holding [value]. *)
val input : ?attrs:Vdom.Attr.t list -> id:string -> string -> Vdom.Node.t
