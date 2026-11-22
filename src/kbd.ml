open! Import

let view ?(attrs = []) ?class_ children =
  Node.create
    "kbd"
    ~attrs:
      ([ data "slot" "kbd"
       ; Cn.with_class
           ?class_
           [ "cn-kbd pointer-events-none inline-flex items-center justify-center \
              select-none"
           ]
       ]
       @ attrs)
    children
;;

let group ?(attrs = []) ?class_ children =
  Node.create
    "kbd"
    ~attrs:
      ([ data "slot" "kbd-group"
       ; Cn.with_class ?class_ [ "cn-kbd-group inline-flex items-center" ]
       ]
       @ attrs)
    children
;;
