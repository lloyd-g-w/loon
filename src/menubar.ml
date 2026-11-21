open! Import

let classes : Menu.Classes.t =
  { slot = "menubar"
  ; item =
      "relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm \
       outline-hidden select-none focus:bg-accent focus:text-accent-foreground \
       data-[disabled]:pointer-events-none data-[disabled]:opacity-50 \
       data-[inset]:pl-8 data-[variant=destructive]:text-destructive \
       data-[variant=destructive]:focus:bg-destructive/10 \
       data-[variant=destructive]:focus:text-destructive \
       dark:data-[variant=destructive]:focus:bg-destructive/20 \
       [&_svg]:pointer-events-none [&_svg]:shrink-0 \
       [&_svg:not([class*='size-'])]:size-4 \
       [&_svg:not([class*='text-'])]:text-muted-foreground \
       data-[variant=destructive]:*:[svg]:text-destructive!"
  ; checkbox_item =
      "relative flex cursor-default items-center gap-2 rounded-xs py-1.5 pr-2 pl-8 \
       text-sm outline-hidden select-none focus:bg-accent \
       focus:text-accent-foreground data-[disabled]:pointer-events-none \
       data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 \
       [&_svg:not([class*='size-'])]:size-4"
  ; radio_item =
      "relative flex cursor-default items-center gap-2 rounded-xs py-1.5 pr-2 pl-8 \
       text-sm outline-hidden select-none focus:bg-accent \
       focus:text-accent-foreground data-[disabled]:pointer-events-none \
       data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 \
       [&_svg:not([class*='size-'])]:size-4"
  ; indicator =
      "pointer-events-none absolute left-2 flex size-3.5 items-center justify-center"
  ; label = "px-2 py-1.5 text-sm font-medium data-[inset]:pl-8"
  ; separator = "-mx-1 my-1 h-px bg-border"
  ; shortcut = "ml-auto text-xs tracking-widest text-muted-foreground"
  ; sub_trigger =
      "flex cursor-default items-center rounded-sm px-2 py-1.5 text-sm outline-none \
       select-none focus:bg-accent focus:text-accent-foreground data-[inset]:pl-8 \
       data-[state=open]:bg-accent data-[state=open]:text-accent-foreground"
  ; sub_trigger_icon = "ml-auto h-4 w-4"
  ; sub_content =
      "z-50 min-w-[8rem] origin-(--radix-menubar-content-transform-origin) \
       overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground \
       shadow-lg data-[side=bottom]:slide-in-from-top-2 \
       data-[side=left]:slide-in-from-right-2 \
       data-[side=right]:slide-in-from-left-2 \
       data-[side=top]:slide-in-from-bottom-2 data-[state=closed]:animate-out \
       data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 \
       data-[state=open]:animate-in data-[state=open]:fade-in-0 \
       data-[state=open]:zoom-in-95"
  }
;;

let content_class =
  "z-50 min-w-[12rem] origin-(--radix-menubar-content-transform-origin) \
   overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground \
   shadow-md data-[side=bottom]:slide-in-from-top-2 \
   data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 \
   data-[side=top]:slide-in-from-bottom-2 data-[state=closed]:fade-out-0 \
   data-[state=closed]:zoom-out-95 data-[state=open]:animate-in \
   data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95"
;;

let root_class = "flex h-9 items-center gap-1 rounded-md border bg-background p-1 shadow-xs"

let trigger_class =
  "flex items-center rounded-sm px-2 py-1 text-sm font-medium outline-hidden \
   select-none focus:bg-accent focus:text-accent-foreground \
   data-[state=open]:bg-accent data-[state=open]:text-accent-foreground"
;;

module State = struct
  type t =
    { value : string option
    ; current : string option
    ; menu : Menu.State.t
    }
  [@@deriving sexp_of, equal]

  let closed = { value = None; current = None; menu = Menu.State.initial }
end

module Trigger = struct
  type t =
    { attrs : Attr.t list
    ; class_ : string option
    ; disabled : bool
    ; children : Node.t list
    }
end

module Content = struct
  type t =
    { attrs : Attr.t list
    ; class_ : string option
    ; side : Popper.Side.t option
    ; side_offset : float
    ; align : Popper.Align.t
    ; align_offset : float
    ; avoid_collisions : bool option
    ; items : Menu.Item.t list
    }
end

module Menu_ = struct
  type t =
    { value : string option
    ; trigger : Trigger.t
    ; content : Content.t
    }
end

let trigger ?(attrs = []) ?class_ ?(disabled = false) children : Trigger.t =
  { attrs; class_; disabled; children }
;;

let content
  ?(attrs = [])
  ?class_
  ?side
  ?(side_offset = 8.)
  ?(align = Popper.Align.Start)
  ?(align_offset = -4.)
  ?avoid_collisions
  items
  : Content.t
  =
  { attrs; class_; side; side_offset; align; align_offset; avoid_collisions; items }
;;

let menu ?value trigger content : Menu_.t = { value; trigger; content }

let view ?(attrs = []) ?class_ ?(id = "menubar") ~state ~on_change (menus : Menu_.t list) =
  let state : State.t = state in
  let menus =
    List.mapi menus ~f:(fun i (m : Menu_.t) ->
      Option.value m.value ~default:(Int.to_string i), m)
  in
  let enabled =
    List.filter_map menus ~f:(fun (v, m) -> Option.some_if (not m.trigger.disabled) v)
  in
  let menu_id v = sprintf "%s-%s" id v in
  let trigger_id v = Menu.trigger_id (menu_id v) in
  let neighbour v dir =
    let a = Array.of_list enabled in
    let n = Array.length a in
    match Array.findi a ~f:(fun _ x -> String.equal x v) with
    | None -> None
    | Some (i, _) ->
      let j =
        match dir with
        | `Left -> (i - 1 + n) % n
        | `Right -> (i + 1) % n
      in
      Some a.(j)
  in
  let items_of v =
    List.find_map menus ~f:(fun (v', m) ->
      Option.some_if (String.equal v v') m.content.items)
    |> Option.value ~default:[]
  in
  let open_menu ?(first = false) v =
    on_change
      { State.value = Some v
      ; current = Some v
      ; menu = (if first then Menu.first_highlighted (items_of v) else Menu.State.initial)
      }
  in
  let close v =
    Effect.Many
      [ on_change { State.closed with current = Some v }; Focus.restore (trigger_id v) ]
  in
  let tab_stop =
    match state.current with
    | Some v when List.mem enabled v ~equal:String.equal -> Some v
    | _ -> List.hd enabled
  in
  let render_menu (v, (m : Menu_.t)) =
    let is_open = Option.equal String.equal state.value (Some v) in
    let tr = m.trigger in
    let trigger =
      Node.button
        ~attrs:
          ([ data "slot" "menubar-trigger"
           ; Cn.with_class ?class_:tr.class_ [ trigger_class ]
           ; Attr.type_ "button"
           ; Attr.role "menuitem"
           ; Attr.id (trigger_id v)
           ; aria "haspopup" "menu"
           ; aria_bool "expanded" is_open
           ]
           @ (if is_open then [ aria "controls" (Menu.content_id (menu_id v)) ] else [])
           @ [ data "state" (if is_open then "open" else "closed")
             ; Attr.tabindex
                 (if Option.equal String.equal tab_stop (Some v) then 0 else -1)
             ]
           @ (if tr.disabled
              then [ Attr.disabled; data "disabled" "" ]
              else
                [ Attr.on_click (fun _ -> if is_open then close v else open_menu v)
                ; Attr.on_mouseenter (fun _ ->
                    match state.value with
                    | Some open_ when not (String.equal open_ v) ->
                      Effect.Many [ open_menu v; Focus.restore (trigger_id v) ]
                    | _ -> Effect.Ignore)
                ; Attr.on_focus (fun _ ->
                    if Option.equal String.equal state.current (Some v)
                    then Effect.Ignore
                    else on_change { state with current = Some v })
                ; Attr.on_keydown (fun ev ->
                    match Dom_util.key ev with
                    | Enter | Space | ArrowDown ->
                      Effect.Many [ Dom_util.prevent_default ev; open_menu ~first:true v ]
                    | ArrowRight | ArrowLeft ->
                      let dir =
                        match Dom_util.key ev with
                        | ArrowLeft -> `Left
                        | _ -> `Right
                      in
                      (match neighbour v dir with
                       | Some w ->
                         Effect.Many
                           [ Dom_util.prevent_default ev
                           ; on_change { state with current = Some w }
                           ; Focus.restore (trigger_id w)
                           ]
                       | None -> Effect.Ignore)
                    | Home | End ->
                      let w =
                        match Dom_util.key ev with
                        | Home -> List.hd enabled
                        | _ -> List.last enabled
                      in
                      (match w with
                       | Some w ->
                         Effect.Many
                           [ Dom_util.prevent_default ev
                           ; on_change { state with current = Some w }
                           ; Focus.restore (trigger_id w)
                           ]
                       | None -> Effect.Ignore)
                    | _ -> Effect.Ignore)
                ])
           @ tr.attrs)
        tr.children
    in
    let content =
      if not is_open
      then Node.none
      else (
        let c = m.content in
        let menu : Menu.t =
          { id = menu_id v
          ; classes
          ; state = state.menu
          ; set_state = (fun menu -> on_change { state with menu })
          ; close = close v
          ; on_edge =
              Some
                (fun dir ->
                  match neighbour v dir with
                  | Some w -> open_menu ~first:true w
                  | None -> Effect.Ignore)
          }
        in
        Menu.content
          ~attrs:c.attrs
          ?class_:c.class_
          ?side:c.side
          ~side_offset:c.side_offset
          ~align:c.align
          ~align_offset:c.align_offset
          ?avoid_collisions:c.avoid_collisions
          ~modal:false
          ~inside:(List.map enabled ~f:trigger_id)
          ~base_class:content_class
          ~anchor:(Element (trigger_id v))
          menu
          c.items)
    in
    Node.fragment [ trigger; content ]
  in
  Node.div
    ~attrs:
      ([ data "slot" "menubar"
       ; Cn.with_class ?class_ [ root_class ]
       ; Attr.role "menubar"
       ; aria "orientation" "horizontal"
       ]
       @ attrs)
    (List.map menus ~f:render_menu)
;;

let component ?attrs ?class_ menus (local_ graph) =
  let open Bonsai.Let_syntax in
  let state, set_state = Bonsai.state State.closed graph in
  let id = Bonsai.path_id graph in
  let%arr state and set_state and id and menus in
  view ?attrs ?class_ ~id ~state ~on_change:set_state menus
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
