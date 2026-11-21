(** The preview blocks' shared frame (their index.tsx): a horizontally
    scrolling, centred seven-column grid. *)

open! Core
open Bonsai_web

(** The frame around [columns]. *)
val frame : Vdom.Node.t list -> Vdom.Node.t

(** A column: [wide] spans two. *)
val column : ?wide:bool -> Vdom.Node.t list -> Vdom.Node.t
