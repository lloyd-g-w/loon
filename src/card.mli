(** Displays a card with header, content, and footer. Port of shadcn/ui's
    [Card]: [root] holds a [header] (a [title], a [description] and an
    optional [action]), [content] and a [footer]. *)

open! Import

val root : ?attrs:Attr.t list -> ?class_:string -> Node.t list -> Node.t
val header : ?attrs:Attr.t list -> ?class_:string -> Node.t list -> Node.t
val title : ?attrs:Attr.t list -> ?class_:string -> Node.t list -> Node.t
val description : ?attrs:Attr.t list -> ?class_:string -> Node.t list -> Node.t
val action : ?attrs:Attr.t list -> ?class_:string -> Node.t list -> Node.t
val content : ?attrs:Attr.t list -> ?class_:string -> Node.t list -> Node.t
val footer : ?attrs:Attr.t list -> ?class_:string -> Node.t list -> Node.t
