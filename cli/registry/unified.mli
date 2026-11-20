(** Unified diffs ([diff -u]), which [patch] and [git apply] take. *)

open! Core

(** The diff from [prev] to [next] with three lines of context, or [None] if
    they are the same. With [color], removed lines are red and added ones
    green (ANSI). *)
val diff
  :  ?color:bool
  -> prev_name:string
  -> next_name:string
  -> prev:string
  -> next:string
  -> unit
  -> string option
