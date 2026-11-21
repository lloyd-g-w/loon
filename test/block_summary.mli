open! Core

(** A block's rendering in brief, for smoke tests of whole pages: the
    [data-slot]s it renders, in order of first appearance with how many,
    then its text, whitespace collapsed, wrapped at 80 columns. *)
val print : Virtual_dom.Vdom.Node.t -> unit

(** Renders the block (by shadcn's name, ["login-01"]) in a test handle,
    for [print] and interactions. *)
val handle
  :  string
  -> (Virtual_dom.Vdom.Node.t, Nothing.t) Bonsai_web_test.Handle.t

(** [print] of the handle's current view. *)
val show : (Virtual_dom.Vdom.Node.t, Nothing.t) Bonsai_web_test.Handle.t -> unit
