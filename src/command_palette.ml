open! Import

module Item = struct
  type t =
    { value : string
    ; label : string
    ; keywords : string list
    ; icon : Icon.t option
    ; shortcut : string option
    ; disabled : bool
    ; on_select : unit Effect.t
    }

  let create ?value ?(keywords = []) ?icon ?shortcut ?(disabled = false) ~on_select label =
    { value = Option.value value ~default:label
    ; label
    ; keywords
    ; icon
    ; shortcut
    ; disabled
    ; on_select
    }
  ;;
end

module Group = struct
  type t =
    { heading : string option
    ; items : Item.t list
    }

  let create ?heading items = { heading; items }
end

module State = struct
  type t =
    { query : string
    ; highlighted : string option
    }
  [@@deriving sexp_of, equal]

  let empty = { query = ""; highlighted = None }
end

let filter ~query groups =
  List.filter_map groups ~f:(fun (g : Group.t) ->
    let items =
      List.filter_map g.items ~f:(fun (item : Item.t) ->
        let label = Fuzzy.score ~query item.label in
        let keywords =
          Fuzzy.best ~query item.keywords |> Option.map ~f:(fun s -> s - 1)
        in
        Option.merge label keywords ~f:Int.max |> Option.map ~f:(fun s -> s, item))
      |> List.stable_sort ~compare:(fun (a, _) (b, _) -> Int.compare b a)
      |> List.map ~f:snd
    in
    if List.is_empty items then None else Some { g with items })
;;

let item_id ~id value =
  sprintf "%s-item-%s" id (String.map value ~f:(fun c -> if Char.is_alphanum c then c else '_'))
;;

let view
  ?attrs:extra
  ?(placeholder = "Type a command or search…")
  ?(empty = "No results found.")
  ?(autofocus = false)
  ~id
  ~(state : State.t)
  ~on_state
  groups
  =
  let shown = filter ~query:state.query groups in
  let enabled =
    List.concat_map shown ~f:(fun g -> g.items)
    |> List.filter_map ~f:(fun (i : Item.t) -> Option.some_if (not i.disabled) (i.value, i.label))
  in
  let highlighted =
    match state.highlighted with
    | Some v when List.exists enabled ~f:(fun (v', _) -> String.equal v v') -> Some v
    | _ -> List.hd enabled |> Option.map ~f:fst
  in
  let find v =
    List.concat_map shown ~f:(fun g -> g.items)
    |> List.find ~f:(fun (i : Item.t) -> String.equal i.value v)
  in
  let on_keydown ev =
    match Dom_util.key ev with
    | Enter ->
      (match Option.bind highlighted ~f:find with
       | Some item -> Effect.Many [ Dom_util.prevent_default ev; item.on_select ]
       | None -> Effect.Ignore)
    | (ArrowDown | ArrowUp) as key ->
      (match List_nav.move ~equal:String.equal ~items:enabled ~current:highlighted key with
       | None -> Effect.Ignore
       | Some v ->
         Effect.Many
           [ Dom_util.prevent_default ev
           ; on_state { state with highlighted = Some v }
           ; Scroll.into_view ("#" ^ item_id ~id v)
           ])
    | _ -> Effect.Ignore
  in
  let item_view (item : Item.t) =
    let is_highlighted = Option.equal String.equal highlighted (Some item.value) in
    Node.div
      ~key:item.value
      ~attrs:
        ([ Attr.class_ "loon-option"
         ; Attr.role "option"
         ; Attr.id (item_id ~id item.value)
         ; aria_bool "selected" is_highlighted
         ]
         @ (if is_highlighted then [ data "highlighted" "" ] else [])
         @
         if item.disabled
         then [ aria "disabled" "true"; data "disabled" "" ]
         else
           [ Attr.on_click (fun _ -> item.on_select)
           ; Attr.on_mousemove (fun _ ->
               if is_highlighted
               then Effect.Ignore
               else on_state { state with highlighted = Some item.value })
           ])
      (List.filter_opt
         [ Option.map item.icon ~f:(fun i -> Icon.view i)
         ; Some (Node.span ~attrs:[ Attr.class_ "loon-menu-text" ] [ Node.text item.label ])
         ; Option.map item.shortcut ~f:(fun s ->
             Node.span ~attrs:[ Attr.class_ "loon-menu-shortcut" ] [ Node.text s ])
         ])
  in
  let list_id = id ^ "-list" in
  Node.div
    ~attrs:(attrs ?attrs:extra [ "loon-command" ])
    [ Node.div
        ~attrs:[ Attr.class_ "loon-command-search" ]
        [ Icon.view Search
        ; Node.input
            ~attrs:
              ([ Attr.class_ "loon-command-input"
               ; Attr.type_ "text"
               ; Attr.role "combobox"
               ; Attr.placeholder placeholder
               ; Attr.create "autocomplete" "off"
               ; Attr.create "spellcheck" "false"
               ; aria "autocomplete" "list"
               ; aria "expanded" "true"
               ; aria "controls" list_id
               ; aria "label" placeholder
               ; Attr.value state.query
               ; Attr.on_input (fun _ query -> on_state { query; highlighted = None })
               ; Attr.on_keydown on_keydown
               ]
               @ (if autofocus then [ Floating.focus_on_mount ] else [])
               @
               match highlighted with
               | None -> []
               | Some v -> [ aria "activedescendant" (item_id ~id v) ])
            ()
        ]
    ; Node.div
        ~attrs:[ Attr.class_ "loon-command-list"; Attr.role "listbox"; Attr.id list_id ]
        (match shown with
         | [] -> [ Node.div ~attrs:[ Attr.class_ "loon-command-empty" ] [ Node.text empty ] ]
         | shown ->
           List.mapi shown ~f:(fun i (g : Group.t) ->
             let heading_id = sprintf "%s-group-%d" id i in
             Node.div
               ~attrs:
                 ([ Attr.class_ "loon-command-group"; Attr.role "group" ]
                  @ if Option.is_some g.heading then [ aria "labelledby" heading_id ] else [])
               (List.filter_opt
                  [ Option.map g.heading ~f:(fun h ->
                      Node.div
                        ~attrs:[ Attr.class_ "loon-menu-label"; Attr.id heading_id ]
                        [ Node.text h ])
                  ]
                @ List.map g.items ~f:item_view)))
    ]
;;

let component ?attrs ?placeholder ?empty groups (local_ graph) =
  let state, set_state = Bonsai.state State.empty ~equal:State.equal graph in
  let id = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr state and set_state and id and groups in
  view ?attrs ?placeholder ?empty ~id:("loon" ^ id) ~state ~on_state:set_state groups
;;

let dialog ?placeholder ?empty ?(shortcut = true) groups (local_ graph) =
  let open_, set_open = Bonsai.state false graph in
  let state, set_state = Bonsai.state State.empty ~equal:State.equal graph in
  let id = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr open_ and set_open and state and set_state and id and groups in
  let id = "loon" ^ id in
  let set_open b = Effect.Many [ set_state State.empty; set_open b ] in
  let close = set_open false in
  let groups =
    List.map groups ~f:(fun (g : Group.t) ->
      { g with
        items =
          List.map g.items ~f:(fun (i : Item.t) ->
            { i with on_select = Effect.Many [ close; i.on_select ] })
      })
  in
  let on_global_keydown (ev : Js_of_ocaml.Dom_html.keyboardEvent Js_of_ocaml.Js.t) =
    let modifier = Js_of_ocaml.Js.to_bool ev##.ctrlKey || Js_of_ocaml.Js.to_bool ev##.metaKey in
    match Dom_util.key ev with
    | KeyK when modifier -> Effect.Many [ Dom_util.prevent_default ev; set_open (not open_) ]
    | _ -> Effect.Ignore
  in
  let modal =
    Modal.view
      ~role:"dialog"
      ~class_:"loon-command-dialog"
      ~id
      ~open_
      ~on_close:close
      [ Node.h2
          ~attrs:[ Attr.class_ "loon-visually-hidden"; Attr.id (Modal.title_id id) ]
          [ Node.text "Command palette" ]
      ; view ?placeholder ?empty ~autofocus:true ~id ~state ~on_state:set_state groups
      ]
  in
  ( Node.div
      ~attrs:
        ([ Attr.class_ "loon-modal-anchor" ]
         @
         if shortcut
         then [ Vdom.Attr.Global_listeners.keydown ~phase:Bubbling ~f:on_global_keydown ]
         else [])
      [ modal ]
  , set_open true )
;;
