(** How the preview root takes a preset ([design-system-provider.tsx]):
    its theme's variables for the mode, the radius and fonts as inline
    custom properties; the inverted and translucent menus and the heading
    font as rules scoped to the root (shadcn adds [dark] and
    [cn-menu-translucent] to menus' content, and [cn-font-heading] to
    titles: loon's components have none of these, so the rules match their
    [data-slot]s). *)

open! Core

(** The root's custom properties: [(name, value)] with the [--]. *)
val variables : mode:Loon.Theme.Mode.t -> Create_preset.t -> (string * string) list

(** The root's attributes: [data-create-preview], its [data-menu-color],
    the variables as its [style], and [dark] in dark mode (with the
    fonts' {!Customize_fonts.root_class}). *)
val attrs : mode:Loon.Theme.Mode.t -> Create_preset.t -> Virtual_dom.Vdom.Attr.t list

(** The scoped rules (the inverted menus take the preset's dark
    variables). *)
val css : Create_preset.t -> string
