open! Import

module Item = struct
  type t =
    { value : string
    ; content : Node.t list
    ; label : string option
    ; disabled : bool
    }

  let create ?label ?(disabled = false) ~value content = { value; content; label; disabled }
  let text ?disabled ~value s = create ?disabled ~value [ Node.text s ]
  let icon ?disabled ~value ~label i = create ~label ?disabled ~value [ Icon.view i ]
end

let item_id ~name value = sprintf "%s-toggle-%s" name value

let group
  ?attrs:extra
  ?variant
  ?size
  ?(disabled = false)
  ~role
  ~name
  ~is_pressed
  ~press
  (items : Item.t list)
  =
  let enabled = List.map items ~f:(fun item -> (not disabled) && not item.disabled) in
  let tab_stop =
    let pressed_enabled =
      List.findi items ~f:(fun i item -> List.nth_exn enabled i && is_pressed item.value)
    in
    match pressed_enabled with
    | Some (i, _) -> Some i
    | None -> List.findi enabled ~f:(fun _ e -> e) |> Option.map ~f:fst
  in
  let item i (it : Item.t) =
    let pressed = is_pressed it.value in
    let item_disabled = not (List.nth_exn enabled i) in
    Node.button
      ~attrs:
        ([ Attr.classes ("loon-toggle-group-item" :: Toggle.classes ?variant ?size ())
         ; Attr.type_ "button"
         ; Attr.id (item_id ~name it.value)
         ; data "state" (if pressed then "on" else "off")
         ; Attr.tabindex (if Option.equal Int.equal tab_stop (Some i) then 0 else -1)
         ]
         @ (match role with
            | `Radio -> [ Attr.role "radio"; aria_bool "checked" pressed ]
            | `Toggle -> [ aria_bool "pressed" pressed ])
         @ Option.value_map it.label ~default:[] ~f:(fun l -> [ aria "label" l ])
         @
         if item_disabled
         then [ Attr.disabled ]
         else
           [ Attr.on_click (fun _ -> press it.value (not pressed))
           ; Attr.on_keydown (fun ev ->
               match Roving.move ~enabled ~current:i (Dom_util.key ev) with
               | None -> Effect.Ignore
               | Some j ->
                 Effect.Many
                   [ Dom_util.prevent_default ev
                   ; Dom_util.focus_selector
                       ("#" ^ item_id ~name (List.nth_exn items j).value)
                   ])
           ])
      it.content
  in
  Node.div
    ~attrs:
      (attrs ?attrs:extra [ "loon-toggle-group" ]
       @ [ Attr.role
             (match role with
              | `Radio -> "radiogroup"
              | `Toggle -> "group")
         ]
       @ if disabled then [ aria "disabled" "true" ] else [])
    (List.mapi items ~f:item)
;;

let single ?attrs ?variant ?size ?disabled ?(required = false) ~name ~value ~on_change items
  =
  group
    ?attrs
    ?variant
    ?size
    ?disabled
    ~role:`Radio
    ~name
    ~is_pressed:(fun v -> Option.equal String.equal value (Some v))
    ~press:(fun v pressed ->
      if pressed
      then on_change (Some v)
      else if required
      then Effect.Ignore
      else on_change None)
    items
;;

let multiple ?attrs ?variant ?size ?disabled ~name ~value ~on_change items =
  group
    ?attrs
    ?variant
    ?size
    ?disabled
    ~role:`Toggle
    ~name
    ~is_pressed:(Set.mem value)
    ~press:(fun v pressed ->
      on_change (if pressed then Set.add value v else Set.remove value v))
    items
;;

(* The component updates its set by function, so that two clicks before a
   render both count. *)
let multiple_toggling ?attrs ?variant ?size ?disabled ~name ~value ~toggle items =
  group
    ?attrs
    ?variant
    ?size
    ?disabled
    ~role:`Toggle
    ~name
    ~is_pressed:(Set.mem value)
    ~press:(fun v _ -> toggle v)
    items
;;

let single_component ?attrs ?variant ?size ?disabled ?required ?default items (local_ graph)
  =
  Control.make_named
    ~equal:[%equal: string option]
    default
    ~view:(fun ~name value set ->
      single ?attrs ?variant ?size ?disabled ?required ~name ~value ~on_change:set items)
    graph
;;

let multiple_component
  ?attrs
  ?variant
  ?size
  ?disabled
  ?(default = String.Set.empty)
  items
  (local_ graph)
  =
  let value, update = Bonsai.state' ~equal:String.Set.equal default graph in
  let name = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr value and update and name in
  let toggle v =
    update (fun s -> if Set.mem s v then Set.remove s v else Set.add s v)
  in
  { Control.value
  ; set = (fun s -> update (fun _ -> s))
  ; view =
      multiple_toggling
        ?attrs
        ?variant
        ?size
        ?disabled
        ~name:("loon" ^ name)
        ~value
        ~toggle
        items
  }
;;
