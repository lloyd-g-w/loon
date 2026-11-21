open! Core

(** For the menu tests (Dropdown_menu, Context_menu, Menubar): a compact
    picture of what is open, one line per menu and item. *)

type h := (Virtual_dom.Vdom.Node.t, Nothing.t) Bonsai_web_test.Handle.t

(** Prints each open [role="menu"] (its [data-slot]), with its items: [>]
    marks the highlighted one, then the item's text and its [data-state],
    [aria-checked] and [data-disabled]. Prints [closed] when no menu is
    open. With [triggers], first the elements matching it, with their
    [data-state]. *)
val print : ?triggers:string -> h -> unit

(** Fires the [contextmenu] event at the element matching the selector,
    at the point ([client_x], [client_y]). *)
val right_click : h -> string -> client_x:float -> client_y:float -> unit

(** Moves the pointer over the element matching the selector. *)
val hover : h -> string -> unit
