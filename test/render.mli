open! Core

(** Prints virtual DOM as indented HTML. [classes] (default [true]): with
    [false], class attributes are left out — shadcn's class strings are long,
    and one test per component printing them is enough; the rest show
    structure, ARIA and data attributes. *)
val html : ?classes:bool -> ?selector:string -> Virtual_dom.Vdom.Node.t -> unit

(** A Bonsai component's view, driven by the test (clicks, keys); class
    attributes are left out with [~classes:false]. *)
val handle
  :  ?classes:bool
  -> (local_ Bonsai_web.Bonsai.graph -> Virtual_dom.Vdom.Node.t Bonsai_web.Bonsai.t)
  -> (Virtual_dom.Vdom.Node.t, Nothing.t) Bonsai_web_test.Handle.t
