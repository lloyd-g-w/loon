open! Core

type t =
  { back : string list
  ; current : string option
  ; forward : string list
  }
[@@deriving sexp_of, equal]

let empty = { back = []; current = None; forward = [] }

let push t q =
  match t.current with
  | Some c when String.equal c q -> t
  | None -> { back = []; current = Some q; forward = [] }
  | Some c -> { back = c :: t.back; current = Some q; forward = [] }
;;

let can_undo t = not (List.is_empty t.back)
let can_redo t = not (List.is_empty t.forward)

let undo t =
  match t.back, t.current with
  | prev :: back, Some c ->
    Some ({ back; current = Some prev; forward = c :: t.forward }, prev)
  | _ -> None
;;

let redo t =
  match t.forward, t.current with
  | next :: forward, Some c ->
    Some ({ back = c :: t.back; current = Some next; forward }, next)
  | _ -> None
;;
