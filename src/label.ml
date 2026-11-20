open! Import

let view ?attrs:extra ?for_ ?(required = false) children =
  Node.label
    ~attrs:
      (attrs ?attrs:extra [ "loon-label" ]
       @ Option.value_map for_ ~default:[] ~f:(fun id -> [ Attr.for_ id ]))
    (children
     @
     if required
     then [ Node.span ~attrs:[ Attr.class_ "loon-label-required"; aria "hidden" "true" ] [ Node.text "*" ] ]
     else [])
;;

let text ?attrs ?for_ ?required s = view ?attrs ?for_ ?required [ Node.text s ]
