(** Undo and redo over the page's states ([(create)/hooks/use-history.tsx]):
    every new state is pushed (dropping what could be redone); undo and redo
    move through them. States are the hash's queries. *)

open! Core

type t [@@deriving sexp_of, equal]

val empty : t

(** Records a state: nothing if it is the current one. *)
val push : t -> string -> t

val can_undo : t -> bool
val can_redo : t -> bool

(** The history moved back (or forward) one state, and that state. *)
val undo : t -> (t * string) option

val redo : t -> (t * string) option
