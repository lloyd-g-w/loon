open! Import

module Size = struct
  type t =
    | Default
    | Sm
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Sm -> "sm"
  ;;
end

let view
  ?(attrs = [])
  ?class_
  ?(size = Size.Default)
  ?id
  ?(disabled = false)
  ?(required = false)
  ?(invalid = false)
  ~checked
  ~on_change
  ()
  =
  let state = data "state" (if checked then "checked" else "unchecked") in
  let disabled_attrs = if disabled then [ data "disabled" "" ] else [] in
  Node.button
    ~attrs:
      ([ Attr.type_ "button"
       ; Attr.role "switch"
       ; aria_bool "checked" checked
       ]
       (* Radix leaves aria-required out unless [required] is given. *)
       @ (if required then [ aria "required" "true" ] else [])
       @ [ state
         ; Attr.value "on"
         ; data "slot" "switch"
         ; data "size" (Size.name size)
         ; Cn.with_class
             ?class_
             [ "cn-switch peer group/switch relative inline-flex items-center \
                transition-all outline-none after:absolute after:-inset-x-3 \
                after:-inset-y-2 data-disabled:cursor-not-allowed \
                data-disabled:opacity-50"
             ]
         ]
       @ Option.value_map id ~default:[] ~f:(fun id -> [ Attr.id id ])
       @ (if invalid then [ aria "invalid" "true" ] else [])
       @ disabled_attrs
       @ (if disabled
          then [ Attr.disabled ]
          else [ Attr.on_click (fun _ -> on_change (not checked)) ])
       @ attrs)
    [ Node.span
        ~attrs:
          ([ state
           ; data "slot" "switch-thumb"
           ; Attr.class_
               "cn-switch-thumb pointer-events-none block ring-0 transition-transform"
           ]
           @ disabled_attrs)
        []
    ]
;;

let component
  ?attrs
  ?class_
  ?size
  ?id
  ?disabled
  ?required
  ?invalid
  ?(default_checked = false)
  (local_ graph)
  =
  Control.make ~equal:Bool.equal default_checked graph ~view:(fun checked set ->
    view ?attrs ?class_ ?size ?id ?disabled ?required ?invalid ~checked ~on_change:set ())
;;
