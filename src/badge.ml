open! Import

module Variant = struct
  type t =
    | Default
    | Secondary
    | Destructive
    | Outline
    | Ghost
    | Link
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Secondary -> "secondary"
    | Destructive -> "destructive"
    | Outline -> "outline"
    | Ghost -> "ghost"
    | Link -> "link"
  ;;

  let classes = function
    | Default -> "cn-badge-variant-default"
    | Secondary -> "cn-badge-variant-secondary"
    | Destructive -> "cn-badge-variant-destructive"
    | Outline -> "cn-badge-variant-outline"
    | Ghost -> "cn-badge-variant-ghost"
    | Link -> "cn-badge-variant-link"
  ;;
end

let base =
  "cn-badge group/badge inline-flex w-fit shrink-0 items-center justify-center \
   overflow-hidden whitespace-nowrap focus-visible:border-ring focus-visible:ring-[3px] \
   focus-visible:ring-ring/50 aria-invalid:border-destructive \
   aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 \
   [&>svg]:pointer-events-none"
;;

let class_list ?(variant = Variant.Default) ?class_ () =
  [ base; Variant.classes variant ] @ Option.to_list class_
;;

let classes ?variant ?class_ () = Cn.cn (class_list ?variant ?class_ ())

let attrs_of ?(variant = Variant.Default) ?class_ attrs =
  [ data "slot" "badge"
  ; data "variant" (Variant.name variant)
  ; Cn.attr (class_list ~variant ?class_ ())
  ]
  @ attrs
;;

let view ?(attrs = []) ?class_ ?variant children =
  Node.span ~attrs:(attrs_of ?variant ?class_ attrs) children
;;

let link ?(attrs = []) ?class_ ?variant ~href children =
  Node.a ~attrs:(Attr.href href :: attrs_of ?variant ?class_ attrs) children
;;
