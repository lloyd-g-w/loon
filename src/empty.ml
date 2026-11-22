open! Import

module Media_variant = struct
  type t =
    | Default
    | Icon
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Icon -> "icon"
  ;;

  let classes = function
    | Default -> "cn-empty-media-default"
    | Icon ->
      "cn-empty-media-icon"
  ;;
end

let div slot classes ?(attrs = []) ?class_ children =
  Node.div ~attrs:([ data "slot" slot; Cn.with_class ?class_ [ classes ] ] @ attrs) children
;;

let root =
  div
    "empty"
    "cn-empty flex w-full min-w-0 flex-1 flex-col items-center justify-center text-center \
     text-balance"
;;

let header = div "empty-header" "cn-empty-header flex max-w-sm flex-col items-center"

let media ?(attrs = []) ?class_ ?(variant = Media_variant.Default) children =
  Node.div
    ~attrs:
      ([ data "slot" "empty-icon"
       ; data "variant" (Media_variant.name variant)
       ; Cn.with_class
           ?class_
           [ "cn-empty-media flex shrink-0 items-center justify-center \
              [&_svg]:pointer-events-none [&_svg]:shrink-0"
           ; Media_variant.classes variant
           ]
       ]
       @ attrs)
    children
;;

let title = div "empty-title" "cn-empty-title cn-font-heading"

let description =
  div
    "empty-description"
    "cn-empty-description text-muted-foreground [&>a]:underline [&>a]:underline-offset-4 \
     [&>a:hover]:text-primary"
;;

let content =
  div
    "empty-content"
    "cn-empty-content flex w-full max-w-sm min-w-0 flex-col items-center text-balance"
;;
