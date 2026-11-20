(** Highlighted code with a copy button. *)

open! Core
open Bonsai_web

(** Copies [text] to the clipboard and marks the element the event came
    from (or its closest [.docs-copy]) [data-copied] for two seconds. *)
val copy : text:string -> Js_of_ocaml.Dom_html.mouseEvent Js_of_ocaml.Js.t -> unit Effect.t

val copy_button : ?label:string -> string -> Vdom.Node.t
val view : ?lang:Highlight.Lang.t -> string -> Vdom.Node.t
