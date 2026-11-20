(** A window over the page that the user must deal with before going back
    to it: a title, a description, content and buttons. Esc, the close
    button or a click outside closes it; focus stays inside while it is
    open. *)

open! Import

module Size : sig
  type t =
    | Sm
    | Md
    | Lg
    | Xl
  [@@deriving enumerate, sexp_of, compare, equal]
end

(** Controlled. [trigger attrs], when given, is the element that opens it.
    [footer] is a row of buttons (stacked on phones). [id] must be unique
    on the page. *)
val view
  :  ?attrs:Attr.t list
  -> ?size:Size.t
  -> ?description:string
  -> ?footer:Node.t list
  -> ?close_button:bool
  -> ?trigger:(Attr.t list -> Node.t)
  -> id:string
  -> open_:bool
  -> on_change:(bool -> unit Effect.t)
  -> title:string
  -> Node.t list
  -> Node.t

(** Keeps whether it is open. [content ~close] gives the body and footer,
    with an effect that closes it. *)
val component
  :  ?attrs:Attr.t list
  -> ?size:Size.t
  -> ?description:string
  -> ?close_button:bool
  -> trigger:(Attr.t list -> Node.t)
  -> title:string
  -> (close:unit Effect.t -> Node.t list * Node.t list) Bonsai.t
  -> local_ Bonsai.graph
  -> Node.t Bonsai.t

(** The header (title and description) and footer, for building other
    dialogs. *)
val header : id:string -> ?description:string -> string -> Node.t

val footer : Node.t list -> Node.t
