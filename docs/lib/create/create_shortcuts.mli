(** The page's keyboard shortcuts, as shadcn's /create: R shuffles, Shift+R
    resets, D toggles light and dark, O opens a preset, Ctrl/⌘+Z undoes and
    Shift+Ctrl/⌘+Z redoes. The letters only when focus is not in a text
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
