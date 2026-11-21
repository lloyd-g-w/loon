(** shadcn's preset codes ([packages/registry/src/preset/preset.ts]): a
    design system's choices bit-packed into one integer, written in base 62
    after a version letter (["a"]: v1, without the chart colour and heading
    font; ["b"]: v2, the one written). Codes made here and on
    ui.shadcn.com/create are interchangeable. Values are shadcn's names
    (["nova"], ["jetbrains-mono"]). *)

open! Core

val bases : string list
val styles : string list
val base_colors : string list
val themes : string list
val chart_colors : string list

(** Before v2 the base-colour themes took their charts from these themes:
    [("neutral", "blue"); ...]. *)
val v1_chart_color_map : (string * string) list

val icon_libraries : string list
val fonts : string list
val font_headings : string list
val radii : string list
val menu_accents : string list
val menu_colors : string list

type t =
  { style : string
  ; base_color : string
  ; theme : string
  ; chart_color : string option (** [None] in v1 codes *)
  ; icon_library : string
  ; font : string
  ; font_heading : string
  ; radius : string
  ; menu_accent : string
  ; menu_color : string
  }
[@@deriving sexp_of, equal, compare]

(** Every field's first value: what ["b0"] decodes to. *)
val default : t

(** Numbers are JavaScript's, as in preset.ts: a code holds 51 bits. *)
val to_base62 : float -> string

(** [-1.] for a string with a character outside base 62. *)
val of_base62 : string -> float

(** Always a v2 (["b"]) code; a value not in its field's list counts as the
    first. *)
val encode : t -> string

(** [None] for an unknown version or a non-base-62 body; a field's index past
    its list decodes as the first value. *)
val decode : string -> t option

(** A version letter and 1 to 9 base-62 digits. *)
val is_preset_code : string -> bool

(** The code in what a user pastes: a code, or [--preset CODE]
    ([parse-preset-input.ts]). *)
val parse_input : string -> string option

(** [parsePresetStyle]: ["base-vega"] is the base ["base"] and style
    ["vega"]; a name without a known base prefix is only a style. *)
val parse_style : string -> string option * string
