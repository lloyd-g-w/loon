open! Core
open Bonsai_web
module Node = Vdom.Node
module Attr = Vdom.Attr
module Menu = Loon.Menu
module Cn = Loon.Cn

let data name value = Attr.create ("data-" ^ name) value
let aria name value = Attr.create ("aria-" ^ name) value

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

(* picker.tsx's classes, with Base UI's variables and attributes as loon's
   Popper and Menu name them. *)
let item_class =
  "group/dropdown-menu-item relative flex cursor-default items-center gap-2 rounded-lg \
   px-2 py-1.5 text-sm font-medium outline-hidden select-none **:text-neutral-100 \
   focus:bg-neutral-600 focus:text-neutral-100 focus:**:text-neutral-100 \
   data-[inset]:pl-8 dark:focus:bg-neutral-700/80 pointer-coarse:gap-3 \
   pointer-coarse:py-2.5 pointer-coarse:pl-3 pointer-coarse:text-base \
   data-[disabled]:pointer-events-none data-[disabled]:opacity-50 \
   [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
;;

let radio_item_class =
  "relative flex cursor-default items-center gap-2 rounded-lg py-1.5 pr-8 pl-2 text-sm \
   font-medium outline-hidden select-none **:text-neutral-100 focus:bg-neutral-600 \
   focus:text-neutral-100 focus:**:text-neutral-100 data-[inset]:pl-8 \
   dark:focus:bg-neutral-700/80 pointer-coarse:gap-3 pointer-coarse:py-2.5 \
   pointer-coarse:pl-3 pointer-coarse:text-base data-[disabled]:pointer-events-none \
   data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 \
   [&_svg:not([class*='size-'])]:size-4"
;;

let classes : Menu.Classes.t =
  { slot = "dropdown-menu"
  ; item = item_class
  ; checkbox_item = radio_item_class
  ; radio_item = radio_item_class
  (* Menu's own radio indicator (a circle); radio_item draws picker.tsx's
     check instead. *)
  ; indicator = "hidden"
  ; label = "px-2 py-1.5 text-xs font-medium text-neutral-400 data-[inset]:pl-8"
  ; separator = "-mx-1.5 my-1.5 h-px bg-neutral-600 dark:bg-neutral-700"
  ; shortcut =
      "ml-auto text-xs tracking-widest text-neutral-400! \
       group-focus/dropdown-menu-item:text-neutral-100"
  ; sub_trigger = item_class
  ; sub_trigger_icon = "ml-auto"
  ; sub_content =
      "w-auto min-w-[96px] rounded-md bg-popover/90 p-1 text-popover-foreground \
       shadow-lg ring-1 ring-foreground/10 backdrop-blur-xs duration-100"
  }
;;

let content_class =
  "z-50 no-scrollbar max-h-(--radix-dropdown-menu-content-available-height) \
   w-[calc(var(--radix-dropdown-menu-content-available-width)-(--spacing(6)))] min-w-32 \
   origin-(--radix-dropdown-menu-content-transform-origin) translate-y-2 \
   overflow-x-hidden overflow-y-auto rounded-xl border-0 bg-neutral-950/80 p-1.5 \
   text-neutral-100 ring-1 ring-neutral-950/80 backdrop-blur-xl outline-none md:w-52 \
   dark:bg-neutral-800/90 dark:ring-neutral-700/50 \
   data-[state=closed]:overflow-hidden"
;;

let trigger_class =
  "relative w-36 shrink-0 touch-manipulation rounded-xl p-3 ring-1 ring-foreground/10 \
   select-none hover:bg-muted focus-visible:ring-foreground/50 focus-visible:outline-none \
   disabled:opacity-50 data-popup-open:bg-muted md:w-full md:rounded-lg md:px-2.5 \
   md:py-2"
;;

type t =
  { id : string
  ; state : State.t
  ; on_change : State.t -> unit Effect.t
  }

let is_open t = State.is_open t.state

let set_open t o =
  match o, t.state with
  | true, Open _ | false, Closed -> Effect.Ignore
  | true, Closed -> t.on_change (Open Menu.State.initial)
  | false, Open _ -> t.on_change Closed
;;

let view ~id ~state ~on_change f = Node.fragment (f { id; state; on_change })

let component ?on_open_change f (local_ graph) =
  let open Bonsai.Let_syntax in
  let state, set_state = Bonsai.state State.Closed graph in
  let id = Bonsai.path_id graph in
  let on_open_change =
    match on_open_change with
    | Some f -> f
    | None -> Bonsai.return (fun _ -> Effect.Ignore)
  in
  let%arr state and set_state and id and f and on_open_change in
  let on_change s =
    if Bool.equal (State.is_open s) (State.is_open state)
    then set_state s
    else Effect.Many [ set_state s; on_open_change (State.is_open s) ]
  in
  view ~id:("picker-" ^ id) ~state ~on_change f
;;

let trigger_id t = Menu.trigger_id t.id
let close t = Effect.Many [ t.on_change Closed; Loon.Focus.restore (trigger_id t) ]

let trigger ?(attrs = []) ?class_ ?(disabled = false) t children =
  let open_ = is_open t in
  let open_first = t.on_change (Open { Menu.State.initial with highlighted = Some [] }) in
  Node.button
    ~attrs:
      ([ Attr.type_ "button"
       ; data "slot" "dropdown-menu-trigger"
       ; Cn.with_class ?class_ [ trigger_class ]
       ; Attr.id (trigger_id t)
       ; aria "haspopup" "menu"
       ; aria "expanded" (Bool.to_string open_)
       ]
       @ (if open_ then [ aria "controls" (Menu.content_id t.id); data "popup-open" "" ] else [])
       @ (if disabled
          then [ Attr.disabled; data "disabled" "" ]
          else
            [ Attr.on_click (fun _ -> if open_ then close t else set_open t true)
            ; Attr.on_keydown (fun ev ->
                match Loon.Dom_util.key ev with
                | Enter | Space ->
                  Effect.Many
                    [ Loon.Dom_util.prevent_default ev
                    ; (if open_ then close t else open_first)
                    ]
                | ArrowDown -> Effect.Many [ Loon.Dom_util.prevent_default ev; open_first ]
                | _ -> Effect.Ignore)
            ])
       @ attrs)
    children
;;

let resolve items (s : Menu.State.t) =
  match s.highlighted with
  | Some [] -> Menu.first_highlighted items
  | _ -> s
;;

let content
  ?attrs
  ?class_
  ?(side = Loon.Popper.Side.Bottom)
  ?(side_offset = 20.)
  ?(align = Loon.Popper.Align.Start)
  ?(align_offset = 0.)
  ?anchor
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
      ~side
      ~side_offset
      ~align
      ~align_offset
      ~modal:false
      ~inside:(trigger_id t :: Option.to_list anchor)
      ~base_class:content_class
      ~anchor:(Element (Option.value anchor ~default:(trigger_id t)))
      menu
      items
;;

let group = Menu.group
let label = Menu.label

let item ?attrs ?class_ ?disabled ?text_value ?close_on_select ?on_select children =
  Menu.item ?attrs ?class_ ?disabled ?text_value ?close_on_select ?on_select children
;;

module Radio_item = struct
  type t =
    checked:string
    -> on_value_change:(string -> unit Effect.t)
    -> on_item_preview:(string -> unit Effect.t) option
    -> Menu.Item.t
end

let radio_group ?(attrs = []) ?on_item_preview ~value ~on_value_change items =
  Menu.radio_group
    ~attrs
    ~value
    ~on_value_change
    (List.map items ~f:(fun (item : Radio_item.t) ->
       item ~checked:value ~on_value_change ~on_item_preview))
;;

let radio_item
  ?(attrs = [])
  ?(class_ = "")
  ?disabled
  ?text_value
  ?(close_on_select = false)
  ~value
  children
  : Radio_item.t
  =
  fun ~checked ~on_value_change:_ ~on_item_preview ->
  let is_checked = String.equal checked value in
  let preview =
    match on_item_preview with
    | None -> []
    | Some f ->
      [ Attr.on_mousemove (fun _ -> f value); Attr.on_focus (fun _ -> f value) ]
  in
  Menu.radio_item
    ~attrs:(preview @ attrs)
    ~class_:(Cn.cn [ radio_item_class; class_ ])
    ?disabled
    ?text_value
    ~close_on_select
    ~value
    (Node.span
       ~attrs:
         [ Attr.class_ "pointer-events-none absolute right-2 flex items-center justify-center"
         ; data "slot" "dropdown-menu-radio-item-indicator"
         ]
       (if is_checked
        then [ Loon.Icon.view ~class_:"size-4 pointer-coarse:size-5" Check ]
        else [])
     :: children)
;;

let separator ?attrs ?class_ () = Menu.separator ?attrs ?class_ ()
let shortcut ?attrs ?class_ children = Menu.shortcut classes ?attrs ?class_ children
let node = Menu.node
