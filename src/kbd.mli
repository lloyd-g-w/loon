(** Keyboard keys, as in "press [Ctrl] [K]". *)

open! Import

(** One key. *)
val view : ?attrs:Attr.t list -> string -> Node.t

(** Keys pressed together: [combo ["Ctrl"; "Shift"; "P"]]. Modifier names
    ("Ctrl", "Shift", "Alt", "Cmd", "Enter", ...) show as their symbols
    where [symbols] (default [true]), keeping the name for screen readers. *)
val combo : ?attrs:Attr.t list -> ?symbols:bool -> string list -> Node.t

(** The symbol a key name shows as, if it has one ("Cmd" is "⌘"). *)
val symbol : string -> string option
