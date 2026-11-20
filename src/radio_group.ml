open! Import

module Item = struct
  type t =
    { value : string
    ; label : string
    ; description : string option
    ; disabled : bool
    }

  let create ?description ?(disabled = false) ~value label =
    { value; label; description; disabled }
  ;;
end

let item_id ~name value = sprintf "%s-radio-%s" name value

let view
      ?attrs:extra
      ?(orientation = Roving.Orientation.Vertical)
      ?(disabled = false)
      ~name
      ~value
      ~on_change
      (items : Item.t list)
  =
  let enabled =
    List.map items ~f:(fun item -> (not disabled) && not item.disabled)
  in
  (* Tab reaches the chosen item, or the first enabled one. *)
  let tab_stop =
    match
      List.findi items ~f:(fun i item ->
        List.nth_exn enabled i
        && Option.equal String.equal value (Some item.value))
    with
    | Some (i, _) -> Some i
    | None -> List.findi enabled ~f:(fun _ e -> e) |> Option.map ~f:fst
  in
  let radio i (item : Item.t) =
    let checked = Option.equal String.equal value (Some item.value) in
    let item_disabled = not (List.nth_exn enabled i) in
    let id = item_id ~name item.value in
    let on_keydown ev =
      match Roving.move ~enabled ~current:i (Dom_util.key ev) with
      | None -> Effect.Ignore
      | Some j ->
        let next = List.nth_exn items j in
        Effect.Many
          [ Dom_util.prevent_default ev
          ; on_change next.value
          ; Dom_util.focus_selector ("#" ^ item_id ~name next.value)
          ]
    in
    Node.label
      ~attrs:
        [ Attr.class_ "loon-radio-item"
        ; data "disabled" (Bool.to_string item_disabled)
        ]
      [ Node.button
          ~attrs:
            ([ Attr.class_ "loon-radio"
             ; Attr.type_ "button"
             ; Attr.role "radio"
             ; Attr.id id
             ; aria "labelledby" (id ^ "-label")
             ; aria_bool "checked" checked
             ; data "state" (if checked then "checked" else "unchecked")
             ; Attr.tabindex
                 (if Option.equal Int.equal tab_stop (Some i) then 0 else -1)
             ]
             @ (if Option.is_some item.description
                then [ aria "describedby" (id ^ "-description") ]
                else [])
             @
             if item_disabled
             then [ Attr.disabled ]
             else
               [ Attr.on_click (fun _ ->
                   if checked then Effect.Ignore else on_change item.value)
               ; Attr.on_keydown on_keydown
               ])
          [ Node.span ~attrs:[ Attr.class_ "loon-radio-dot" ] [] ]
      ; Node.span
          ~attrs:[ Attr.class_ "loon-radio-text" ]
          (Node.span
             ~attrs:[ Attr.class_ "loon-radio-label"; Attr.id (id ^ "-label") ]
             [ Node.text item.label ]
           :: Option.value_map item.description ~default:[] ~f:(fun d ->
             [ Node.span
                 ~attrs:
                   [ Attr.class_ "loon-radio-description"
                   ; Attr.id (id ^ "-description")
                   ]
                 [ Node.text d ]
             ]))
      ]
  in
  Node.div
    ~attrs:
      (attrs
         ?attrs:extra
         [ "loon-radio-group"
         ; "loon-radio-group-" ^ Roving.Orientation.name orientation
         ]
       @ [ Attr.role "radiogroup"
         ; aria "orientation" (Roving.Orientation.name orientation)
         ]
       @ if disabled then [ aria "disabled" "true" ] else [])
    (List.mapi items ~f:radio)
;;

let component ?attrs ?orientation ?disabled ?default items (local_ graph) =
  Control.make_named
    ~equal:[%equal: string option]
    default
    ~view:(fun ~name value set ->
      view
        ?attrs
        ?orientation
        ?disabled
        ~name
        ~value
        ~on_change:(fun v -> set (Some v))
        items)
    graph
;;
