(** Fuzzy matching for the docs' search: the query's characters in order,
    scored higher for matches at word starts and in runs, lower for the
    characters skipped between them. *)

open! Core

(** [None] when [text] does not contain [query]'s characters in order
    (ignoring case and spaces). Higher is better. *)
val score : query:string -> string -> int option

(** The items matching [query], best first (ties keep their order). An item
    is scored by its best field; [fields]' first fields count more. An
    empty query keeps every item. *)
val rank : query:string -> 'a list -> fields:('a -> string list) -> 'a list
