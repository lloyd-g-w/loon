(** A preset's theme as CSS: shadcn's [buildRegistryTheme] and
    [buildThemeForPreset] ([registry/config.ts]): the base colour's
    variables, the theme's over them, the chart colour's [chart-1..5], the
    bold menu accent ([accent] = [primary]) and the radius; and the
    get-code dialog's [globals.css] ([formatThemeCss]), with the fonts. *)

open! Core

type t =
  { light : (string * string) list (** in the base colour's order *)
  ; dark : (string * string) list
  }
[@@deriving sexp_of]

(** The variables of a preset; a missing base colour or theme counts as
    neutral. [radius] is always in [light] (the theme's own for
    ["default"]). *)
val of_preset : Create_preset.t -> t

(** [selector { --name: value; ... }], one declaration a line. *)
val rule : string -> (string * string) list -> string

(** [:root {...}] and [.dark {...}]: what shadcn copies as "Theme". *)
val theme_css : Create_preset.t -> string

(** The fonts' [@theme inline] lines: [--font-sans] and [--font-heading]
    (the body font's for ["inherit"]). *)
val font_css : Create_preset.t -> string

(** [theme_css], then [font_css]: the get-code dialog's [globals.css]. *)
val css : Create_preset.t -> string
