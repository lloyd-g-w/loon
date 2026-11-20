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

let attrs ?(mode = Mode.Light) ?(accent = Accent.Teal) () =
  [ Attr.classes
      [ "loon"
      ; (match mode with
         | Light -> "loon-light"
         | Dark -> "loon-dark")
      ]
  ; data "loon-accent" (Accent.name accent)
  ]
;;

let root ?attrs:(extra = []) ?mode ?accent children =
  Node.div ~attrs:(attrs ?mode ?accent () @ extra) children
;;
