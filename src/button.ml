open! Import

module Variant = struct
  type t =
    | Primary
    | Secondary
    | Outline
    | Ghost
    | Accent
    | Danger
    | Link
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

module Size = struct
  type t =
    | Sm
    | Md
    | Lg
    | Icon
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let classes ?(variant = Variant.Primary) ?(size = Size.Md) () =
  [ "loon-button"
  ; "loon-button-" ^ Variant.name variant
  ; "loon-button-" ^ Size.name size
  ]
;;

let view
  ?attrs:extra
  ?variant
  ?size
  ?(disabled = false)
  ?(loading = false)
  ?(type_ = `Button)
  ?on_click
  children
  =
  let type_ =
    match type_ with
    | `Button -> "button"
    | `Submit -> "submit"
    | `Reset -> "reset"
  in
  let spinner = Icon.view ~attrs:[ Attr.class_ "loon-spin" ] Loader in
  let children =
    match loading, size with
    | false, _ -> children
    | true, Some Size.Icon -> [ spinner ]
    | true, _ -> spinner :: children
  in
  Node.button
    ~attrs:
      (attrs ?attrs:extra (classes ?variant ?size ())
       @ [ Attr.type_ type_ ]
       @ (if disabled || loading then [ Attr.disabled ] else [])
       @ (if loading then [ aria "busy" "true" ] else [])
       @
       match on_click with
       | Some effect when not (disabled || loading) ->
         [ Attr.on_click (fun _ -> effect) ]
       | _ -> [])
    children
;;

let with_icon ?attrs ?variant ?size ?disabled ?on_click icon label =
  view ?attrs ?variant ?size ?disabled ?on_click [ Icon.view icon; Node.text label ]
;;

let link ?attrs:extra ?variant ?size ~href children =
  Node.a ~attrs:(attrs ?attrs:extra (classes ?variant ?size ()) @ [ Attr.href href ]) children
;;
