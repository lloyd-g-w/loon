open! Import

module Variant = struct
  type t =
    | Neutral
    | Primary
    | Outline
    | Accent
    | Success
    | Warning
    | Danger
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let view ?attrs:extra ?(variant = Variant.Neutral) ?(dot = false) children =
  Node.span
    ~attrs:(attrs ?attrs:extra [ "loon-badge"; "loon-badge-" ^ Variant.name variant ])
    ((if dot then [ Node.span ~attrs:[ Attr.class_ "loon-badge-dot" ] [] ] else [])
     @ children)
;;
