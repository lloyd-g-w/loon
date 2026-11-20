open! Import

module State = struct
  type t =
    | Closed
    | Open of Command_palette.State.t
  [@@deriving sexp_of, equal]
end

let view
  ?attrs
  ?placeholder
  ?(search_placeholder = "Search…")
  ?empty
  ?(disabled = false)
  ?(invalid = false)
  ~id
  ~value
  ~on_change
  ~state
  ~on_state
  groups
  =
  let options = List.concat_map groups ~f:(fun (g : Select.Group.t) -> g.options) in
  let selected =
    Option.bind value ~f:(fun v ->
      List.find options ~f:(fun (o : Select.Option_.t) -> String.equal o.value v))
  in
  let open_ =
    match (state : State.t) with
    | Closed -> false
    | Open _ -> true
  in
  let open_state = State.Open { query = ""; highlighted = value } in
  let choose v = Effect.Many [ Floating.and_refocus ~id (on_state State.Closed); on_change v ] in
  let trigger_keydown ev =
    match Dom_util.key ev with
    | ArrowDown | ArrowUp -> Effect.Many [ Dom_util.prevent_default ev; on_state open_state ]
    | _ -> Effect.Ignore
  in
  let command_groups =
    List.map groups ~f:(fun (g : Select.Group.t) ->
      Command_palette.Group.create
        ?heading:g.label
        (List.map g.options ~f:(fun (o : Select.Option_.t) ->
           Command_palette.Item.create
             ~value:o.value
             ?icon:o.icon
             ~disabled:o.disabled
             ~on_select:(choose o.value)
             o.label)))
  in
  let trigger =
    Node.button
      ~attrs:
        (Floating.trigger_attrs
           ~id
           ~haspopup:"listbox"
           ~open_
           ~on_toggle:(on_state (if open_ then State.Closed else open_state))
         @ [ Attr.type_ "button"
           ; Attr.class_ "loon-select-trigger"
           ; Attr.role "combobox"
           ; Attr.on_keydown trigger_keydown
           ]
         @ (if invalid then [ aria "invalid" "true" ] else [])
         @ (if Option.is_none selected then [ data "placeholder" "" ] else [])
         @ if disabled then [ Attr.disabled ] else [])
      [ Node.span
          ~attrs:[ Attr.class_ "loon-select-value" ]
          (match selected with
           | Some o ->
             List.filter_opt
               [ Option.map o.icon ~f:(fun i -> Icon.view i); Some (Node.text o.label) ]
           | None -> [ Node.text (Option.value placeholder ~default:"Select…") ])
      ; Icon.view ~attrs:[ Attr.class_ "loon-select-chevron" ] Chevrons_up_down
      ]
  in
  Floating.view
    ~attrs:(Import.attrs ?attrs [ "loon-select"; "loon-combobox" ])
    ~match_width:true
    ~id
    ~open_
    ~on_dismiss:(on_state State.Closed)
    ~content_attrs:[ Attr.class_ "loon-combobox-content" ]
    ~trigger
    (match state with
     | Closed -> []
     | Open command_state ->
       [ Command_palette.view
           ~placeholder:search_placeholder
           ?empty
           ~autofocus:true
           ~id:(id ^ "-command")
           ~state:command_state
           ~on_state:(fun s -> on_state (State.Open s))
           command_groups
       ])
;;

let component ?attrs ?placeholder ?search_placeholder ?empty ?disabled ?default groups
  (local_ graph)
  =
  let value, set_value = Bonsai.state_opt ?default_model:default graph in
  let state, set_state = Bonsai.state State.Closed ~equal:State.equal graph in
  let id = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr value and set_value and state and set_state and id and groups in
  ( value
  , view
      ?attrs
      ?placeholder
      ?search_placeholder
      ?empty
      ?disabled
      ~id:("loon" ^ id)
      ~value
      ~on_change:(fun v -> set_value (Some v))
      ~state
      ~on_state:set_state
      groups )
;;
