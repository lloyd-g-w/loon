open! Core

(** Prints virtual DOM as indented HTML. *)
val html : ?selector:string -> Virtual_dom.Vdom.Node.t -> unit

(** A Bonsai component's view, driven by the test (clicks, keys). *)
val handle
  :  (local_ Bonsai_web.Bonsai.graph -> Virtual_dom.Vdom.Node.t Bonsai_web.Bonsai.t)
  -> (Virtual_dom.Vdom.Node.t, Nothing.t) Bonsai_web_test.Handle.t
