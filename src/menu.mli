(** The look menus and listboxes share (Dropdown_menu, Select,
    Command_palette): rows, group labels, separators and shortcuts. *)

open! Import

(** A group's heading. *)
val label : string -> Node.t

(** A thin rule between groups. *)
val separator : Node.t

(** A keyboard shortcut shown at the end of a row, e.g. ["⌘K"]. *)
val shortcut : string -> Node.t
