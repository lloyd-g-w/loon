open! Import

let root ?(attrs = []) ?class_ children =
  Node.create
    "nav"
    ~attrs:
      ([ aria "label" "breadcrumb"; data "slot" "breadcrumb" ]
       @ Option.value_map class_ ~default:[] ~f:(fun c -> [ Cn.attr [ c ] ])
       @ attrs)
    children
;;

let list ?(attrs = []) ?class_ children =
  Node.ol
    ~attrs:
      ([ data "slot" "breadcrumb-list"
       ; Cn.with_class
           ?class_
           [ "flex flex-wrap items-center gap-1.5 text-sm break-words \
              text-muted-foreground sm:gap-2.5"
           ]
       ]
       @ attrs)
    children
;;

let item ?(attrs = []) ?class_ children =
  Node.li
    ~attrs:
      ([ data "slot" "breadcrumb-item"
       ; Cn.with_class ?class_ [ "inline-flex items-center gap-1.5" ]
       ]
       @ attrs)
    children
;;

let link_base = "transition-colors hover:text-foreground"
let link_classes ?class_ () = Cn.cn (link_base :: Option.to_list class_)

let link ?(attrs = []) ?class_ ~href children =
  Node.a
    ~attrs:
      ([ data "slot" "breadcrumb-link"; Attr.href href; Cn.with_class ?class_ [ link_base ] ]
       @ attrs)
    children
;;

let page ?(attrs = []) ?class_ children =
  Node.span
    ~attrs:
      ([ data "slot" "breadcrumb-page"
       ; Attr.role "link"
       ; aria "disabled" "true"
       ; aria "current" "page"
       ; Cn.with_class ?class_ [ "font-normal text-foreground" ]
       ]
       @ attrs)
    children
;;

let separator ?(attrs = []) ?class_ ?children () =
  Node.li
    ~attrs:
      ([ data "slot" "breadcrumb-separator"
       ; Attr.role "presentation"
       ; aria "hidden" "true"
       ; Cn.with_class ?class_ [ "[&>svg]:size-3.5" ]
       ]
       @ attrs)
    (Option.value children ~default:[ Icon.view Chevron_right ])
;;

let ellipsis ?(attrs = []) ?class_ () =
  Node.span
    ~attrs:
      ([ data "slot" "breadcrumb-ellipsis"
       ; Attr.role "presentation"
       ; aria "hidden" "true"
       ; Cn.with_class ?class_ [ "flex size-9 items-center justify-center" ]
       ]
       @ attrs)
    [ Icon.view ~class_:"size-4" Ellipsis
    ; Node.span ~attrs:[ Attr.class_ "sr-only" ] [ Node.text "More" ]
    ]
;;
