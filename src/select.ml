open! Import

module Option_ = struct
  type t =
    { value : string
    ; label : string
    ; icon : Icon.t option
    ; disabled : bool
    }

  let create ?icon ?(disabled = false) ?label value =
    { value; label = Option.value label ~default:value; icon; disabled }
  ;;
end

module Group = struct
  type t =
    { label : string option
    ; options : Option_.t list
    }

  let create ?label options = { label; options }
end

module State = struct
  type t =
    | Closed
    | Open of { highlighted : string option }
  [@@deriving sexp_of, equal]
end

let option_id ~id value =
  sprintf "%s-option-%s" id (String.map value ~f:(fun c -> if Char.is_alphanum c then c else '_'))
;;

let view
  ?attrs
  ?placeholder
  ?(disabled = false)
  ?(invalid = false)
  ?side
  ~id
  ~value
  ~on_change
  ~state
  ~on_state
  groups
  =
  let options = List.concat_map groups ~f:(fun (g : Group.t) -> g.options) in
  let enabled =
    List.filter_map options ~f:(fun (o : Option_.t) ->
      Option.some_if (not o.disabled) (o.value, o.label))
  in
  let selected =
    Option.bind value ~f:(fun v ->
      List.find options ~f:(fun (o : Option_.t) -> String.equal o.value v))
  in
  let open_, highlighted =
    match (state : State.t) with
    | Closed -> false, None
    | Open { highlighted } -> true, highlighted
  in
  let open_at highlighted = on_state (State.Open { highlighted }) in
  let initial = Option.first_some value (List.hd enabled |> Option.map ~f:fst) in
  let choose v =
    Effect.Many [ Floating.and_refocus ~id (on_state Closed); on_change v ]
  in
  let move ev key current =
    match List_nav.move ~equal:String.equal ~items:enabled ~current key with
    | None -> None
    | Some v -> Some (Effect.Many [ Dom_util.prevent_default ev; open_at (Some v) ])
  in
  let trigger_keydown ev =
    match Dom_util.key ev with
    | ArrowDown | ArrowUp | Enter | Space ->
      Effect.Many [ Dom_util.prevent_default ev; open_at initial ]
    | key ->
      (* Typeahead on the closed select changes the value, as a native one does. *)
      (match List_nav.letter key with
       | None -> Effect.Ignore
       | Some _ ->
         (match List_nav.move ~equal:String.equal ~items:enabled ~current:value key with
          | None -> Effect.Ignore
          | Some v -> on_change v))
  in
  let content_keydown ev =
    match Dom_util.key ev with
    | Enter | Space ->
      Effect.Many
        [ Dom_util.prevent_default ev
        ; Option.value_map highlighted ~default:Effect.Ignore ~f:choose
        ]
    | Tab -> on_state Closed
    | key -> Option.value (move ev key highlighted) ~default:Effect.Ignore
  in
  let option_view (o : Option_.t) =
    let is_selected = Option.equal String.equal value (Some o.value) in
    let is_highlighted = Option.equal String.equal highlighted (Some o.value) in
    Node.div
      ~attrs:
        ([ Attr.class_ "loon-option"
         ; Attr.role "option"
         ; Attr.id (option_id ~id o.value)
         ; aria_bool "selected" is_selected
         ]
         @ (if is_highlighted then [ data "highlighted" "" ] else [])
         @
         if o.disabled
         then [ aria "disabled" "true"; data "disabled" "" ]
         else
           [ Attr.on_click (fun _ -> choose o.value)
           ; Attr.on_mousemove (fun _ ->
               if is_highlighted then Effect.Ignore else open_at (Some o.value))
           ])
      (List.filter_opt
         [ Option.map o.icon ~f:(fun i -> Icon.view i)
         ; Some (Node.span ~attrs:[ Attr.class_ "loon-menu-text" ] [ Node.text o.label ])
         ; Some
             (Node.span
                ~attrs:[ Attr.class_ "loon-option-check" ]
                (if is_selected then [ Icon.view Check ] else []))
         ])
  in
  let group_view i (g : Group.t) =
    let label_id = sprintf "%s-group-%d" id i in
    Node.div
      ~attrs:
        ([ Attr.role "group"; Attr.class_ "loon-option-group" ]
         @ if Option.is_some g.label then [ aria "labelledby" label_id ] else [])
      (List.filter_opt
         [ Option.map g.label ~f:(fun l ->
             Node.div
               ~attrs:[ Attr.class_ "loon-menu-label"; Attr.id label_id ]
               [ Node.text l ])
         ]
       @ List.map g.options ~f:option_view)
  in
  let trigger =
    Node.button
      ~attrs:
        (Floating.trigger_attrs
           ~id
           ~haspopup:"listbox"
           ~open_
           ~on_toggle:(if open_ then on_state Closed else open_at initial)
         @ [ Attr.type_ "button"
           ; Attr.class_ "loon-select-trigger"
           ; Attr.role "combobox"
           ; Attr.on_keydown trigger_keydown
           ]
         @ (if invalid then [ aria "invalid" "true" ] else [])
         @ (if Option.is_none selected then [ data "placeholder" "" ] else [])
         @ if disabled then [ Attr.disabled ] else [])
      [ (match selected with
         | Some o ->
           Node.span
             ~attrs:[ Attr.class_ "loon-select-value" ]
             (List.filter_opt
                [ Option.map o.icon ~f:(fun i -> Icon.view i); Some (Node.text o.label) ])
         | None ->
           Node.span
             ~attrs:[ Attr.class_ "loon-select-value" ]
             [ Node.text (Option.value placeholder ~default:"Select…") ])
      ; Icon.view ~attrs:[ Attr.class_ "loon-select-chevron" ] Chevrons_up_down
      ]
  in
  Floating.view
    ~attrs:(Import.attrs ?attrs [ "loon-select" ])
    ?side
    ~match_width:true
    ~id
    ~open_
    ~on_dismiss:(on_state Closed)
    ~content_attrs:
      ([ Attr.class_ "loon-listbox"
       ; Attr.role "listbox"
       ; Attr.tabindex (-1)
       ; aria "labelledby" (Floating.trigger_id id)
       ; Attr.on_keydown content_keydown
       ; Floating.focus_on_mount
       ]
       @
       match highlighted with
       | None -> []
       | Some v -> [ aria "activedescendant" (option_id ~id v) ])
    ~trigger
    (List.mapi groups ~f:(fun i g ->
       if i = 0
       then group_view i g
       else
         Node.div
           [ Node.div ~attrs:[ Attr.class_ "loon-menu-separator" ] []; group_view i g ]))
;;

let component ?attrs ?placeholder ?disabled ?side ?default groups (local_ graph) =
  let value, set_value = Bonsai.state_opt ?default_model:default graph in
  let state, set_state = Bonsai.state State.Closed ~equal:State.equal graph in
  let id = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr value and set_value and state and set_state and id and groups in
  ( value
  , view
      ?attrs
      ?placeholder
      ?disabled
      ?side
      ~id:("loon" ^ id)
      ~value
      ~on_change:(fun v -> set_value (Some v))
      ~state
      ~on_state:set_state
      groups )
;;
