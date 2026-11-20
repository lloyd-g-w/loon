open! Import

module Item = struct
  type kind =
    | Action of
        { icon : Icon.t option
        ; shortcut : string option
        ; danger : bool
        ; on_select : unit Effect.t
        }
    | Checkbox of
        { checked : bool
        ; on_change : bool -> unit Effect.t
        }
    | Radio of
        { selected : bool
        ; on_select : unit Effect.t
        }

  type t =
    | Item of
        { label : string
        ; disabled : bool
        ; kind : kind
        }
    | Label of string
    | Separator

  let action ?icon ?shortcut ?(disabled = false) ?(danger = false) ~on_select label =
    Item { label; disabled; kind = Action { icon; shortcut; danger; on_select } }
  ;;

  let checkbox ?(disabled = false) ~checked ~on_change label =
    Item { label; disabled; kind = Checkbox { checked; on_change } }
  ;;

  let radio ?(disabled = false) ~selected ~on_select label =
    Item { label; disabled; kind = Radio { selected; on_select } }
  ;;

  let label l = Label l
  let separator = Separator
end

module State = struct
  type t =
    | Closed
    | Open of { highlighted : int option }
  [@@deriving sexp_of, equal]
end

let item_id ~id i = sprintf "%s-item-%d" id i

(* The enabled items, by index, with their labels. *)
let enabled items =
  List.filter_mapi items ~f:(fun i (item : Item.t) ->
    match item with
    | Item { label; disabled = false; _ } -> Some (i, label)
    | Item { disabled = true; _ } | Label _ | Separator -> None)
;;

let view ?attrs ?side ?(align = Floating.Align.Start) ~id ~state ~on_change ~trigger items =
  let open_, highlighted =
    match (state : State.t) with
    | Closed -> false, None
    | Open { highlighted } -> true, highlighted
  in
  let close = Floating.and_refocus ~id (on_change State.Closed) in
  let highlight i = on_change (Open { highlighted = Some i }) in
  let choose i =
    match List.nth items i with
    | Some (Item.Item { disabled = false; kind; _ }) ->
      (match kind with
       | Action { on_select; _ } -> Effect.Many [ close; on_select ]
       | Checkbox { checked; on_change = f } -> Effect.Many [ highlight i; f (not checked) ]
       | Radio { on_select; _ } -> Effect.Many [ highlight i; on_select ])
    | Some _ | None -> Effect.Ignore
  in
  let first () =
    match enabled items with
    | (i, _) :: _ -> Some i
    | [] -> None
  in
  let trigger_keydown ev =
    match Dom_util.key ev with
    | ArrowDown | Enter | Space ->
      Effect.Many
        [ Dom_util.prevent_default ev; on_change (Open { highlighted = first () }) ]
    | ArrowUp ->
      let last = List.last (enabled items) |> Option.map ~f:fst in
      Effect.Many [ Dom_util.prevent_default ev; on_change (Open { highlighted = last }) ]
    | _ -> Effect.Ignore
  in
  let content_keydown ev =
    match Dom_util.key ev with
    | Enter | Space ->
      Effect.Many
        [ Dom_util.prevent_default ev
        ; Option.value_map highlighted ~default:Effect.Ignore ~f:choose
        ]
    | Tab -> on_change Closed
    | key ->
      (match
         List_nav.move ~equal:Int.equal ~items:(enabled items) ~current:highlighted key
       with
       | None -> Effect.Ignore
       | Some i -> Effect.Many [ Dom_util.prevent_default ev; highlight i ])
  in
  let item_view i (item : Item.t) =
    match item with
    | Separator ->
      Node.div ~attrs:[ Attr.class_ "loon-menu-separator"; Attr.role "separator" ] []
    | Label l -> Node.div ~attrs:[ Attr.class_ "loon-menu-label" ] [ Node.text l ]
    | Item { label; disabled; kind } ->
      let role, indicator, trailing, danger =
        match kind with
        | Action { icon; shortcut; danger; _ } ->
          ( "menuitem"
          , Option.map icon ~f:(fun icon -> Icon.view icon)
          , Option.map shortcut ~f:(fun s ->
              Node.span ~attrs:[ Attr.class_ "loon-menu-shortcut" ] [ Node.text s ])
          , danger )
        | Checkbox { checked; _ } ->
          ( "menuitemcheckbox"
          , Some
              (Node.span
                 ~attrs:[ Attr.class_ "loon-menu-indicator" ]
                 (if checked then [ Icon.view Check ] else []))
          , None
          , false )
        | Radio { selected; _ } ->
          ( "menuitemradio"
          , Some
              (Node.span
                 ~attrs:[ Attr.class_ "loon-menu-indicator" ]
                 (if selected then [ Icon.view Dot ] else []))
          , None
          , false )
      in
      let checked =
        match kind with
        | Action _ -> []
        | Checkbox { checked; _ } | Radio { selected = checked; _ } ->
          [ aria_bool "checked" checked ]
      in
      Node.div
        ~attrs:
          ([ Attr.classes
               ([ "loon-menu-item" ] @ if danger then [ "loon-menu-item-danger" ] else [])
           ; Attr.role role
           ; Attr.id (item_id ~id i)
           ; Attr.tabindex (-1)
           ]
           @ checked
           @ (if Option.equal Int.equal highlighted (Some i)
              then [ data "highlighted" "" ]
              else [])
           @
           if disabled
           then [ aria "disabled" "true"; data "disabled" "" ]
           else
             [ Attr.on_click (fun _ -> choose i)
             ; Attr.on_mousemove (fun _ ->
                 if Option.equal Int.equal highlighted (Some i)
                 then Effect.Ignore
                 else highlight i)
             ])
        (List.filter_opt
           [ indicator
           ; Some (Node.span ~attrs:[ Attr.class_ "loon-menu-text" ] [ Node.text label ])
           ; trailing
           ])
  in
  Floating.view
    ?attrs
    ?side
    ~align
    ~id
    ~open_
    ~on_dismiss:(on_change Closed)
    ~content_attrs:
      ([ Attr.class_ "loon-menu"
       ; Attr.role "menu"
       ; Attr.tabindex (-1)
       ; aria "labelledby" (Floating.trigger_id id)
       ; Attr.on_keydown content_keydown
       ; Floating.focus_on_mount
       ]
       @
       match highlighted with
       | None -> []
       | Some i -> [ aria "activedescendant" (item_id ~id i) ])
    ~trigger:
      (trigger
         (Floating.trigger_attrs
            ~id
            ~haspopup:"menu"
            ~open_
            ~on_toggle:(on_change (if open_ then Closed else Open { highlighted = None }))
          @ [ Attr.on_keydown trigger_keydown ]))
    (List.mapi items ~f:item_view)
;;

let component ?attrs ?side ?align ~trigger items (local_ graph) =
  let state, set_state = Bonsai.state State.Closed ~equal:State.equal graph in
  let id = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr state and set_state and id and items in
  view ?attrs ?side ?align ~id:("loon" ^ id) ~state ~on_change:set_state ~trigger items
;;
