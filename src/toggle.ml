open! Import

module Variant = struct
  type t =
    | Default
    | Outline
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Outline -> "outline"
  ;;

  let classes = function
    | Default -> "bg-transparent"
    | Outline ->
      "border border-input bg-transparent shadow-xs hover:bg-accent \
       hover:text-accent-foreground"
  ;;
end

module Size = struct
  type t =
    | Default
    | Sm
    | Lg
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Sm -> "sm"
    | Lg -> "lg"
  ;;

  let classes = function
    | Default -> "h-9 min-w-9 px-2"
    | Sm -> "h-8 min-w-8 px-1.5"
    | Lg -> "h-10 min-w-10 px-2.5"
  ;;
end

let base =
  "inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium \
   whitespace-nowrap transition-[color,box-shadow] outline-none hover:bg-muted \
   hover:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] \
   focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 \
   aria-invalid:border-destructive aria-invalid:ring-destructive/20 \
   data-[state=on]:bg-accent data-[state=on]:text-accent-foreground \
   dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0 \
   [&_svg:not([class*='size-'])]:size-4"
;;

let class_list ?(variant = Variant.Default) ?(size = Size.Default) ?class_ () =
  [ base; Variant.classes variant; Size.classes size ] @ Option.to_list class_
;;

let classes ?variant ?size ?class_ () = Cn.cn (class_list ?variant ?size ?class_ ())

let view ?(attrs = []) ?class_ ?variant ?size ?(disabled = false) ~pressed ~on_change children
  =
  Node.button
    ~attrs:
      ([ Attr.type_ "button"
       ; aria_bool "pressed" pressed
       ; data "state" (if pressed then "on" else "off")
       ; data "slot" "toggle"
       ; Cn.attr (class_list ?variant ?size ?class_ ())
       ]
       @ (if disabled
          then [ data "disabled" ""; Attr.disabled ]
          else [ Attr.on_click (fun _ -> on_change (not pressed)) ])
       @ attrs)
    children
;;

let component
  ?attrs
  ?class_
  ?variant
  ?size
  ?disabled
  ?(default_pressed = false)
  children
  (local_ graph)
  =
  Control.make ~equal:Bool.equal default_pressed graph ~view:(fun pressed set ->
    view ?attrs ?class_ ?variant ?size ?disabled ~pressed ~on_change:set children)
;;
