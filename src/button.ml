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
    | Default -> "bg-primary text-primary-foreground hover:bg-primary/90"
    | Destructive ->
      "bg-destructive text-white hover:bg-destructive/90 focus-visible:ring-destructive/20 \
       dark:bg-destructive/60 dark:focus-visible:ring-destructive/40"
    | Outline ->
      "border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground \
       dark:border-input dark:bg-input/30 dark:hover:bg-input/50"
    | Secondary -> "bg-secondary text-secondary-foreground hover:bg-secondary/80"
    | Ghost -> "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50"
    | Link -> "text-primary underline-offset-4 hover:underline"
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
    | Default -> "h-9 px-4 py-2 has-[>svg]:px-3"
    | Xs ->
      "h-6 gap-1 rounded-md px-2 text-xs has-[>svg]:px-1.5 \
       [&_svg:not([class*='size-'])]:size-3"
    | Sm -> "h-8 gap-1.5 rounded-md px-3 has-[>svg]:px-2.5"
    | Lg -> "h-10 rounded-md px-6 has-[>svg]:px-4"
    | Icon -> "size-9"
    | Icon_xs -> "size-6 rounded-md [&_svg:not([class*='size-'])]:size-3"
    | Icon_sm -> "size-8"
    | Icon_lg -> "size-10"
  ;;
end

let base =
  "inline-flex shrink-0 items-center justify-center gap-2 rounded-md text-sm font-medium \
   whitespace-nowrap transition-all outline-none focus-visible:border-ring \
   focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none \
   disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 \
   dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0 \
   [&_svg:not([class*='size-'])]:size-4"
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
