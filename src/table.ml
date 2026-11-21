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
      ; Attr.class_ "relative w-full overflow-x-auto"
      ]
    [ Node.table
        ~attrs:
          ([ data "slot" "table"
           ; Cn.with_class ?class_ [ "w-full caption-bottom text-sm" ]
           ]
           @ attrs)
        children
    ]
;;

let header = part "thead" "table-header" "[&_tr]:border-b"
let body = part "tbody" "table-body" "[&_tr:last-child]:border-0"

let footer =
  part
    "tfoot"
    "table-footer"
    "border-t bg-muted/50 font-medium [&>tr]:last:border-b-0"
;;

let row ?(attrs = []) ?class_ ?(selected = false) children =
  part
    "tr"
    "table-row"
    "border-b transition-colors hover:bg-muted/50 \
     has-aria-expanded:bg-muted/50 data-[state=selected]:bg-muted"
    ~attrs:((if selected then [ data "state" "selected" ] else []) @ attrs)
    ?class_
    children
;;

let head =
  part
    "th"
    "table-head"
    "h-10 px-2 text-left align-middle font-medium whitespace-nowrap \
     text-foreground [&:has([role=checkbox])]:pr-0 \
     [&>[role=checkbox]]:translate-y-[2px]"
;;

let cell ?(attrs = []) ?class_ ?col_span children =
  part
    "td"
    "table-cell"
    "p-2 align-middle whitespace-nowrap [&:has([role=checkbox])]:pr-0 \
     [&>[role=checkbox]]:translate-y-[2px]"
    ~attrs:
      (Option.value_map col_span ~default:[] ~f:(fun n ->
         [ Attr.create "colspan" (Int.to_string n) ])
       @ attrs)
    ?class_
    children
;;

let caption =
  part "caption" "table-caption" "mt-4 text-sm text-muted-foreground"
;;
