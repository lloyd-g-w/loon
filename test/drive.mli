open! Core

(** Actions on a handle that recompute the view afterwards, so that the
    next action sees the handlers of the new view. *)

type h := (Virtual_dom.Vdom.Node.t, Nothing.t) Bonsai_web_test.Handle.t

val click : h -> string -> unit
val key : h -> string -> Js_of_ocaml.Dom_html.Keyboard_code.t -> unit
val type_ : h -> string -> string -> unit

(** Fires an event with no fields by its handler's name ("onpointermove"). *)
val event : h -> string -> string -> unit
