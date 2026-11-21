open! Core
open Bonsai_web
module Node = Vdom.Node
module Attr = Vdom.Attr
module Cn = Loon.Cn

module Variant = struct
  type t =
    | Default
    | Outline
    | Ghost
end

module Size = struct
  type t =
    | Default
    | Sm
    | Lg
    | Icon
    | Icon_sm
end

let button_base =
  "group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap \
   transition-all outline-none select-none disabled:pointer-events-none \
   disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 \
   focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 \
   dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive \
   dark:aria-invalid:border-destructive/50 rounded-lg border border-transparent \
   bg-clip-padding text-sm font-medium focus-visible:ring-3 aria-invalid:ring-3 \
   active:not-aria-[haspopup]:translate-y-px [&_svg:not([class*='size-'])]:size-4"
;;

let variant_classes : Variant.t -> string = function
  | Default -> "bg-primary text-primary-foreground hover:bg-primary/80"
  | Outline ->
    "border-border bg-background hover:bg-muted hover:text-foreground dark:bg-input/30 \
     dark:border-input dark:hover:bg-input/50 aria-expanded:bg-muted \
     aria-expanded:text-foreground"
  | Ghost ->
    "hover:bg-muted hover:text-foreground dark:hover:bg-muted/50 aria-expanded:bg-muted \
     aria-expanded:text-foreground"
;;

let size_classes : Size.t -> string = function
  | Default ->
    "h-8 gap-1.5 px-2.5 has-data-[icon=inline-end]:pr-2 has-data-[icon=inline-start]:pl-2"
  | Sm ->
    "h-7 gap-1 rounded-[min(var(--radius-md),12px)] px-2.5 text-[0.8rem] \
     in-data-[slot=button-group]:rounded-lg has-data-[icon=inline-end]:pr-1.5 \
     has-data-[icon=inline-start]:pl-1.5 [&_svg:not([class*='size-'])]:size-3.5"
  | Lg ->
    "h-9 gap-1.5 px-2.5 has-data-[icon=inline-end]:pr-2 has-data-[icon=inline-start]:pl-2"
  | Icon -> "size-8"
  | Icon_sm ->
    "size-7 rounded-[min(var(--radius-md),12px)] in-data-[slot=button-group]:rounded-lg"
;;

let button_classes ?(variant = Variant.Default) ?(size = Size.Default) ?class_ () =
  Cn.cn
    ([ button_base; variant_classes variant; size_classes size ] @ Option.to_list class_)
;;

let button
  ?(attrs = [])
  ?class_
  ?variant
  ?size
  ?(disabled = false)
  ?(on_click = Effect.Ignore)
  children
  =
  Node.button
    ~attrs:
      ([ Attr.type_ "button"
       ; Attr.create "data-slot" "button"
       ; Attr.class_ (button_classes ?variant ?size ?class_ ())
       ; Attr.on_click (fun _ -> on_click)
       ]
       @ (if disabled then [ Attr.disabled ] else [])
       @ attrs)
    children
;;

let part ~slot ~base ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ Attr.create "data-slot" slot
       ; Attr.class_ (Cn.cn (base :: Option.to_list class_))
       ]
       @ attrs)
    children
;;

let card ?(attrs = []) =
  part
    ~slot:"card"
    ~base:
      "group/card flex flex-col ring-foreground/10 bg-card text-card-foreground \
       gap-(--card-spacing) overflow-hidden rounded-xl py-(--card-spacing) text-sm ring-1 \
       [--card-spacing:--spacing(4)] has-data-[slot=card-footer]:pb-0 \
       has-[>img:first-child]:pt-0 data-[size=sm]:[--card-spacing:--spacing(3)] \
       data-[size=sm]:has-data-[slot=card-footer]:pb-0 *:[img:first-child]:rounded-t-xl \
       *:[img:last-child]:rounded-b-xl"
    ~attrs:(Attr.create "data-size" "sm" :: attrs)
;;

let card_header =
  part
    ~slot:"card-header"
    ~base:
      "group/card-header @container/card-header grid auto-rows-min items-start \
       has-data-[slot=card-action]:grid-cols-[1fr_auto] \
       has-data-[slot=card-description]:grid-rows-[auto_auto] gap-1 rounded-t-xl \
       px-(--card-spacing) [.border-b]:pb-(--card-spacing)"
;;

let card_content = part ~slot:"card-content" ~base:"px-(--card-spacing)"

let card_footer =
  part
    ~slot:"card-footer"
    ~base:"flex items-center bg-muted/50 rounded-b-xl border-t p-(--card-spacing)"
;;

let field_group =
  part
    ~slot:"field-group"
    ~base:
      "group/field-group @container/field-group flex w-full flex-col gap-5 \
       data-[slot=checkbox-group]:gap-3 *:data-[slot=field-group]:gap-4"
;;

let field_separator ?class_ () =
  Node.div
    ~attrs:
      [ Attr.create "data-slot" "field-separator"
      ; Attr.create "data-content" "false"
      ; Attr.class_
          (Cn.cn
             ("relative -my-2 h-5 text-sm group-data-[variant=outline]/field-group:-mb-2"
              :: Option.to_list class_))
      ]
    [ Node.div
        ~attrs:
          [ Attr.create "data-slot" "separator"
          ; Attr.create "data-orientation" "horizontal"
          ; Attr.role "none"
          ; Attr.class_
              "bg-border shrink-0 data-[orientation=horizontal]:h-px \
               data-[orientation=horizontal]:w-full absolute inset-0 top-1/2"
          ]
        []
    ]
;;

let dialog_content_class =
  "bg-popover text-popover-foreground ring-foreground/10 grid max-w-[calc(100%-2rem)] \
   gap-4 rounded-xl border-0 p-4 text-sm ring-1 duration-100 sm:max-w-sm"
;;

let dialog_footer_class = "bg-muted/50 -mx-4 -mb-4 rounded-b-xl border-t p-4"
let dialog_title_class = "text-base leading-none font-medium"

let input_class =
  "dark:bg-input/30 border-input focus-visible:border-ring focus-visible:ring-ring/50 \
   aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 \
   aria-invalid:border-destructive dark:aria-invalid:border-destructive/50 \
   disabled:bg-input/50 dark:disabled:bg-input/80 h-8 rounded-lg border bg-transparent \
   px-2.5 py-1 text-base transition-colors file:h-6 file:text-sm file:font-medium \
   focus-visible:ring-3 aria-invalid:ring-3 md:text-sm"
;;

let is_mobile () =
  let open Js_of_ocaml in
  try
    Js.Optdef.test (Js.Unsafe.global##.matchMedia : _ Js.Optdef.t)
    && Js.to_bool
         (Js.Unsafe.meth_call
            Dom_html.window
            "matchMedia"
            [| Js.Unsafe.inject (Js.string "(max-width: 767px)") |])##.matches
  with
  | _ -> false
;;
