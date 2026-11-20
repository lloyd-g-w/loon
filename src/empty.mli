(** What a list, a search or a page shows when it has nothing to show: an
    icon, a title, a description and what to do next. *)

open! Import

val view
  :  ?attrs:Attr.t list
  -> ?icon:Icon.t
  -> ?description:string
  -> ?actions:Node.t list
  -> ?bordered:bool
  -> string
  -> Node.t
