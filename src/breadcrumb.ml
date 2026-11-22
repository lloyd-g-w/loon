open! Import

let root ?(attrs = []) ?class_ children =
  Node.create
    "nav"
    ~attrs:
      ([ aria "label" "breadcrumb"
       ; data "slot" "breadcrumb"
       ; Cn.with_class ?class_ [ "cn-breadcrumb" ]
       ]
       @ attrs)
    children
;;

let list ?(attrs = []) ?class_ children =
  Node.ol
    ~attrs:
      ([ data "slot" "breadcrumb-list"
       ; Cn.with_class
           ?class_
           [ "cn-breadcrumb-list flex flex-wrap items-center wrap-break-word" ]
       ]
       @ attrs)
    children
;;

let item ?(attrs = []) ?class_ children =
  Node.li
    ~attrs:
      ([ data "slot" "breadcrumb-item"
       ; Cn.with_class ?class_ [ "cn-breadcrumb-item inline-flex items-center" ]
       ]
       @ attrs)
    children
;;

let link_base = "cn-breadcrumb-link"
let link_classes ?class_ () = Cn.cn (link_base :: Option.to_list class_)

let link ?(attrs = []) ?class_ ~href children =
  Node.a
    ~attrs:
      ([ data "slot" "breadcrumb-link"
       ; Attr.href href
       ; Cn.with_class ?class_ [ link_base ]
       ]
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
       ; Cn.with_class ?class_ [ "cn-breadcrumb-page" ]
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
       ; Cn.with_class ?class_ [ "cn-breadcrumb-separator" ]
       ]
       @ attrs)
    (Option.value children ~default:[ Icon.view ~class_:"cn-rtl-flip" Chevron_right ])
;;

let ellipsis ?(attrs = []) ?class_ () =
  Node.span
    ~attrs:
      ([ data "slot" "breadcrumb-ellipsis"
       ; Attr.role "presentation"
       ; aria "hidden" "true"
       ; Cn.with_class
           ?class_
           [ "cn-breadcrumb-ellipsis flex items-center justify-center" ]
       ]
       @ attrs)
    [ Icon.view Ellipsis
    ; Node.span ~attrs:[ Attr.class_ "sr-only" ] [ Node.text "More" ]
    ]
;;
