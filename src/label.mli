(** A label for a form control. [required] marks it with an asterisk. *)

open! Import

val view
  :  ?attrs:Attr.t list
  -> ?for_:string
  -> ?required:bool
  -> Node.t list
  -> Node.t

(** A label with just text. *)
val text
  :  ?attrs:Attr.t list
  -> ?for_:string
  -> ?required:bool
  -> string
  -> Node.t
