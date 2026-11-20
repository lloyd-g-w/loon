open! Import

let view ?attrs:extra ?(side = Floating.Side.Top) ~id ~content trigger =
  Node.span
    ~attrs:
      (attrs ?attrs:extra [ "loon-tooltip" ]
       @ [ data "side" (Floating.Side.name side) ])
    [ trigger [ aria "describedby" id ]
    ; Node.span
        ~attrs:
          [ Attr.class_ "loon-tooltip-content"
          ; Attr.role "tooltip"
          ; Attr.id id
          ]
        [ Node.text content ]
    ]
;;
