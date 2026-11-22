open! Import

module State = struct
  type t =
    | Closed
    | Open of Menu.State.t
  [@@deriving sexp_of, equal]

  let is_open = function
    | Closed -> false
    | Open _ -> true
  ;;
end

let classes : Menu.Classes.t =
  { slot = "dropdown-menu"
  ; item =
      "cn-dropdown-menu-item group/dropdown-menu-item relative flex \
       cursor-default items-center outline-hidden select-none \
       data-disabled:pointer-events-none data-disabled:opacity-50 \
       [&_svg]:pointer-events-none [&_svg]:shrink-0"
  ; checkbox_item =
      "cn-dropdown-menu-checkbox-item relative flex cursor-default items-center \
       outline-hidden select-none data-disabled:pointer-events-none \
       data-disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0"
  ; radio_item =
      "cn-dropdown-menu-radio-item relative flex cursor-default items-center \
       outline-hidden select-none data-disabled:pointer-events-none \
       data-disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0"
  ; checkbox_indicator = "cn-dropdown-menu-item-indicator pointer-events-none"
  ; radio_indicator = "cn-dropdown-menu-item-indicator pointer-events-none"
  ; indicator_slots = true
  ; label = "cn-dropdown-menu-label"
  ; separator = "cn-dropdown-menu-separator"
  ; shortcut = "cn-dropdown-menu-shortcut"
  ; sub_trigger =
      "cn-dropdown-menu-sub-trigger flex cursor-default items-center \
       outline-hidden select-none [&_svg]:pointer-events-none [&_svg]:shrink-0"
  ; sub_trigger_icon = "cn-rtl-flip ml-auto"
  ; sub_content =
      "cn-dropdown-menu-sub-content cn-menu-target cn-menu-translucent z-50 \
       origin-(--radix-dropdown-menu-content-transform-origin) overflow-hidden"
  }
;;

let content_class =
  "cn-dropdown-menu-content cn-menu-target cn-menu-translucent z-50 \
   max-h-(--radix-dropdown-menu-content-available-height) \
   w-(--radix-dropdown-menu-trigger-width) \
   origin-(--radix-dropdown-menu-content-transform-origin) overflow-x-hidden \
   overflow-y-auto data-[state=closed]:overflow-hidden"
;;

type t =
  { id : string
  ; modal : bool
  ; state : State.t
  ; on_change : State.t -> unit Effect.t
  }

let set_open t o =
  match o, t.state with
  | true, Open _ | false, Closed -> Effect.Ignore
  | true, Closed -> t.on_change (Open Menu.State.initial)
  | false, Open _ -> t.on_change Closed
;;

let view ?(id = "dropdown-menu") ?(modal = true) ~state ~on_change f =
  Node.fragment (f { id; modal; state; on_change })
;;

let component ?(default_open = false) ?modal f (local_ graph) =
  let open Bonsai.Let_syntax in
  let state, set_state =
    Bonsai.state
      (if default_open then State.Open Menu.State.initial else Closed)
      graph
  in
  let id = Bonsai.path_id graph in
  let%arr state and set_state and id and f in
  view ~id ?modal ~state ~on_change:set_state f
;;

let trigger_id t = Menu.trigger_id t.id

let close t = Effect.Many [ t.on_change Closed; Focus.restore (trigger_id t) ]

let trigger ?(attrs = []) ?(disabled = false) t node =
  let is_open = State.is_open t.state in
  let open_first =
    (* The items are only known to the content: it highlights the first
       when it opens with this state. *)
    t.on_change (Open { Menu.State.initial with highlighted = Some [] })
  in
  Slot.merge
    ~defaults:[ "type", Attr.type_ "button"; "data-slot", data "slot" "dropdown-menu-trigger" ]
    ([ Attr.id (trigger_id t)
     ; aria "haspopup" "menu"
     ; aria_bool "expanded" is_open
     ]
     @ (if is_open then [ aria "controls" (Menu.content_id t.id) ] else [])
     @ [ data "state" (if is_open then "open" else "closed") ]
     @ (if disabled
        then [ Attr.disabled; data "disabled" "" ]
        else
          [ Attr.on_click (fun _ -> if is_open then close t else set_open t true)
          ; Attr.on_keydown (fun ev ->
              match Dom_util.key ev with
              | Enter | Space ->
                Effect.Many
                  [ Dom_util.prevent_default ev
                  ; (if is_open then close t else open_first)
                  ]
              | ArrowDown -> Effect.Many [ Dom_util.prevent_default ev; open_first ]
              | _ -> Effect.Ignore)
          ])
     @ attrs)
    node
;;

(* [highlighted = Some []] asks for the first item (see [trigger]). *)
let resolve items (s : Menu.State.t) =
  match s.highlighted with
  | Some [] -> Menu.first_highlighted items
  | _ -> s
;;

let content
  ?attrs
  ?class_
  ?side
  ?(side_offset = 4.)
  ?align
  ?align_offset
  ?avoid_collisions
  t
  items
  =
  match t.state with
  | Closed -> Node.none
  | Open s ->
    let s = resolve items s in
    let menu : Menu.t =
      { id = t.id
      ; classes
      ; state = s
      ; set_state = (fun s -> t.on_change (Open s))
      ; close = close t
      ; on_edge = None
      }
    in
    Menu.content
      ?attrs
      ?class_
      ?side
      ~side_offset
      ?align
      ?align_offset
      ?avoid_collisions
      ~modal:t.modal
      ~inside:[ trigger_id t ]
      ~on_dismiss:(function
        | Pointer_outside | Focus_outside when not t.modal ->
          (* Radix: a non-modal menu leaves the focus where an interaction
             outside put it. *)
          Effect.Many [ Focus.no_restore; t.on_change Closed ]
        | _ -> close t)
      ~base_class:content_class
      ~anchor:(Element (trigger_id t))
      menu
      items
;;

let group = Menu.group
let label = Menu.label
let item = Menu.item
let checkbox_item = Menu.checkbox_item
let radio_group = Menu.radio_group
let radio_item = Menu.radio_item ?indicator:None
let separator = Menu.separator
let shortcut = Menu.shortcut classes
let sub = Menu.sub
let sub_trigger = Menu.sub_trigger
let sub_content = Menu.sub_content
