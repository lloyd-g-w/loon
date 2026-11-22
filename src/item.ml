open! Import

module Variant = struct
  type t =
    | Default
    | Outline
    | Muted
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Outline -> "outline"
    | Muted -> "muted"
  ;;

  let classes = function
    | Default -> "cn-item-variant-default"
    | Outline -> "cn-item-variant-outline"
    | Muted -> "cn-item-variant-muted"
  ;;
end

module Size = struct
  type t =
    | Default
    | Sm
    | Xs
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Sm -> "sm"
    | Xs -> "xs"
  ;;

  let classes = function
    | Default -> "cn-item-size-default"
    | Sm -> "cn-item-size-sm"
    | Xs -> "cn-item-size-xs"
  ;;
end

module Media_variant = struct
  type t =
    | Default
    | Icon
    | Image
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Icon -> "icon"
    | Image -> "image"
  ;;

  let classes = function
    | Default -> "cn-item-media-variant-default"
    | Icon -> "cn-item-media-variant-icon"
    | Image -> "cn-item-media-variant-image"
  ;;
end

let base =
  "cn-item group/item flex w-full flex-wrap items-center transition-colors duration-100 \
   outline-none focus-visible:border-ring focus-visible:ring-[3px] \
   focus-visible:ring-ring/50 [a]:transition-colors"
;;

let class_list ?(variant = Variant.Default) ?(size = Size.Default) ?class_ () =
  [ base; Variant.classes variant; Size.classes size ] @ Option.to_list class_
;;

let classes ?variant ?size ?class_ () = Cn.cn (class_list ?variant ?size ?class_ ())

let item_attrs ?(variant = Variant.Default) ?(size = Size.Default) ?class_ () =
  [ data "slot" "item"
  ; data "variant" (Variant.name variant)
  ; data "size" (Size.name size)
  ; Cn.attr (class_list ~variant ~size ?class_ ())
  ]
;;

let view ?(attrs = []) ?class_ ?variant ?size children =
  Node.div ~attrs:(item_attrs ?variant ?size ?class_ () @ attrs) children
;;

let link ?(attrs = []) ?class_ ?variant ?size ~href children =
  Node.a ~attrs:(item_attrs ?variant ?size ?class_ () @ [ Attr.href href ] @ attrs) children
;;

let element make slot classes ?(attrs = []) ?class_ children =
  make ~attrs:([ data "slot" slot; Cn.with_class ?class_ [ classes ] ] @ attrs) children
;;

let div slot classes = element (fun ~attrs c -> Node.div ~attrs c) slot classes

let group ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ Attr.role "list"
       ; data "slot" "item-group"
       ; Cn.with_class ?class_ [ "cn-item-group group/item-group flex w-full flex-col" ]
       ]
       @ attrs)
    children
;;

(* Separator's DOM, with this slot rather than [separator]. *)
let separator ?(attrs = []) ?class_ () =
  Node.div
    ~attrs:
      ([ data "slot" "item-separator"
       ; Attr.role "none"
       ; data "orientation" "horizontal"
       ; Cn.with_class
           ?class_
           [ "shrink-0 bg-border data-horizontal:h-px data-horizontal:w-full \
              data-vertical:w-px data-vertical:self-stretch"
           ; "cn-item-separator"
           ]
       ]
       @ attrs)
    []
;;

let media ?(attrs = []) ?class_ ?(variant = Media_variant.Default) children =
  Node.div
    ~attrs:
      ([ data "slot" "item-media"
       ; data "variant" (Media_variant.name variant)
       ; Cn.with_class
           ?class_
           [ "cn-item-media flex shrink-0 items-center justify-center \
              [&_svg]:pointer-events-none"
           ; Media_variant.classes variant
           ]
       ]
       @ attrs)
    children
;;

let content =
  div "item-content" "cn-item-content flex flex-1 flex-col \
                      [&+[data-slot=item-content]]:flex-none"
;;

let title =
  div "item-title" "cn-item-title line-clamp-1 flex w-fit items-center"
;;

let description ?(attrs = []) ?class_ children =
  Node.p
    ~attrs:
      ([ data "slot" "item-description"
       ; Cn.with_class
           ?class_
           [ "cn-item-description line-clamp-2 font-normal [&>a]:underline \
              [&>a]:underline-offset-4 [&>a:hover]:text-primary"
           ; "[&>a]:underline [&>a]:underline-offset-4 [&>a:hover]:text-primary"
           ]
       ]
       @ attrs)
    children
;;

let actions = div "item-actions" "cn-item-actions flex items-center"
let header = div "item-header" "cn-item-header flex basis-full items-center justify-between"
let footer = div "item-footer" "cn-item-footer flex basis-full items-center justify-between"
