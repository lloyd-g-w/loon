open! Import

module Variant = struct
  type t =
    | Ghost
    | Outline
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

module Size = struct
  type t =
    | Sm
    | Md
    | Lg
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let classes ?(variant = Variant.Ghost) ?(size = Size.Md) () =
  [ "loon-toggle"
  ; "loon-toggle-" ^ Variant.name variant
  ; "loon-toggle-" ^ Size.name size
  ]
;;

let view
      ?attrs:extra
      ?variant
      ?size
      ?(disabled = false)
      ~pressed
      ~on_change
      children
  =
  Node.button
    ~attrs:
      (attrs ?attrs:extra (classes ?variant ?size ())
       @ [ Attr.type_ "button"
         ; aria_bool "pressed" pressed
         ; data "state" (if pressed then "on" else "off")
         ]
       @
       if disabled
       then [ Attr.disabled ]
       else [ Attr.on_click (fun _ -> on_change (not pressed)) ])
    children
;;

let component
      ?attrs
      ?variant
      ?size
      ?disabled
      ?(default = false)
      children
      (local_ graph)
  =
  Control.make
    ~equal:Bool.equal
    default
    ~view:(fun pressed set ->
      view ?attrs ?variant ?size ?disabled ~pressed ~on_change:set children)
    graph
;;
