open! Import
open Js_of_ocaml

module Mode = struct
  type t =
    | Light
    | Dark
  [@@deriving enumerate, sexp, compare, equal]

  let toggle = function
    | Light -> Dark
    | Dark -> Light
  ;;

  let preferred () =
    match
      Js.Optdef.to_option (Js.Unsafe.global##.matchMedia : _ Js.Optdef.t)
    with
    | None -> Light
    | Some _ ->
      let query : < matches : bool Js.t Js.readonly_prop > Js.t =
        Js.Unsafe.global##matchMedia (Js.string "(prefers-color-scheme: dark)")
      in
      if Js.to_bool query##.matches then Dark else Light
  ;;
end

let attrs ?mode () =
  match (mode : Mode.t option) with
  | Some Dark -> [ Attr.class_ "dark" ]
  | Some Light | None -> []
;;

let root ?attrs:(extra = []) ?mode children =
  Node.div
    ~attrs:(attrs ?mode () @ [ Attr.classes [ "bg-background"; "text-foreground" ] ] @ extra)
    children
;;
