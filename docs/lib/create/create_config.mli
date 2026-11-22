(** What /create offers ([registry/config.ts], [bases.ts], shadcn's
    [iconLibraries], [(create)/lib/fonts.ts]), and which of it loon can
    show: every style, on Radix with Lucide icons (other bases and icon
    libraries are listed but disabled). *)

open! Core

module Option_ : sig
  type t =
    { name : string
    ; title : string
    ; disabled : string option (** why it cannot be chosen *)
    }
end

(** Vega, shadcn's default style. *)
val style : string

val styles : Create_style.t list

(** Radix. *)
val base : string

val bases : Option_.t list

(** Lucide. *)
val icon_library : string

val icon_libraries : Option_.t list

(** The base colours ([BASE_COLORS]): neutral, stone, zinc, mauve, olive,
    mist, taupe. *)
val base_colors : Create_theme.t list

val is_base_color : string -> bool
val theme : string -> Create_theme.t option

(** [getThemesForBaseColor]: the base colour itself, then every accent. *)
val themes_for_base_color : string -> Create_theme.t list

module Radius : sig
  type t =
    { name : string
    ; label : string
    ; value : string (** [""] for the theme's own *)
    }
end

val radii : Radius.t list
val menu_accents : (string * string) list
val menu_colors : (string * string) list

(** [(create)/lib/fonts.ts]'s [FONTS], in its order. *)
val fonts : Customize_fonts.Font.t list

val font : string -> Customize_fonts.Font.t option

(** The CSS value of a font for the preview, as [createFontOption]'s
    [style.fontFamily]: ["var(--font-inter), 'Inter Variable', sans-serif"]. *)
val font_family : Customize_fonts.Font.t -> string

(** [PRESETS]' "radix-vega": what Reset goes back to. *)
val reset_preset : Create_preset.t
