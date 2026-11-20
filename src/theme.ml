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

module Accent = struct
  type t =
    | Teal
    | Lake
    | Moss
    | Ember
    | Iris
  [@@deriving enumerate, sexp, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let attrs ?mode ?accent () =
  Attr.classes
    ("loon"
     ::
     (match (mode : Mode.t option) with
      | None -> []
      | Some Light -> [ "loon-light" ]
      | Some Dark -> [ "loon-dark" ]))
  :: Option.value_map accent ~default:[] ~f:(fun accent ->
    [ data "loon-accent" (Accent.name accent) ])
;;

let root ?attrs:(extra = []) ?mode ?accent children =
  Node.div ~attrs:(attrs ?mode ?accent () @ extra) children
;;
