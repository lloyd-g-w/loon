open! Import

module State = struct
  type t =
    | Checked
    | Unchecked
    | Indeterminate
  [@@deriving enumerate, sexp_of, compare, equal]

  let of_bool b = if b then Checked else Unchecked

  let aria = function
    | Checked -> "true"
    | Unchecked -> "false"
    | Indeterminate -> "mixed"
  ;;

  let name = function
    | Checked -> "checked"
    | Unchecked -> "unchecked"
    | Indeterminate -> "indeterminate"
  ;;
end

let view
  ?(attrs = [])
  ?class_
  ?id
  ?(disabled = false)
  ?(required = false)
  ?(invalid = false)
  ~(checked : State.t)
  ~on_change
  ()
  =
  let disabled_attrs = if disabled then [ data "disabled" "" ] else [] in
  Node.button
    ~attrs:
      ([ Attr.type_ "button"
       ; Attr.role "checkbox"
       ; aria "checked" (State.aria checked)
       ]
       (* Radix leaves aria-required out unless [required] is given. *)
       @ (if required then [ aria "required" "true" ] else [])
       @ [ data "state" (State.name checked)
         ; Attr.value "on"
         ; data "slot" "checkbox"
         ; Cn.with_class
             ?class_
             [ "peer size-4 shrink-0 rounded-[4px] border border-input shadow-xs \
                transition-shadow outline-none focus-visible:border-ring \
                focus-visible:ring-[3px] focus-visible:ring-ring/50 \
                disabled:cursor-not-allowed disabled:opacity-50 \
                aria-invalid:border-destructive aria-invalid:ring-destructive/20 \
                data-[state=checked]:border-primary data-[state=checked]:bg-primary \
                data-[state=checked]:text-primary-foreground dark:bg-input/30 \
                dark:aria-invalid:ring-destructive/40 dark:data-[state=checked]:bg-primary"
             ]
         ; Attr.on_keydown (fun ev ->
             match Dom_util.key ev with
             | Enter -> Dom_util.prevent_default ev
             | _ -> Effect.Ignore)
         ]
       @ Option.value_map id ~default:[] ~f:(fun id -> [ Attr.id id ])
       @ (if invalid then [ aria "invalid" "true" ] else [])
       @ disabled_attrs
       @ (if disabled
          then [ Attr.disabled ]
          else
            [ Attr.on_click (fun _ ->
                on_change
                  (match checked with
                   | Checked -> false
                   | Unchecked | Indeterminate -> true))
            ])
       @ attrs)
    (match checked with
     | Unchecked -> []
     | Checked | Indeterminate ->
       [ Node.span
           ~attrs:
             ([ data "state" (State.name checked)
              ; data "slot" "checkbox-indicator"
              ; Attr.class_ "grid place-content-center text-current transition-none"
              ; Attr.style (Css_gen.create ~field:"pointer-events" ~value:"none")
              ]
              @ disabled_attrs)
           [ Icon.view ~class_:"size-3.5" Check ]
       ])
;;

let component
  ?attrs
  ?class_
  ?id
  ?disabled
  ?required
  ?invalid
  ?(default_checked = false)
  (local_ graph)
  =
  Control.make ~equal:Bool.equal default_checked graph ~view:(fun checked set ->
    view
      ?attrs
      ?class_
      ?id
      ?disabled
      ?required
      ?invalid
      ~checked:(State.of_bool checked)
      ~on_change:set
      ())
;;
