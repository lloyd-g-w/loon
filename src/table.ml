open! Import

let part tag slot classes ?(attrs = []) ?class_ children =
  Node.create
    tag
    ~attrs:([ data "slot" slot; Cn.with_class ?class_ [ classes ] ] @ attrs)
    children
;;

let root ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      [ data "slot" "table-container"
      ; Attr.class_ "cn-table-container"
      ]
    [ Node.table
        ~attrs:
          ([ data "slot" "table"
           ; Cn.with_class ?class_ [ "cn-table" ]
           ]
           @ attrs)
        children
    ]
;;

let header = part "thead" "table-header" "cn-table-header"
let body = part "tbody" "table-body" "cn-table-body"

let footer =
  part
    "tfoot"
    "table-footer"
    "cn-table-footer"
;;

let row ?(attrs = []) ?class_ ?(selected = false) children =
  part
    "tr"
    "table-row"
    "cn-table-row has-aria-expanded:bg-muted/50"
    ~attrs:((if selected then [ data "state" "selected" ] else []) @ attrs)
    ?class_
    children
;;

let head =
  part
    "th"
    "table-head"
    "cn-table-head"
;;

let cell ?(attrs = []) ?class_ ?col_span children =
  part
    "td"
    "table-cell"
    "cn-table-cell"
    ~attrs:
      (Option.value_map col_span ~default:[] ~f:(fun n ->
         [ Attr.create "colspan" (Int.to_string n) ])
       @ attrs)
    ?class_
    children
;;

let caption =
  part "caption" "table-caption" "cn-table-caption"
;;
