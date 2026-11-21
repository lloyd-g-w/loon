(** What #/create's Navigate menu lists besides the preview blocks: each
    component's examples on one page, as shadcn's [<name>-example] items
    ([registry/bases/radix/examples], drawn in [ExampleWrapper] and
    [Example]), from the docs' component pages. *)

open! Core
open Bonsai_web

(** [("<slug>-example", title)] for each component page, by title. *)
val items : (string * string) list

val mem : string -> bool

(** The examples of [item] (one of [items]). *)
val component : string Bonsai.t -> local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
