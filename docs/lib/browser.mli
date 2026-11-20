(** The browser's side of the docs: the URL's hash, storage, scrolling and
    the document's theme. Only call these in a browser. *)

open! Core

val in_browser : unit -> bool
val hash : unit -> string
val set_hash : string -> unit

(** Calls [f] with the new hash whenever it changes (links, back/forward). *)
val on_hash_change : (string -> unit) -> unit

(** [localStorage], ignoring its errors (private modes, file: URLs). *)
val get_item : string -> string option

val set_item : string -> string -> unit

(** Puts the theme's classes on [<html>], so its background follows. *)
val set_root_theme : mode:string -> accent:string -> unit

val set_title : string -> unit
val scroll_to_top : unit -> unit
val scroll_to_anchor : string -> unit
val focus : string -> unit

(** The article's headings marked [data-outline]: id, title, level. *)
val outline : unit -> (string * string * int) list

(** Marks the outline's link to the section in view [data-active]. *)
val update_scroll_spy : unit -> unit

val install_scroll_spy : unit -> unit
val is_mac : unit -> bool
val set_body_scroll_locked : bool -> unit
val active_element_is_editable : unit -> bool

(** Moves focus [delta] places along the elements matching [selector]
    (wrapping), from the focused one. *)
val move_focus : string -> int -> unit
