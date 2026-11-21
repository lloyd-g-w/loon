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
    | Default -> "bg-transparent"
    | Outline -> "border-border"
    | Muted -> "bg-muted/50"
  ;;
end

module Size = struct
  type t =
    | Default
    | Sm
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Sm -> "sm"
  ;;

  let classes = function
    | Default -> "gap-4 p-4"
    | Sm -> "gap-2.5 px-4 py-3"
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
    | Default -> "bg-transparent"
    | Icon -> "size-8 rounded-sm border bg-muted [&_svg:not([class*='size-'])]:size-4"
    | Image -> "size-10 overflow-hidden rounded-sm [&_img]:size-full [&_img]:object-cover"
  ;;
end

let base =
  "group/item flex flex-wrap items-center rounded-md border border-transparent text-sm \
   transition-colors duration-100 outline-none focus-visible:border-ring \
   focus-visible:ring-[3px] focus-visible:ring-ring/50 [a]:transition-colors \
   [a]:hover:bg-accent/50"
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
       ; Cn.with_class ?class_ [ "group/item-group flex flex-col" ]
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
           [ "shrink-0 bg-border data-[orientation=horizontal]:h-px \
              data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full \
              data-[orientation=vertical]:w-px"
           ; "my-0"
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
           [ "flex shrink-0 items-center justify-center gap-2 \
              group-has-[[data-slot=item-description]]/item:translate-y-0.5 \
              group-has-[[data-slot=item-description]]/item:self-start \
              [&_svg]:pointer-events-none"
           ; Media_variant.classes variant
           ]
       ]
       @ attrs)
    children
;;

let content =
  div "item-content" "flex flex-1 flex-col gap-1 [&+[data-slot=item-content]]:flex-none"
;;

let title =
  div "item-title" "flex w-fit items-center gap-2 text-sm leading-snug font-medium"
;;

let description ?(attrs = []) ?class_ children =
  Node.p
    ~attrs:
      ([ data "slot" "item-description"
       ; Cn.with_class
           ?class_
           [ "line-clamp-2 text-sm leading-normal font-normal text-balance \
              text-muted-foreground"
           ; "[&>a]:underline [&>a]:underline-offset-4 [&>a:hover]:text-primary"
           ]
       ]
       @ attrs)
    children
;;

let actions = div "item-actions" "flex items-center gap-2"
let header = div "item-header" "flex basis-full items-center justify-between gap-2"
let footer = div "item-footer" "flex basis-full items-center justify-between gap-2"
