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
             [ "peer group/switch inline-flex shrink-0 items-center rounded-full border \
                border-transparent shadow-xs transition-all outline-none \
                focus-visible:border-ring focus-visible:ring-[3px] \
                focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 \
                data-[size=default]:h-[1.15rem] data-[size=default]:w-8 \
                data-[size=sm]:h-3.5 data-[size=sm]:w-6 data-[state=checked]:bg-primary \
                data-[state=unchecked]:bg-input dark:data-[state=unchecked]:bg-input/80"
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
               "pointer-events-none block rounded-full bg-background ring-0 \
                transition-transform group-data-[size=default]/switch:size-4 \
                group-data-[size=sm]/switch:size-3 \
                data-[state=checked]:translate-x-[calc(100%-2px)] \
                data-[state=unchecked]:translate-x-0 \
                dark:data-[state=checked]:bg-primary-foreground \
                dark:data-[state=unchecked]:bg-foreground"
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
