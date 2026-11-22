(** shadcn's styles (Vega, Nova, ...), inlined into copied components as
    shadcn's CLI does ([transform-style-map.ts]): each [cn-*] class in a
    string literal of a component's [.ml] becomes the style's classes for
    it, merged under the literal's own (which win, as tailwind-merge does
    there). Copied components then need no style stylesheet. *)

open! Core

(** The styles' names, Vega (the default) first. *)
val names : string list

val default : string

(** [Some name] if [name] is a style (any case). *)
val find : string -> string option

(** The style's classes by [cn-*] class (its rules [.cn-x { @apply ... }]). *)
val map : string -> string String.Map.t

(** [inline ~style source]: the [.ml] [source] with every string literal
    holding [cn-*] classes rewritten: the style's classes merged in, the
    [cn-*] classes gone ([cn-font-heading] becomes [font-heading];
    [cn-menu-target] stays, for the theme's inverted menus). Other
    literals, comments and code are kept byte for byte. *)
val inline : style:string -> string -> string
