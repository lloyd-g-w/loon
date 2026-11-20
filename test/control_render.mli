open! Core
open Loon

(** A control's component, viewed with its value printed above it (through
    [sexp_of]), driven by the test. *)
val handle
  :  ('a -> Sexp.t)
  -> (local_ Bonsai_web.Bonsai.graph -> 'a Control.t Bonsai_web.Bonsai.t)
  -> (Virtual_dom.Vdom.Node.t, Nothing.t) Bonsai_web_test.Handle.t
