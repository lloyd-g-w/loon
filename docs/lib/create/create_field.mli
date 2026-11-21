(** The design system's fields: what a picker sets, a lock keeps, an
    override previews ([LockableParam]). *)

open! Core

type t =
  | Style
  | Base_color
  | Theme
  | Chart_color
  | Icon_library
  | Font
  | Font_heading
  | Radius
  | Menu_accent
  | Menu_color
[@@deriving enumerate, sexp, compare, equal]

include Comparable.S with type t := t

(** shadcn's search-param key: ["baseColor"]. *)
val name : t -> string

val get : Create_preset.t -> t -> string
val set : Create_preset.t -> t -> string -> Create_preset.t
