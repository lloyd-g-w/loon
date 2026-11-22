open! Import

module Variant = struct
  type t =
    | Default
    | Destructive
    | Outline
    | Secondary
    | Ghost
    | Link
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Destructive -> "destructive"
    | Outline -> "outline"
    | Secondary -> "secondary"
    | Ghost -> "ghost"
    | Link -> "link"
  ;;

  let classes = function
    | Default -> "cn-button-variant-default"
    | Outline -> "cn-button-variant-outline"
    | Secondary -> "cn-button-variant-secondary"
    | Ghost -> "cn-button-variant-ghost"
    | Destructive -> "cn-button-variant-destructive"
    | Link -> "cn-button-variant-link"
  ;;
end

module Size = struct
  type t =
    | Default
    | Xs
    | Sm
    | Lg
    | Icon
    | Icon_xs
    | Icon_sm
    | Icon_lg
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Xs -> "xs"
    | Sm -> "sm"
    | Lg -> "lg"
    | Icon -> "icon"
    | Icon_xs -> "icon-xs"
    | Icon_sm -> "icon-sm"
    | Icon_lg -> "icon-lg"
  ;;

  let classes = function
    | Default -> "cn-button-size-default"
    | Xs -> "cn-button-size-xs"
    | Sm -> "cn-button-size-sm"
    | Lg -> "cn-button-size-lg"
    | Icon -> "cn-button-size-icon"
    | Icon_xs -> "cn-button-size-icon-xs"
    | Icon_sm -> "cn-button-size-icon-sm"
    | Icon_lg -> "cn-button-size-icon-lg"
  ;;
end

let base =
  "cn-button group/button inline-flex shrink-0 items-center justify-center \
   whitespace-nowrap transition-all outline-none select-none \
   disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none \
   [&_svg]:shrink-0"
;;

let class_list ?(variant = Variant.Default) ?(size = Size.Default) ?class_ () =
  [ base; Variant.classes variant; Size.classes size ] @ Option.to_list class_
;;

let classes ?variant ?size ?class_ () = Cn.cn (class_list ?variant ?size ?class_ ())

let slot_attrs ?(variant = Variant.Default) ?(size = Size.Default) () =
  [ data "slot" "button"; data "variant" (Variant.name variant); data "size" (Size.name size) ]
;;

let view
  ?(attrs = [])
  ?class_
  ?variant
  ?size
  ?(disabled = false)
  ?(type_ = `Button)
  ?on_click
  children
  =
  Node.button
    ~attrs:
      ([ Attr.type_
           (match type_ with
            | `Button -> "button"
            | `Submit -> "submit"
            | `Reset -> "reset")
       ]
       @ slot_attrs ?variant ?size ()
       @ [ Cn.attr (class_list ?variant ?size ?class_ ()) ]
       @ (if disabled then [ Attr.disabled ] else [])
       @ Option.value_map on_click ~default:[] ~f:(fun effect ->
         [ Attr.on_click (fun _ -> effect) ])
       @ attrs)
    children
;;

let link ?(attrs = []) ?class_ ?variant ?size ~href children =
  Node.a
    ~attrs:
      (slot_attrs ?variant ?size ()
       @ [ Attr.href href; Cn.attr (class_list ?variant ?size ?class_ ()) ]
       @ attrs)
    children
;;
