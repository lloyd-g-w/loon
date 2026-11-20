open! Import

module Item = struct
  type t =
    { id : string
    ; title : Node.t
    ; content : Node.t
    ; disabled : bool
    }

  let create ?(disabled = false) ~id ~title content =
    { id; title = Node.text title; content; disabled }
  ;;
end

module Kind = struct
  type t =
    | Single of { collapsible : bool }
    | Multiple
  [@@deriving sexp_of, compare, equal]
end

let toggled (kind : Kind.t) ~open_ id =
  let is_open = List.mem open_ id ~equal:String.equal in
  match kind with
  | Multiple ->
    if is_open
    then List.filter open_ ~f:(fun o -> not (String.equal o id))
    else open_ @ [ id ]
  | Single { collapsible } ->
    if is_open then if collapsible then [] else open_ else [ id ]
;;

let trigger_id ~name id = sprintf "%s-trigger-%s" name id
let content_id ~name id = sprintf "%s-content-%s" name id

let view_with_toggle ?attrs:extra ~kind ~name ~open_ ~toggle items =
  let enabled =
    List.filter_map items ~f:(fun (i : Item.t) -> Option.some_if (not i.disabled) i.id)
    |> Array.of_list
  in
  let on_keydown id ev =
    let n = Array.length enabled in
    let index =
      Array.findi enabled ~f:(fun _ e -> String.equal e id) |> Option.value_map ~default:0 ~f:fst
    in
    let target =
      match (Dom_util.key ev : Js_of_ocaml.Dom_html.Keyboard_code.t) with
      | _ when n = 0 -> None
      | ArrowDown -> Some enabled.((index + 1) % n)
      | ArrowUp -> Some enabled.((index - 1 + n) % n)
      | Home -> Some enabled.(0)
      | End -> Some enabled.(n - 1)
      | _ -> None
    in
    match target with
    | None -> Effect.Ignore
    | Some target ->
      Effect.Many
        [ Dom_util.prevent_default ev; Dom_util.focus_selector ("#" ^ trigger_id ~name target) ]
  in
  let item (item : Item.t) =
    let is_open = List.mem open_ item.id ~equal:String.equal in
    let state = if is_open then "open" else "closed" in
    let locked =
      match kind with
      | Kind.Single { collapsible = false } -> is_open
      | Single { collapsible = true } | Multiple -> false
    in
    Node.div
      ~key:item.id
      ~attrs:[ Attr.class_ "loon-accordion-item"; data "state" state ]
      [ Node.h3
          ~attrs:[ Attr.class_ "loon-accordion-heading" ]
          [ Node.button
              ~attrs:
                ([ Attr.class_ "loon-accordion-trigger"
                 ; Attr.type_ "button"
                 ; Attr.id (trigger_id ~name item.id)
                 ; aria_bool "expanded" is_open
                 ; aria "controls" (content_id ~name item.id)
                 ; data "state" state
                 ; Attr.on_click (fun _ -> toggle item.id)
                 ; Attr.on_keydown (on_keydown item.id)
                 ]
                 @ (if locked then [ aria "disabled" "true" ] else [])
                 @ if item.disabled then [ Attr.disabled ] else [])
              [ Node.span ~attrs:[ Attr.class_ "loon-accordion-title" ] [ item.title ]
              ; Icon.view ~attrs:[ Attr.class_ "loon-accordion-chevron" ] Chevron_down
              ]
          ]
      ; Node.div
          ~attrs:
            ([ Attr.class_ "loon-accordion-content"
             ; Attr.id (content_id ~name item.id)
             ; Attr.role "region"
             ; aria "labelledby" (trigger_id ~name item.id)
             ; data "state" state
             ]
             @ if is_open then [] else [ Attr.create "inert" "" ])
          [ Node.div
              ~attrs:[ Attr.class_ "loon-accordion-inner" ]
              [ Node.div ~attrs:[ Attr.class_ "loon-accordion-body" ] [ item.content ] ]
          ]
      ]
  in
  Node.div ~attrs:(attrs ?attrs:extra [ "loon-accordion" ]) (List.map items ~f:item)
;;

let view
  ?attrs
  ?(kind = Kind.Single { collapsible = true })
  ~name
  ~open_
  ~on_change
  items
  =
  view_with_toggle
    ?attrs
    ~kind
    ~name
    ~open_
    ~toggle:(fun id -> on_change (toggled kind ~open_ id))
    items
;;

let component
  ?attrs
  ?(kind = Kind.Single { collapsible = true })
  ?(default = [])
  items
  (local_ graph)
  =
  let open_, update = Bonsai.state' default graph in
  let name = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr open_ and update and name and items in
  view_with_toggle
    ?attrs
    ~kind
    ~name:("loon" ^ name)
    ~open_
    ~toggle:(fun id -> update (fun open_ -> toggled kind ~open_ id))
    items
;;
