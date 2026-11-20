open! Import

module Align = struct
  type t =
    | Left
    | Center
    | Right
  [@@deriving enumerate, sexp_of, compare, equal]

  let attr t = data "align" (String.lowercase (Sexp.to_string (sexp_of_t t)))
end

let flag cond cls = if cond then [ cls ] else []

let table ?attrs:extra ?(striped = false) ?(hover = true) ?(dense = false) ?caption parts =
  Node.div
    ~attrs:[ Attr.class_ "loon-table-container" ]
    [ Node.table
        ~attrs:
          (attrs
             ?attrs:extra
             (("loon-table" :: flag striped "loon-table-striped")
              @ flag hover "loon-table-hover"
              @ flag dense "loon-table-dense"))
        (Option.value_map caption ~default:[] ~f:(fun c ->
           [ Node.create "caption" ~attrs:[ Attr.class_ "loon-table-caption" ] [ Node.text c ] ])
         @ parts)
    ]
;;

let header ?attrs:extra rows = Node.thead ~attrs:(attrs ?attrs:extra [ "loon-table-header" ]) rows
let body ?attrs:extra rows = Node.tbody ~attrs:(attrs ?attrs:extra [ "loon-table-body" ]) rows
let footer ?attrs:extra rows = Node.tfoot ~attrs:(attrs ?attrs:extra [ "loon-table-footer" ]) rows

let row ?attrs:extra ?key ?(selected = false) cells =
  Node.tr
    ?key
    ~attrs:
      (attrs ?attrs:extra [ "loon-table-row" ]
       @ if selected then [ data "state" "selected"; aria "selected" "true" ] else [])
    cells
;;

let head ?attrs:extra ?(align = Align.Left) children =
  Node.th
    ~attrs:(attrs ?attrs:extra [ "loon-table-head" ] @ [ Attr.create "scope" "col"; Align.attr align ])
    children
;;

let cell ?attrs:extra ?(align = Align.Left) ?colspan children =
  Node.td
    ~attrs:
      (attrs ?attrs:extra [ "loon-table-cell" ]
       @ (Align.attr align :: Option.value_map colspan ~default:[] ~f:(fun c -> [ Attr.colspan c ])))
    children
;;

module Column = struct
  type 'row t =
    { header : string
    ; align : Align.t
    ; cell : 'row -> Node.t
    }

  let create ?(align = Align.Left) header cell = { header; align; cell }
  let text ?align header f = create ?align header (fun r -> Node.text (f r))
end

let view ?attrs ?striped ?hover ?dense ?caption ?footer:foot ~columns rows =
  table
    ?attrs
    ?striped
    ?hover
    ?dense
    ?caption
    ([ header
         [ row
             (List.map columns ~f:(fun (c : _ Column.t) ->
                head ~align:c.align [ Node.text c.header ]))
         ]
     ; body
         (List.map rows ~f:(fun r ->
            row
              (List.map columns ~f:(fun (c : _ Column.t) -> cell ~align:c.align [ c.cell r ]))))
     ]
     @ Option.value_map foot ~default:[] ~f:(fun cells -> [ footer [ row cells ] ]))
;;
