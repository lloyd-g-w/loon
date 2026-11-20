open! Import

module Tab = struct
  type t =
    { id : string
    ; label : Node.t
    ; content : Node.t
    ; disabled : bool
    }

  let create ?(disabled = false) ~id ~label content =
    { id; label = Node.text label; content; disabled }
  ;;
end

module Variant = struct
  type t =
    | Segmented
    | Underline
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let trigger_id ~name id = sprintf "%s-tab-%s" name id
let panel_id ~name id = sprintf "%s-panel-%s" name id

(** The tab [key] moves to from [active], skipping disabled ones. *)
let moved (tabs : Tab.t list) ~active ~(key : Js_of_ocaml.Dom_html.Keyboard_code.t) =
  let enabled = List.filter tabs ~f:(fun t -> not t.disabled) |> Array.of_list in
  let n = Array.length enabled in
  if n = 0
  then None
  else (
    let index =
      Array.findi enabled ~f:(fun _ t -> String.equal t.id active)
      |> Option.value_map ~default:0 ~f:fst
    in
    match key with
    | ArrowRight -> Some enabled.((index + 1) % n).id
    | ArrowLeft -> Some enabled.((index - 1 + n) % n).id
    | Home -> Some enabled.(0).id
    | End -> Some enabled.(n - 1).id
    | _ -> None)
;;

let view ?attrs:extra ?(variant = Variant.Segmented) ~name ~active ~on_change tabs =
  let active =
    if List.exists tabs ~f:(fun (t : Tab.t) -> String.equal t.id active)
    then active
    else (
      match tabs with
      | [] -> active
      | t :: _ -> t.id)
  in
  let trigger (tab : Tab.t) =
    let selected = String.equal tab.id active in
    Node.button
      ~attrs:
        ([ Attr.classes [ "loon-tabs-trigger" ]
         ; Attr.type_ "button"
         ; Attr.role "tab"
         ; Attr.id (trigger_id ~name tab.id)
         ; aria_bool "selected" selected
         ; aria "controls" (panel_id ~name tab.id)
         ; data "state" (if selected then "active" else "inactive")
         ; Attr.tabindex (if selected then 0 else -1)
         ; Attr.on_click (fun _ -> if selected then Effect.Ignore else on_change tab.id)
         ]
         @ if tab.disabled then [ Attr.disabled ] else [])
      [ tab.label ]
  in
  let on_keydown ev =
    match moved tabs ~active ~key:(Dom_util.key ev) with
    | None -> Effect.Ignore
    | Some id ->
      Effect.Many
        [ Dom_util.prevent_default ev
        ; on_change id
        ; Dom_util.focus_selector ("#" ^ trigger_id ~name id)
        ]
  in
  Node.div
    ~attrs:(attrs ?attrs:extra [ "loon-tabs"; "loon-tabs-" ^ Variant.name variant ])
    (Node.div
       ~attrs:
         [ Attr.class_ "loon-tabs-list"
         ; Attr.role "tablist"
         ; Attr.on_keydown on_keydown
         ]
       (List.map tabs ~f:trigger)
     :: List.filter_map tabs ~f:(fun (tab : Tab.t) ->
       Option.some_if
         (String.equal tab.id active)
         (Node.div
            ~key:tab.id
            ~attrs:
              [ Attr.class_ "loon-tabs-panel"
              ; Attr.role "tabpanel"
              ; Attr.id (panel_id ~name tab.id)
              ; aria "labelledby" (trigger_id ~name tab.id)
              ; Attr.tabindex 0
              ]
            [ tab.content ])))
;;

let component ?attrs ?variant ?default tabs (local_ graph) =
  let active, set_active = Bonsai.state_opt ?default_model:default graph in
  let name = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr active
  and set_active
  and name
  and tabs in
  let active =
    match active, tabs with
    | Some active, _ -> active
    | None, (first : Tab.t) :: _ -> first.id
    | None, [] -> ""
  in
  view
    ?attrs
    ?variant
    ~name:("loon" ^ name)
    ~active
    ~on_change:(fun id -> set_active (Some id))
    tabs
;;
