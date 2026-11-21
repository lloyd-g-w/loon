open! Core

module Action = struct
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

let of_key ~key ~shift ~ctrl ~alt ~editable : Action.t option =
  match String.lowercase key with
  | "p" when ctrl -> Some Navigate
  | "z" when ctrl && not editable -> Some (if shift then Redo else Undo)
  | "y" when ctrl && not editable -> Some Redo
  | _ when ctrl || alt || editable -> None
  | "r" -> Some (if shift then Reset else Shuffle)
  | "d" when not shift -> Some Toggle_mode
  | "o" when not shift -> Some Open_preset
  | _ -> None
;;
