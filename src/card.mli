(** A surface that groups related content: a header (title, description and
    an optional action), a body and a footer. *)

open! Import

val view
  :  ?attrs:Attr.t list
  -> ?title:string
  -> ?description:string
  -> ?action:Node.t
  -> ?footer:Node.t list
  -> Node.t list
  -> Node.t

(** The parts, for cards laid out differently. *)

val container : ?attrs:Attr.t list -> Node.t list -> Node.t
val header : ?attrs:Attr.t list -> Node.t list -> Node.t
val title : ?attrs:Attr.t list -> string -> Node.t
val description : ?attrs:Attr.t list -> string -> Node.t
val content : ?attrs:Attr.t list -> Node.t list -> Node.t
val footer : ?attrs:Attr.t list -> Node.t list -> Node.t
