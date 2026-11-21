open! Core

(** A form control's Bonsai [component] in a test handle: its view, then its
    value in an [<output>]. *)

val handle
  :  ?classes:bool
  -> ('a -> Sexplib0.Sexp.t)
  -> (local_ Bonsai_web.Bonsai.graph -> 'a Loon.Control.t Bonsai_web.Bonsai.t)
  -> (Virtual_dom.Vdom.Node.t, Nothing.t) Bonsai_web_test.Handle.t
