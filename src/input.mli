(** A single-line text field, optionally with a leading icon and a trailing
    addon (text, a button, a keyboard hint) inside its border. *)

open! Import

module Type : sig
  type t =
    | Text
    | Email
    | Password
    | Search
    | Number
    | Url
    | Tel
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string
end

(** Controlled: [value] is shown, [on_input] gets each edit. [attrs] go on
    the [<input>] (give it an id, a name, autocomplete...). [invalid] marks
    it [aria-invalid] and draws it in the danger colour. *)
val view
  :  ?attrs:Attr.t list
  -> ?type_:Type.t
  -> ?placeholder:string
  -> ?disabled:bool
  -> ?invalid:bool
  -> ?leading:Icon.t
  -> ?trailing:Node.t
  -> ?on_enter:unit Effect.t
  -> value:string
  -> on_input:(string -> unit Effect.t)
  -> unit
  -> Node.t

(** Keeps the text; [default] (or empty) at first. *)
val component
  :  ?attrs:Attr.t list
  -> ?type_:Type.t
  -> ?placeholder:string
  -> ?disabled:bool
  -> ?leading:Icon.t
  -> ?trailing:Node.t
  -> ?default:string
  -> local_ Bonsai.graph
  -> string Control.t Bonsai.t
