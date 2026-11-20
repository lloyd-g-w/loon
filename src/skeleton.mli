(** A placeholder that pulses where content is loading. Size it with
    [width] and [height] (CSS lengths) or with attributes. *)

open! Import

module Shape : sig
  type t =
    | Rect
    | Circle
    | Text
  [@@deriving enumerate, sexp_of, compare, equal]
end

val view
  :  ?attrs:Attr.t list
  -> ?shape:Shape.t
  -> ?width:string
  -> ?height:string
  -> unit
  -> Node.t

(** [lines] lines of text, the last one shorter. *)
val text : ?attrs:Attr.t list -> ?lines:int -> unit -> Node.t
