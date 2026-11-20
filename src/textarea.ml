open! Import

let view
  ?attrs:extra
  ?placeholder
  ?(rows = 3)
  ?(disabled = false)
  ?(invalid = false)
  ~value
  ~on_input
  ()
  =
  Node.textarea
    ~attrs:
      (attrs ?attrs:extra [ "loon-textarea" ]
       @ [ Attr.rows rows; Attr.value value; Attr.on_input (fun _ s -> on_input s) ]
       @ Option.value_map placeholder ~default:[] ~f:(fun p -> [ Attr.placeholder p ])
       @ (if disabled then [ Attr.disabled ] else [])
       @ if invalid then [ aria "invalid" "true" ] else [])
    []
;;

let component ?attrs ?placeholder ?rows ?disabled ?(default = "") (local_ graph) =
  Control.make
    ~equal:String.equal
    default
    ~view:(fun value set ->
      view ?attrs ?placeholder ?rows ?disabled ~value ~on_input:set ())
    graph
;;
