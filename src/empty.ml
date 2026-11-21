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
    | Default -> "bg-transparent"
    | Icon ->
      "flex size-10 shrink-0 items-center justify-center rounded-lg bg-muted \
       text-foreground [&_svg:not([class*='size-'])]:size-6"
  ;;
end

let div slot classes ?(attrs = []) ?class_ children =
  Node.div ~attrs:([ data "slot" slot; Cn.with_class ?class_ [ classes ] ] @ attrs) children
;;

let root =
  div
    "empty"
    "flex min-w-0 flex-1 flex-col items-center justify-center gap-6 rounded-lg \
     border-dashed p-6 text-center text-balance md:p-12"
;;

let header = div "empty-header" "flex max-w-sm flex-col items-center gap-2 text-center"

let media ?(attrs = []) ?class_ ?(variant = Media_variant.Default) children =
  Node.div
    ~attrs:
      ([ data "slot" "empty-icon"
       ; data "variant" (Media_variant.name variant)
       ; Cn.with_class
           ?class_
           [ "mb-2 flex shrink-0 items-center justify-center [&_svg]:pointer-events-none \
              [&_svg]:shrink-0"
           ; Media_variant.classes variant
           ]
       ]
       @ attrs)
    children
;;

let title = div "empty-title" "text-lg font-medium tracking-tight"

let description =
  div
    "empty-description"
    "text-sm/relaxed text-muted-foreground [&>a]:underline [&>a]:underline-offset-4 \
     [&>a:hover]:text-primary"
;;

let content =
  div
    "empty-content"
    "flex w-full max-w-sm min-w-0 flex-col items-center gap-4 text-sm text-balance"
;;
