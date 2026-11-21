open! Import

type kind =
  | Single of
      { value : string option
      ; on_change : string option -> unit Effect.t
      }
  | Multiple of
      { value : string list
      ; on_change : string list -> unit Effect.t
      }

type t =
  { kind : kind
  ; variant : Toggle.Variant.t option
  ; size : Toggle.Size.t option
  ; spacing : int
  ; disabled : bool
  ; (* The items, in the order they are created (for tests, which have no
       DOM; OCaml evaluates a list literal last first, so tests make them with
       [List.map]). *)
    mutable items : (string * bool) list
  }

let pressed t value =
  match t.kind with
  | Single { value = v; _ } -> [%equal: string option] v (Some value)
  | Multiple { value = vs; _ } -> List.mem vs value ~equal:String.equal
;;

(* The tab stop: the pressed item (the first pressed, of several), else
   every item. *)
let tab_stop t value =
  match t.kind with
  | Single { value = None; _ } | Multiple { value = []; _ } -> true
  | Single { value = Some v; _ } | Multiple { value = v :: _; _ } -> String.equal v value
;;

let root ?(attrs = []) ?class_ ?variant ?size ?(spacing = 0) ?orientation ?(disabled = false)
  kind children
  =
  let t = { kind; variant; size; spacing; disabled; items = [] } in
  let children = children t in
  Node.div
    ~attrs:
      ([ Attr.role "group"
       ; Attr.create "dir" "ltr"
       ; data "slot" "toggle-group"
       ]
       @ Option.value_map variant ~default:[] ~f:(fun v ->
         [ data "variant" (Toggle.Variant.name v) ])
       @ Option.value_map size ~default:[] ~f:(fun s -> [ data "size" (Toggle.Size.name s) ])
       @ [ data "spacing" (Int.to_string spacing)
         ; Attr.style (Css_gen.create ~field:"--gap" ~value:(Int.to_string spacing))
         ; Cn.with_class
             ?class_
             [ "group/toggle-group flex w-fit items-center gap-[--spacing(var(--gap))] \
                rounded-md data-[spacing=default]:data-[variant=outline]:shadow-xs"
             ]
         ]
       @ Option.value_map orientation ~default:[] ~f:(fun o ->
         [ data "orientation" (Roving.Orientation.name o) ])
       @ attrs)
    children
;;

let single ?attrs ?class_ ?variant ?size ?spacing ?orientation ?disabled ~value ~on_change
  children
  =
  root
    ?attrs
    ?class_
    ?variant
    ?size
    ?spacing
    ?orientation
    ?disabled
    (Single { value; on_change })
    children
;;

let multiple ?attrs ?class_ ?variant ?size ?spacing ?orientation ?disabled ~value
  ~on_change children
  =
  root
    ?attrs
    ?class_
    ?variant
    ?size
    ?spacing
    ?orientation
    ?disabled
    (Multiple { value; on_change })
    children
;;

let single_component
  ?attrs
  ?class_
  ?variant
  ?size
  ?spacing
  ?orientation
  ?disabled
  ?default_value
  children
  (local_ graph)
  =
  let open Bonsai.Let_syntax in
  let value, set = Bonsai.state default_value ~equal:[%equal: string option] graph in
  let%arr value and set and children in
  { Control.value
  ; set
  ; view =
      single
        ?attrs
        ?class_
        ?variant
        ?size
        ?spacing
        ?orientation
        ?disabled
        ~value
        ~on_change:set
        children
  }
;;

let multiple_component
  ?attrs
  ?class_
  ?variant
  ?size
  ?spacing
  ?orientation
  ?disabled
  ?(default_value = [])
  children
  (local_ graph)
  =
  let open Bonsai.Let_syntax in
  let value, set = Bonsai.state default_value ~equal:[%equal: string list] graph in
  let%arr value and set and children in
  { Control.value
  ; set
  ; view =
      multiple
        ?attrs
        ?class_
        ?variant
        ?size
        ?spacing
        ?orientation
        ?disabled
        ~value
        ~on_change:set
        children
  }
;;

let item ?(attrs = []) ?class_ ?variant ?size ?(disabled = false) t ~value children =
  let disabled = disabled || t.disabled in
  t.items <- t.items @ [ value, not disabled ];
  let on = pressed t value in
  let variant = Option.first_some t.variant variant in
  let size = Option.first_some t.size size in
  let toggle () =
    match t.kind with
    | Single { on_change; _ } -> on_change (if on then None else Some value)
    | Multiple { value = vs; on_change } ->
      on_change
        (if on
         then List.filter vs ~f:(fun v -> not (String.equal v value))
         else vs @ [ value ])
  in
  Node.button
    ~attrs:
      ([ Attr.type_ "button"; data "state" (if on then "on" else "off") ]
       @ (match t.kind with
          | Single _ -> [ Attr.role "radio"; aria_bool "checked" on ]
          | Multiple _ -> [ aria_bool "pressed" on ])
       @ [ Attr.value value
         ; Attr.tabindex (if tab_stop t value then 0 else -1)
         ; data "slot" "toggle-group-item"
         ]
       @ Option.value_map variant ~default:[] ~f:(fun v ->
         [ data "variant" (Toggle.Variant.name v) ])
       @ Option.value_map size ~default:[] ~f:(fun s -> [ data "size" (Toggle.Size.name s) ])
       @ [ data "spacing" (Int.to_string t.spacing)
         ; Cn.attr
             ([ Toggle.classes ?variant ?size ()
              ; "w-auto min-w-0 shrink-0 px-3 focus:z-10 focus-visible:z-10"
              ; "data-[spacing=0]:rounded-none data-[spacing=0]:shadow-none \
                 data-[spacing=0]:first:rounded-l-md data-[spacing=0]:last:rounded-r-md \
                 data-[spacing=0]:data-[variant=outline]:border-l-0 \
                 data-[spacing=0]:data-[variant=outline]:first:border-l"
              ]
              @ Option.to_list class_)
         ; Attr.on_keydown (fun ev ->
             match
               Roving.next
                 ev
                 ~group:"[data-slot=toggle-group]"
                 ~item:"[data-slot=toggle-group-item]"
                 ~fallback:t.items
                 ~current:value
             with
             | None -> Effect.Ignore
             | Some (_, focus) -> Effect.Many [ Dom_util.prevent_default ev; focus ])
         ]
       @ (if disabled
          then [ data "disabled" ""; Attr.disabled ]
          else [ Attr.on_click (fun _ -> toggle ()) ])
       @ attrs)
    children
;;
