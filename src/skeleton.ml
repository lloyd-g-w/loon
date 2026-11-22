open! Import

let view ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ data "slot" "skeleton"
       ; Cn.with_class ?class_ [ "cn-skeleton animate-pulse" ]
       ]
       @ attrs)
    children
;;
