(** What [loon] does to a project's directory of components. Each function
    prints what it did. *)

open! Core

(** [add ~dir names]: copies the entries [names] and everything they need into
    [dir] (made if absent), in [style] (by default the project's: its
    loon.json's, else Vega) with its classes inlined ({!Style.inline}).
    Existing files are kept unless [overwrite]. *)
val add
  :  ?style:string
  -> dir:string
  -> overwrite:bool
  -> dry_run:bool
  -> string list
  -> unit Or_error.t

(** Makes [dir] a dune library ([library]) holding the theme, if it is not
    one already, and records [style] (by default the one recorded, else
    Vega) in [dir/loon.json] for [add]. *)
val init
  :  ?style:string
  -> dir:string
  -> library:string
  -> overwrite:bool
  -> unit
  -> unit Or_error.t

(** Prints how the project's copies of [names] (all it has, if empty) differ
    from loon's (in the project's style). [Ok true] if they all match. *)
val diff : dir:string -> color:bool -> string list -> bool Or_error.t

(** The entries [dir] has a copy of. *)
val installed : dir:string -> Registry.Entry.t list

(** The dune file [init] writes. *)
val dune_file : library:string -> string

(** An error naming the closest entries to an unknown name. *)
val unknown : string -> Error.t
