(** #/create's state in the hash's query, as shadcn's
    [(create)/lib/search-params.ts]: [preset=CODE] holds the design system
    (with [fontHeading] and [chartColor] overriding it, as
    [resolvePresetOverrides]); [item] the previewed block; other keys
    ([base], [template], ...) pass through. Without a valid code the
    individual keys ([style], [theme], ...) are read instead. *)

open! Core

type t =
  { preset : Create_preset.t
    (** normalised: [chart_color] is [Some], [font_heading] is ["inherit"] when
      it is the body font, the theme and chart colour fit the base colour,
      [bold] needs an opaque menu, and the style, icon library are the ones
      loon has (Vega, Lucide) *)
  ; item : string
  ; extra : (string * string) list (** the keys passed through, in order *)
  }
[@@deriving sexp_of, equal]

val default_item : string
val of_query : string -> t

(** [preset=CODE&item=...&<extra>]. *)
val to_query : t -> string

(** [normalizeDesignSystemParams], and loon's restrictions. *)
val normalize : Create_preset.t -> Create_preset.t

(** The preset's code. *)
val code : t -> string

val is_translucent_menu_color : string -> bool
