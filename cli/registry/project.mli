(** What [loon] does to a project's directory of components. Each function
    prints what it did. *)

open! Core

(** How a project takes the stylesheets: assembled into [DIR/loon.css], or
    one file per stylesheet in [DIR/css/]. *)
module Css_mode : sig
  type t =
    | Assembled
    | Files
end

(** [add ~dir names]: copies the entries [names] and everything they need into
    [dir] (made if absent). Existing files are kept unless [overwrite]. *)
val add
  :  dir:string
  -> overwrite:bool
  -> css:Css_mode.t
  -> dry_run:bool
  -> string list
  -> unit Or_error.t

(** Makes [dir] a dune library ([library]) holding the theme, if it is not
    one already. *)
val init
  :  dir:string
  -> library:string
  -> overwrite:bool
  -> css:Css_mode.t
  -> unit Or_error.t

(** Prints how the project's copies of [names] (all it has, if empty) differ
    from loon's. [Ok true] if they all match. *)
val diff : dir:string -> color:bool -> string list -> bool Or_error.t

(** The entries [dir] has a copy of. *)
val installed : dir:string -> Registry.Entry.t list

(** The dune file [init] writes. *)
val dune_file : library:string -> string

(** An error naming the closest entries to an unknown name. *)
val unknown : string -> Error.t
