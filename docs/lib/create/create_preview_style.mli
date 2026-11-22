(** How the preview root takes a preset ([design-system-provider.tsx]):
    its theme's variables for the mode, the radius and fonts as inline
    custom properties; the style and menu colour as {!Loon.Theme.attrs}
    (the classes [style-<name>], [menu-inverted], [menu-translucent]); the
    inverted menus' colours as a rule scoped to the root. *)

open! Core

(** The root's custom properties: [(name, value)] with the [--]. *)
val variables : mode:Loon.Theme.Mode.t -> Create_preset.t -> (string * string) list

(** The root's attributes: [data-create-preview], the variables as its
    [style], the fonts' {!Customize_fonts.root_class}, and
    {!Loon.Theme.attrs} for the mode, style and menu colour. *)
val attrs : mode:Loon.Theme.Mode.t -> Create_preset.t -> Virtual_dom.Vdom.Attr.t list

(** The scoped rules (the inverted menus take the preset's dark
    variables). *)
val css : Create_preset.t -> string
