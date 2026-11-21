open! Import

let view ?(attrs = []) ?class_ children =
  Node.create
    "kbd"
    ~attrs:
      ([ data "slot" "kbd"
       ; Cn.with_class
           ?class_
           [ "pointer-events-none inline-flex h-5 w-fit min-w-5 items-center \
              justify-center gap-1 rounded-sm bg-muted px-1 font-sans text-xs \
              font-medium text-muted-foreground select-none"
           ; "[&_svg:not([class*='size-'])]:size-3"
           ; "[[data-slot=tooltip-content]_&]:bg-background/20 \
              [[data-slot=tooltip-content]_&]:text-background \
              dark:[[data-slot=tooltip-content]_&]:bg-background/10"
           ]
       ]
       @ attrs)
    children
;;

let group ?(attrs = []) ?class_ children =
  Node.create
    "kbd"
    ~attrs:
      ([ data "slot" "kbd-group"; Cn.with_class ?class_ [ "inline-flex items-center gap-1" ] ]
       @ attrs)
    children
;;
