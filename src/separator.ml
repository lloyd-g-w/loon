open! Import

module Orientation = struct
  type t =
    | Horizontal
    | Vertical
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let view
      ?attrs:extra
      ?(orientation = Orientation.Horizontal)
      ?(semantic = false)
      ?label
      ()
  =
  let role =
    if semantic
    then
      [ Attr.role "separator"
      ; aria "orientation" (Orientation.name orientation)
      ]
    else [ Attr.role "none" ]
  in
  let classes =
    [ "loon-separator"; "loon-separator-" ^ Orientation.name orientation ]
  in
  match label with
  | None -> Node.div ~attrs:(attrs ?attrs:extra classes @ role) []
  | Some label ->
    Node.div
      ~attrs:(attrs ?attrs:extra ("loon-separator-labelled" :: classes) @ role)
      [ Node.span
          ~attrs:[ Attr.class_ "loon-separator-label" ]
          [ Node.text label ]
      ]
;;
