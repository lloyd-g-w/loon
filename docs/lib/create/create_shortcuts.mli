(** The page's keyboard shortcuts, as shadcn's /create: R shuffles, Shift+R
    resets, D toggles light and dark, O opens a preset, Ctrl/⌘+P opens the
    Navigate menu, Ctrl/⌘+Z undoes and Shift+Ctrl/⌘+Z (or Ctrl+Y) redoes. The letters only when focus is not in a text
    field. *)

open! Core

module Action : sig
  type t =
    | Shuffle
    | Reset
    | Toggle_mode
    | Open_preset
    | Undo
    | Redo
    | Navigate
  [@@deriving sexp_of, equal]
end

(** [key] is [KeyboardEvent.key]; [ctrl] is Ctrl or ⌘. *)
val of_key
  :  key:string
  -> shift:bool
  -> ctrl:bool
  -> alt:bool
  -> editable:bool
  -> Action.t option
