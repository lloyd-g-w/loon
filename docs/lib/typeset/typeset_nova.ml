let card =
  "group/card flex flex-col gap-(--card-spacing) overflow-hidden rounded-xl \
   bg-card py-(--card-spacing) text-sm text-card-foreground ring-1 \
   ring-foreground/10 [--card-spacing:--spacing(4)] \
   has-data-[slot=card-footer]:pb-0 has-[>img:first-child]:pt-0 \
   data-[size=sm]:[--card-spacing:--spacing(3)] \
   data-[size=sm]:has-data-[slot=card-footer]:pb-0 \
   *:[img:first-child]:rounded-t-xl *:[img:last-child]:rounded-b-xl"
;;

let card_header =
  "group/card-header @container/card-header grid auto-rows-min items-start \
   gap-1 rounded-t-xl px-(--card-spacing) \
   has-data-[slot=card-action]:grid-cols-[1fr_auto] \
   has-data-[slot=card-description]:grid-rows-[auto_auto] \
   [.border-b]:pb-(--card-spacing)"
;;

let card_content = "px-(--card-spacing)"

let card_footer =
  "flex items-center rounded-b-xl border-t bg-muted/50 p-(--card-spacing)"
;;

let field_group =
  "group/field-group @container/field-group flex w-full flex-col gap-5 \
   data-[slot=checkbox-group]:gap-3 *:data-[slot=field-group]:gap-4"
;;

let field_separator =
  "relative -my-2 h-5 text-sm group-data-[variant=outline]/field-group:-mb-2"
;;

module Button = struct
  type variant =
    | Outline
    | Ghost
    | Link

  type size =
    | Default
    | Sm

  let base =
    "group/button inline-flex shrink-0 items-center justify-center rounded-lg \
     border border-transparent bg-clip-padding text-sm font-medium \
     whitespace-nowrap transition-all outline-none select-none \
     focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 \
     active:not-aria-[haspopup]:translate-y-px disabled:pointer-events-none \
     disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-3 \
     aria-invalid:ring-destructive/20 dark:aria-invalid:border-destructive/50 \
     dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none \
     [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
  ;;

  let variant = function
    | Outline ->
      "border-border bg-background hover:bg-muted hover:text-foreground \
       aria-expanded:bg-muted aria-expanded:text-foreground dark:border-input \
       dark:bg-input/30 dark:hover:bg-input/50"
    | Ghost ->
      "hover:bg-muted hover:text-foreground aria-expanded:bg-muted \
       aria-expanded:text-foreground dark:hover:bg-muted/50"
    | Link -> "text-primary underline-offset-4 hover:underline"
  ;;

  let size = function
    | Default ->
      "h-8 gap-1.5 px-2.5 has-data-[icon=inline-end]:pr-2 \
       has-data-[icon=inline-start]:pl-2"
    | Sm ->
      "h-7 gap-1 rounded-[min(var(--radius-md),12px)] px-2.5 text-[0.8rem] \
       in-data-[slot=button-group]:rounded-lg \
       has-data-[icon=inline-end]:pr-1.5 has-data-[icon=inline-start]:pl-1.5 \
       [&_svg:not([class*='size-'])]:size-3.5"
  ;;

  let classes ?class_ v s =
    Loon.Cn.cn ([ base; variant v; size s ] @ Option.to_list class_)
  ;;
end
