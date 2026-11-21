open! Import

let class_list ?class_ () =
  [ "flex field-sizing-content min-h-16 w-full rounded-md border border-input \
     bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] \
     outline-none placeholder:text-muted-foreground focus-visible:border-ring \
     focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:cursor-not-allowed \
     disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 \
     md:text-sm dark:bg-input/30 dark:aria-invalid:ring-destructive/40"
  ]
  @ Option.to_list class_
;;

let classes ?class_ () = Cn.cn (class_list ?class_ ())

let view
  ?(attrs = [])
  ?class_
  ?id
  ?name
  ?placeholder
  ?rows
  ?(disabled = false)
  ?(required = false)
  ?(invalid = false)
  ?value
  ?on_input
  ()
  =
  let opt f = Option.value_map ~default:[] ~f:(fun x -> [ f x ]) in
  Node.textarea
    ~attrs:
      ([ data "slot" "textarea"; Cn.attr (class_list ?class_ ()) ]
       @ opt Attr.id id
       @ opt Attr.name name
       @ opt Attr.placeholder placeholder
       @ opt Attr.rows rows
       @ (if disabled then [ Attr.disabled ] else [])
       @ (if required then [ Attr.create "required" "" ] else [])
       @ (if invalid then [ aria "invalid" "true" ] else [])
       @ opt Attr.value value
       @ opt (fun f -> Attr.on_input (fun _ s -> f s)) on_input
       @ attrs)
    []
;;

let component
  ?attrs
  ?class_
  ?id
  ?name
  ?placeholder
  ?rows
  ?disabled
  ?required
  ?invalid
  ?(default_value = "")
  (local_ graph)
  =
  Control.make ~equal:String.equal default_value graph ~view:(fun value set ->
    view
      ?attrs
      ?class_
      ?id
      ?name
      ?placeholder
      ?rows
      ?disabled
      ?required
      ?invalid
      ~value
      ~on_input:set
      ())
;;
