(** shadcn's [Label] and [Input] (their classes), for the overlays'
    examples' forms until loon's own are ported. *)

open! Core
open Bonsai_web

val label : ?class_:string -> for_:string -> string -> Vdom.Node.t

(** An input with id [id], initially holding [value]. *)
val input : ?attrs:Vdom.Attr.t list -> id:string -> string -> Vdom.Node.t
