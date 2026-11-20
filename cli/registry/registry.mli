(** loon's components, as embedded at build time, and the pure parts of
    what [loon] does with them. *)

open! Core
module Entry = Loon_scan.Entry

(** Every entry, by name. *)
val all : Entry.t list

(** The entry a user's name for it refers to: [button], [Button], [dom-util]
    and [dom_util.ml] are all fine. *)
val find : string -> Entry.t option

(** [canonical name]: [name] as entries are named (lowercase, [_] for [-]). *)
val canonical : string -> string

(** The entries [names] need, dependencies before their dependents (the
    theme first), each once. Raises on an unknown name. *)
val closure : ?entries:Entry.t list -> string list -> Entry.t list

(** The entries' names closest to an unknown [name], best first. *)
val suggest : ?entries:Entry.t list -> string -> string list

(** The Levenshtein distance between two strings. *)
val edit_distance : string -> string -> int

module Css : sig
  (** A stylesheet assembled from entries: sections headed
      [/* loon: NAME */], each an entry's stylesheets in order. *)

  type t [@@deriving sexp_of]

  val parse : string -> t
  val to_string : t -> string
  val of_entries : Entry.t list -> t
  val section : t -> string -> string option
  val names : t -> string list

  (** [merge t entries ~overwrite]: [t] with the sections of [entries] it
      lacks (theme at the start, the others at the end), and with those it
      has replaced if [overwrite]. Also returns which entries were added,
      replaced, kept as they were though they differ (skipped) and kept as
      they are the same. Entries without stylesheets
      are left out. *)
  val merge
    :  t
    -> Entry.t list
    -> overwrite:bool
    -> t * [ `Added | `Replaced | `Skipped | `Same ] String.Map.t

  (** The whole stylesheet: the theme then every other entry in name
      order. *)
  val full : unit -> string
end
