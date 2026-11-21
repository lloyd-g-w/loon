open! Core

module T = struct
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
end

include T
include Comparable.Make (T)

let name = function
  | Style -> "style"
  | Base_color -> "baseColor"
  | Theme -> "theme"
  | Chart_color -> "chartColor"
  | Icon_library -> "iconLibrary"
  | Font -> "font"
  | Font_heading -> "fontHeading"
  | Radius -> "radius"
  | Menu_accent -> "menuAccent"
  | Menu_color -> "menuColor"
;;

let get (p : Create_preset.t) = function
  | Style -> p.style
  | Base_color -> p.base_color
  | Theme -> p.theme
  | Chart_color -> Option.value p.chart_color ~default:p.theme
  | Icon_library -> p.icon_library
  | Font -> p.font
  | Font_heading -> p.font_heading
  | Radius -> p.radius
  | Menu_accent -> p.menu_accent
  | Menu_color -> p.menu_color
;;

let set (p : Create_preset.t) t v : Create_preset.t =
  match t with
  | Style -> { p with style = v }
  | Base_color -> { p with base_color = v }
  | Theme -> { p with theme = v }
  | Chart_color -> { p with chart_color = Some v }
  | Icon_library -> { p with icon_library = v }
  | Font -> { p with font = v }
  | Font_heading -> { p with font_heading = v }
  | Radius -> { p with radius = v }
  | Menu_accent -> { p with menu_accent = v }
  | Menu_color -> { p with menu_color = v }
;;
