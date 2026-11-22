open! Import

module State = struct
  type t =
    | Closed
    | Open of
        { x : float
        ; y : float
        ; menu : Menu.State.t
        }
  [@@deriving sexp_of, equal]

  let is_open = function
    | Closed -> false
    | Open _ -> true
  ;;
end

let classes : Menu.Classes.t =
  { slot = "context-menu"
  ; item =
      "cn-context-menu-item group/context-menu-item relative flex cursor-default \
       items-center outline-hidden select-none data-disabled:pointer-events-none \
       data-disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0"
  ; checkbox_item =
      "cn-context-menu-checkbox-item relative flex cursor-default items-center \
       outline-hidden select-none data-disabled:pointer-events-none \
       data-disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0"
  ; radio_item =
      "cn-context-menu-radio-item relative flex cursor-default items-center \
       outline-hidden select-none data-disabled:pointer-events-none \
       data-disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0"
  ; checkbox_indicator = "cn-context-menu-item-indicator pointer-events-none"
  ; radio_indicator = "cn-context-menu-item-indicator pointer-events-none"
  ; indicator_slots = false
  ; label = "cn-context-menu-label"
  ; separator = "cn-context-menu-separator"
  ; shortcut = "cn-context-menu-shortcut"
  ; sub_trigger =
      "cn-context-menu-sub-trigger flex cursor-default items-center \
       outline-hidden select-none [&_svg]:pointer-events-none [&_svg]:shrink-0"
  ; sub_trigger_icon = "cn-rtl-flip ml-auto"
  ; sub_content =
      "cn-context-menu-sub-content cn-menu-target cn-menu-translucent z-50 \
       origin-(--radix-context-menu-content-transform-origin) overflow-hidden"
  }
;;

let content_class =
  "cn-context-menu-content cn-menu-target cn-menu-translucent z-50 \
   max-h-(--radix-context-menu-content-available-height) \
   origin-(--radix-context-menu-content-transform-origin) overflow-x-hidden \
   overflow-y-auto"
;;

type t =
  { id : string
  ; modal : bool
  ; state : State.t
  ; on_change : State.t -> unit Effect.t
  }

let view ?(id = "context-menu") ?(modal = true) ~state ~on_change f =
  Node.fragment (f { id; modal; state; on_change })
;;

let component ?modal f (local_ graph) =
  let open Bonsai.Let_syntax in
  let state, set_state = Bonsai.state State.Closed graph in
  let id = Bonsai.path_id graph in
  let%arr state and set_state and id and f in
  view ~id ?modal ~state ~on_change:set_state f
;;

let trigger_id t = Menu.trigger_id t.id

let trigger ?(attrs = []) ?class_ ?(disabled = false) t children =
  Node.span
    ~attrs:
      ([ data "slot" "context-menu-trigger"
       ; Attr.id (trigger_id t)
       ; data "state" (if State.is_open t.state then "open" else "closed")
       ]
       @ [ Cn.with_class ?class_ [ "cn-context-menu-trigger select-none" ] ]
       @ (if disabled
          then [ data "disabled" "" ]
          else
            [ Attr.on_contextmenu (fun ev ->
                let x = Js_of_ocaml.Js.to_float ev##.clientX
                and y = Js_of_ocaml.Js.to_float ev##.clientY in
                Effect.Many
                  [ Dom_util.prevent_default ev
                  ; t.on_change (Open { x; y; menu = Menu.State.initial })
                  ])
            ; Attr.style (Css_gen.create ~field:"-webkit-touch-callout" ~value:"none")
            ])
       @ attrs)
    children
;;

let content ?attrs ?class_ ?avoid_collisions t items =
  match t.state with
  | Closed -> Node.none
  | Open { x; y; menu = s } ->
    let menu : Menu.t =
      { id = t.id
      ; classes
      ; state = s
      ; set_state = (fun menu -> t.on_change (Open { x; y; menu }))
      ; close = t.on_change Closed
      ; on_edge = None
      }
    in
    Menu.content
      ?attrs
      ?class_
      ~side:Right
      ~side_offset:2.
      ~align:Start
      ?avoid_collisions
      ~modal:t.modal
      ~labelled_by:false
      ~base_class:content_class
      ~anchor:(Point { x; y })
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
