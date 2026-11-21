open! Import
open Js_of_ocaml

module State = struct
  type t =
    | Expanded
    | Collapsed
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Expanded -> "expanded"
    | Collapsed -> "collapsed"
  ;;
end

module Side = struct
  type t =
    | Left
    | Right
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Left -> "left"
    | Right -> "right"
  ;;
end

module Variant = struct
  type t =
    | Sidebar
    | Floating
    | Inset
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Sidebar -> "sidebar"
    | Floating -> "floating"
    | Inset -> "inset"
  ;;
end

module Collapsible = struct
  type t =
    | Offcanvas
    | Icon
    | None
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Offcanvas -> "offcanvas"
    | Icon -> "icon"
    | None -> "none"
  ;;
end

type t =
  { open_ : bool
  ; set_open : bool -> unit Effect.t
  ; open_mobile : bool
  ; set_open_mobile : bool -> unit Effect.t
  ; is_mobile : bool
  ; tooltip : string option
  ; set_tooltip : string option -> unit Effect.t
  }

let cookie_name = "sidebar_state"
let cookie_max_age = 60 * 60 * 24 * 7
let width = "16rem"
let width_mobile = "18rem"
let width_icon = "3rem"
let in_browser () = Js.Optdef.test (Js.Unsafe.global##.document : _ Js.Optdef.t)

let write_cookie value =
  Effect.of_thunk (fun () ->
    if in_browser ()
    then
      Dom_html.document##.cookie
      := Js.string
           (sprintf
              "%s=%b; path=/; max-age=%d"
              cookie_name
              value
              cookie_max_age))
;;

let read_cookie () =
  if not (in_browser ())
  then None
  else
    String.split (Js.to_string Dom_html.document##.cookie) ~on:';'
    |> List.find_map ~f:(fun pair ->
      match String.lsplit2 (String.strip pair) ~on:'=' with
      | Some (name, "true") when String.equal name cookie_name -> Some true
      | Some (name, "false") when String.equal name cookie_name -> Some false
      | _ -> None)
;;

let create
      ?(persist = true)
      ~open_
      ~on_open_change
      ~open_mobile
      ~on_open_mobile_change
      ~is_mobile
      ?open_tooltip
      ?(on_open_tooltip_change = fun _ -> Effect.Ignore)
      ()
  =
  let set_open value =
    if persist
    then Effect.Many [ on_open_change value; write_cookie value ]
    else on_open_change value
  in
  { open_
  ; set_open
  ; open_mobile
  ; set_open_mobile = on_open_mobile_change
  ; is_mobile
  ; tooltip = open_tooltip
  ; set_tooltip = on_open_tooltip_change
  }
;;

let component ?(default_open = true) ?(persist = true) (local_ graph) =
  let open Bonsai.Let_syntax in
  let initial =
    if persist
    then Option.value (read_cookie ()) ~default:default_open
    else default_open
  in
  let open_, set_open = Bonsai.state initial graph in
  let open_mobile, set_open_mobile = Bonsai.state false graph in
  let is_mobile = Use_mobile.component graph in
  let tooltip, set_tooltip = Bonsai.state None graph in
  let%arr open_
  and set_open
  and open_mobile
  and set_open_mobile
  and is_mobile
  and tooltip
  and set_tooltip in
  create
    ~persist
    ~open_
    ~on_open_change:set_open
    ~open_mobile
    ~on_open_mobile_change:set_open_mobile
    ~is_mobile
    ?open_tooltip:tooltip
    ~on_open_tooltip_change:set_tooltip
    ()
;;

let state t = if t.open_ then State.Expanded else Collapsed
let open_ t = t.open_
let set_open t = t.set_open
let open_mobile t = t.open_mobile
let set_open_mobile t = t.set_open_mobile
let is_mobile t = t.is_mobile

let toggle t =
  if t.is_mobile
  then t.set_open_mobile (not t.open_mobile)
  else t.set_open (not t.open_)
;;

let slot name = [ data "slot" ("sidebar-" ^ name); data "sidebar" name ]

let provider ?(attrs = []) ?class_ ?(keyboard_shortcut = true) t children =
  let shortcut =
    if not keyboard_shortcut
    then []
    else
      [ Attr.Global_listeners.keydown ~phase:Bubbling ~f:(fun ev ->
          let key = Js.Optdef.case ev##.key (fun () -> "") Js.to_string in
          if
            String.equal key "b"
            && (Js.to_bool ev##.metaKey || Js.to_bool ev##.ctrlKey)
          then Effect.Many [ Dom_util.prevent_default ev; toggle t ]
          else Effect.Ignore)
      ]
  in
  Node.div
    ~attrs:
      ([ data "slot" "sidebar-wrapper"
       ; Attr.__css_vars_no_kebabs
           [ "--sidebar-width", width; "--sidebar-width-icon", width_icon ]
       ; Cn.with_class
           ?class_
           [ "group/sidebar-wrapper flex min-h-svh w-full \
              has-data-[variant=inset]:bg-sidebar"
           ]
       ]
       @ shortcut
       @ attrs)
    children
;;

(* The sheet the sidebar becomes on phones: shadcn's [Sheet], its close
   button hidden by [[&>button]:hidden] as in shadcn. *)
let mobile_sheet ~attrs ~side t children =
  Sheet.view
    ~id:"sidebar-mobile"
    ~open_:t.open_mobile
    ~on_open_change:t.set_open_mobile
    (fun sheet ->
       [ Sheet.content
           ~side:
             (match (side : Side.t) with
              | Left -> Left
              | Right -> Right)
           ~class_:
             "w-(--sidebar-width) bg-sidebar p-0 text-sidebar-foreground \
              [&>button]:hidden"
           ~attrs:
             ([ data "sidebar" "sidebar"
              ; Attr.suppress_merge_warnings (data "slot" "sidebar")
              ; data "mobile" "true"
              ; Attr.__css_vars_no_kebabs [ "--sidebar-width", width_mobile ]
              ]
              @ attrs)
           sheet
           [ Sheet.header
               ~class_:"sr-only"
               [ Sheet.title sheet [ Node.text "Sidebar" ]
               ; Sheet.description sheet [ Node.text "Displays the mobile sidebar." ]
               ]
           ; Node.div
               ~attrs:[ Attr.class_ "flex h-full w-full flex-col" ]
               children
           ]
       ])
;;

let root
      ?(attrs = [])
      ?class_
      ?(side = Side.Left)
      ?(variant = Variant.Sidebar)
      ?(collapsible = Collapsible.Offcanvas)
      t
      children
  =
  match collapsible with
  | None ->
    Node.div
      ~attrs:
        ([ data "slot" "sidebar"
         ; Cn.with_class
             ?class_
             [ "flex h-full w-(--sidebar-width) flex-col bg-sidebar \
                text-sidebar-foreground"
             ]
         ]
         @ attrs)
      children
  | (Offcanvas | Icon) when t.is_mobile -> mobile_sheet ~attrs ~side t children
  | Offcanvas | Icon ->
    let state = state t in
    let floating_or_inset =
      match variant with
      | Floating | Inset -> true
      | Sidebar -> false
    in
    Node.div
      ~attrs:
        [ Attr.class_ "group peer hidden text-sidebar-foreground md:block"
        ; data "state" (State.name state)
        ; data
            "collapsible"
            (match state with
             | Collapsed -> Collapsible.name collapsible
             | Expanded -> "")
        ; data "variant" (Variant.name variant)
        ; data "side" (Side.name side)
        ; data "slot" "sidebar"
        ]
      [ Node.div
          ~attrs:
            [ data "slot" "sidebar-gap"
            ; Cn.attr
                [ "relative w-(--sidebar-width) bg-transparent \
                   transition-[width] duration-200 ease-linear"
                ; "group-data-[collapsible=offcanvas]:w-0"
                ; "group-data-[side=right]:rotate-180"
                ; (if floating_or_inset
                   then
                     "group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+(--spacing(4)))]"
                   else "group-data-[collapsible=icon]:w-(--sidebar-width-icon)")
                ]
            ]
          []
      ; Node.div
          ~attrs:
            ([ data "slot" "sidebar-container"
             ; Cn.attr
                 [ "fixed inset-y-0 z-10 hidden h-svh w-(--sidebar-width) \
                    transition-[left,right,width] duration-200 ease-linear \
                    md:flex"
                 ; (match side with
                    | Left ->
                      "left-0 \
                       group-data-[collapsible=offcanvas]:left-[calc(var(--sidebar-width)*-1)]"
                    | Right ->
                      "right-0 \
                       group-data-[collapsible=offcanvas]:right-[calc(var(--sidebar-width)*-1)]")
                 ; (if floating_or_inset
                    then
                      "p-2 \
                       group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+(--spacing(4))+2px)]"
                    else
                      "group-data-[collapsible=icon]:w-(--sidebar-width-icon) \
                       group-data-[side=left]:border-r \
                       group-data-[side=right]:border-l")
                 ; Option.value class_ ~default:""
                 ]
             ]
             @ attrs)
          [ Node.div
              ~attrs:
                [ data "sidebar" "sidebar"
                ; data "slot" "sidebar-inner"
                ; Attr.class_
                    "flex h-full w-full flex-col bg-sidebar \
                     group-data-[variant=floating]:rounded-lg \
                     group-data-[variant=floating]:border \
                     group-data-[variant=floating]:border-sidebar-border \
                     group-data-[variant=floating]:shadow-sm"
                ]
              children
          ]
      ]
;;

let trigger ?(attrs = []) ?class_ ?on_click t =
  Node.button
    ~attrs:
      ([ Attr.type_ "button"
       ; data "variant" "ghost"
       ; data "size" "icon"
       ; data "sidebar" "trigger"
       ; data "slot" "sidebar-trigger"
       ; Attr.class_
           (Button.classes
              ~variant:Ghost
              ~size:Icon
              ~class_:(Cn.cn [ "size-7"; Option.value class_ ~default:"" ])
              ())
       ; Attr.on_click (fun _ ->
           Effect.Many (Option.to_list on_click @ [ toggle t ]))
       ]
       @ attrs)
    [ Icon.view Panel_left
    ; Node.span ~attrs:[ Attr.class_ "sr-only" ] [ Node.text "Toggle Sidebar" ]
    ]
;;

let rail ?(attrs = []) ?class_ t =
  Node.button
    ~attrs:
      ([ Attr.type_ "button"
       ; data "sidebar" "rail"
       ; data "slot" "sidebar-rail"
       ; aria "label" "Toggle Sidebar"
       ; Attr.tabindex (-1)
       ; Attr.on_click (fun _ -> toggle t)
       ; Attr.title "Toggle Sidebar"
       ; Cn.with_class
           ?class_
           [ "absolute inset-y-0 z-20 hidden w-4 -translate-x-1/2 \
              transition-all ease-linear group-data-[side=left]:-right-4 \
              group-data-[side=right]:left-0 after:absolute after:inset-y-0 \
              after:left-1/2 after:w-[2px] hover:after:bg-sidebar-border \
              sm:flex"
           ; "in-data-[side=left]:cursor-w-resize \
              in-data-[side=right]:cursor-e-resize"
           ; "[[data-side=left][data-state=collapsed]_&]:cursor-e-resize \
              [[data-side=right][data-state=collapsed]_&]:cursor-w-resize"
           ; "group-data-[collapsible=offcanvas]:translate-x-0 \
              group-data-[collapsible=offcanvas]:after:left-full \
              hover:group-data-[collapsible=offcanvas]:bg-sidebar"
           ; "[[data-side=left][data-collapsible=offcanvas]_&]:-right-2"
           ; "[[data-side=right][data-collapsible=offcanvas]_&]:-left-2"
           ]
       ]
       @ attrs)
    []
;;

let inset ?(attrs = []) ?class_ children =
  Node.main
    ~attrs:
      ([ data "slot" "sidebar-inset"
       ; Cn.with_class
           ?class_
           [ "relative flex w-full flex-1 flex-col bg-background"
           ; "md:peer-data-[variant=inset]:m-2 \
              md:peer-data-[variant=inset]:ml-0 \
              md:peer-data-[variant=inset]:rounded-xl \
              md:peer-data-[variant=inset]:shadow-sm \
              md:peer-data-[variant=inset]:peer-data-[state=collapsed]:ml-2"
           ]
       ]
       @ attrs)
    children
;;

let input ?(attrs = []) ?class_ ?type_ ?id ?placeholder ?value ?on_input () =
  Input.view
    ~class_:(Cn.cn ("h-8 w-full bg-background shadow-none" :: Option.to_list class_))
    ~attrs:(data "sidebar" "input" :: attrs)
    ?type_
    ?id
    ?placeholder
    ?value
    ?on_input
    ()
;;

let div name base ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:(slot name @ [ Cn.with_class ?class_ [ base ] ] @ attrs)
    children
;;

let header = div "header" "flex flex-col gap-2 p-2"
let footer = div "footer" "flex flex-col gap-2 p-2"

let separator ?(attrs = []) ?class_ () =
  Separator.view
    ~class_:(Cn.cn ("mx-2 w-auto bg-sidebar-border" :: Option.to_list class_))
    ~attrs:(data "sidebar" "separator" :: attrs)
    ()
;;

let content =
  div
    "content"
    "flex min-h-0 flex-1 flex-col gap-2 overflow-auto \
     group-data-[collapsible=icon]:overflow-hidden"
;;

let group = div "group" "relative flex w-full min-w-0 flex-col p-2"

let group_label_classes ?class_ () =
  Cn.cn
    [ "flex h-8 shrink-0 items-center rounded-md px-2 text-xs font-medium \
       text-sidebar-foreground/70 ring-sidebar-ring outline-hidden \
       transition-[margin,opacity] duration-200 ease-linear \
       focus-visible:ring-2 [&>svg]:size-4 [&>svg]:shrink-0"
    ; "group-data-[collapsible=icon]:-mt-8 \
       group-data-[collapsible=icon]:opacity-0"
    ; Option.value class_ ~default:""
    ]
;;

let group_label ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      (slot "group-label"
       @ [ Attr.class_ (group_label_classes ?class_ ()) ]
       @ attrs)
    children
;;

let group_action_classes ?class_ () =
  Cn.cn
    [ "absolute top-3.5 right-3 flex aspect-square w-5 items-center \
       justify-center rounded-md p-0 text-sidebar-foreground ring-sidebar-ring \
       outline-hidden transition-transform hover:bg-sidebar-accent \
       hover:text-sidebar-accent-foreground focus-visible:ring-2 \
       [&>svg]:size-4 [&>svg]:shrink-0"
    ; "after:absolute after:-inset-2 md:after:hidden"
    ; "group-data-[collapsible=icon]:hidden"
    ; Option.value class_ ~default:""
    ]
;;

let on_click_attrs = function
  | None -> []
  | Some eff -> [ Attr.on_click (fun _ -> eff) ]
;;

let group_action ?(attrs = []) ?class_ ?on_click children =
  Node.button
    ~attrs:
      ((Attr.type_ "button" :: slot "group-action")
       @ [ Attr.class_ (group_action_classes ?class_ ()) ]
       @ on_click_attrs on_click
       @ attrs)
    children
;;

let group_content = div "group-content" "w-full text-sm"

let menu ?(attrs = []) ?class_ children =
  Node.ul
    ~attrs:
      (slot "menu"
       @ [ Cn.with_class ?class_ [ "flex w-full min-w-0 flex-col gap-1" ] ]
       @ attrs)
    children
;;

let menu_item ?(attrs = []) ?class_ children =
  Node.li
    ~attrs:
      (slot "menu-item"
       @ [ Cn.with_class ?class_ [ "group/menu-item relative" ] ]
       @ attrs)
    children
;;

module Menu_button_variant = struct
  type t =
    | Default
    | Outline
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Outline -> "outline"
  ;;

  let classes = function
    | Default -> "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
    | Outline ->
      "bg-background shadow-[0_0_0_1px_var(--sidebar-border)] \
       hover:bg-sidebar-accent hover:text-sidebar-accent-foreground \
       hover:shadow-[0_0_0_1px_var(--sidebar-accent)]"
  ;;
end

module Menu_button_size = struct
  type t =
    | Default
    | Sm
    | Lg
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Sm -> "sm"
    | Lg -> "lg"
  ;;

  let classes = function
    | Default -> "h-8 text-sm"
    | Sm -> "h-7 text-xs"
    | Lg -> "h-12 text-sm group-data-[collapsible=icon]:p-0!"
  ;;
end

let menu_button_classes
      ?(variant = Menu_button_variant.Default)
      ?(size = Menu_button_size.Default)
      ?class_
      ()
  =
  Cn.cn
    [ "peer/menu-button flex w-full items-center gap-2 overflow-hidden \
       rounded-md p-2 text-left text-sm ring-sidebar-ring outline-hidden \
       transition-[width,height,padding] \
       group-has-data-[sidebar=menu-action]/menu-item:pr-8 \
       group-data-[collapsible=icon]:size-8! \
       group-data-[collapsible=icon]:p-2! hover:bg-sidebar-accent \
       hover:text-sidebar-accent-foreground focus-visible:ring-2 \
       active:bg-sidebar-accent active:text-sidebar-accent-foreground \
       disabled:pointer-events-none disabled:opacity-50 \
       aria-disabled:pointer-events-none aria-disabled:opacity-50 \
       data-[active=true]:bg-sidebar-accent data-[active=true]:font-medium \
       data-[active=true]:text-sidebar-accent-foreground \
       data-[state=open]:hover:bg-sidebar-accent \
       data-[state=open]:hover:text-sidebar-accent-foreground \
       [&>span:last-child]:truncate [&>svg]:size-4 [&>svg]:shrink-0"
    ; Menu_button_variant.classes variant
    ; Menu_button_size.classes size
    ; Option.value class_ ~default:""
    ]
;;

module Menu_tooltip = struct
  type nonrec t =
    { sidebar : t
    ; id : string
    ; hidden : bool option
    ; text : string
    }
end

let menu_tooltip ?id ?hidden sidebar text =
  let id =
    match id with
    | Some id -> id
    | None ->
      "sidebar-tooltip-"
      ^ String.map text ~f:(fun c -> if Char.is_alphanum c then c else '-')
  in
  { Menu_tooltip.sidebar; id; hidden; text }
;;

let with_tooltip (tooltip : Menu_tooltip.t) button =
  let t = tooltip.sidebar in
  let hidden =
    match tooltip.hidden with
    | Some hidden -> hidden
    | None -> t.open_ || t.is_mobile
  in
  let open_ =
    (not hidden) && [%equal: string option] t.tooltip (Some tooltip.id)
  in
  Tooltip.view
    ~id:tooltip.id
    ~open_
    ~on_open_change:(fun o ->
      if o
      then if hidden then Effect.Ignore else t.set_tooltip (Some tooltip.id)
      else if [%equal: string option] t.tooltip (Some tooltip.id)
      then t.set_tooltip None
      else Effect.Ignore)
    (fun tip ->
       [ (* The button keeps its [data-slot], as Radix's Slot keeps the
            child's props. *)
         Slot.merge
           [ data "slot" "sidebar-menu-button" ]
           (Tooltip.trigger tip button)
       ; Tooltip.content
           ~side:Right
           ~align:Center
           tip
           [ Node.text tooltip.text ]
       ])
;;

let menu_button
      ?(attrs = [])
      ?class_
      ?(variant = Menu_button_variant.Default)
      ?(size = Menu_button_size.Default)
      ?(is_active = false)
      ?tooltip
      ?href
      ?on_click
      children
  =
  let attrs =
    slot "menu-button"
    @ [ data "size" (Menu_button_size.name size)
      ; data "active" (Bool.to_string is_active)
      ; Attr.class_ (menu_button_classes ~variant ~size ?class_ ())
      ]
    @ on_click_attrs on_click
    @ attrs
  in
  let button =
    match href with
    | Some href -> Node.a ~attrs:(Attr.href href :: attrs) children
    | None -> Node.button ~attrs:(Attr.type_ "button" :: attrs) children
  in
  match tooltip with
  | None -> button
  | Some tooltip -> with_tooltip tooltip button
;;

let menu_action
      ?(attrs = [])
      ?class_
      ?(show_on_hover = false)
      ?on_click
      children
  =
  Node.button
    ~attrs:
      ((Attr.type_ "button" :: slot "menu-action")
       @ [ Cn.with_class
             ?class_
             [ "absolute top-1.5 right-1 flex aspect-square w-5 items-center \
                justify-center rounded-md p-0 text-sidebar-foreground \
                ring-sidebar-ring outline-hidden transition-transform \
                peer-hover/menu-button:text-sidebar-accent-foreground \
                hover:bg-sidebar-accent hover:text-sidebar-accent-foreground \
                focus-visible:ring-2 [&>svg]:size-4 [&>svg]:shrink-0"
             ; "after:absolute after:-inset-2 md:after:hidden"
             ; "peer-data-[size=sm]/menu-button:top-1"
             ; "peer-data-[size=default]/menu-button:top-1.5"
             ; "peer-data-[size=lg]/menu-button:top-2.5"
             ; "group-data-[collapsible=icon]:hidden"
             ; (if show_on_hover
                then
                  "group-focus-within/menu-item:opacity-100 \
                   group-hover/menu-item:opacity-100 \
                   peer-data-[active=true]/menu-button:text-sidebar-accent-foreground \
                   data-[state=open]:opacity-100 md:opacity-0"
                else "")
             ]
         ]
       @ on_click_attrs on_click
       @ attrs)
    children
;;

let menu_badge ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      (slot "menu-badge"
       @ [ Cn.with_class
             ?class_
             [ "pointer-events-none absolute right-1 flex h-5 min-w-5 \
                items-center justify-center rounded-md px-1 text-xs \
                font-medium text-sidebar-foreground tabular-nums select-none"
             ; "peer-hover/menu-button:text-sidebar-accent-foreground \
                peer-data-[active=true]/menu-button:text-sidebar-accent-foreground"
             ; "peer-data-[size=sm]/menu-button:top-1"
             ; "peer-data-[size=default]/menu-button:top-1.5"
             ; "peer-data-[size=lg]/menu-button:top-2.5"
             ; "group-data-[collapsible=icon]:hidden"
             ]
         ]
       @ attrs)
    children
;;

let menu_skeleton ?(attrs = []) ?class_ ?(show_icon = false) ?(width = "70%") ()
  =
  Node.div
    ~attrs:
      (slot "menu-skeleton"
       @ [ Cn.with_class
             ?class_
             [ "flex h-8 items-center gap-2 rounded-md px-2" ]
         ]
       @ attrs)
    ((if show_icon
      then
        [ Skeleton.view
            ~class_:"size-4 rounded-md"
            ~attrs:[ data "sidebar" "menu-skeleton-icon" ]
            []
        ]
      else [])
     @ [ Skeleton.view
           ~class_:"h-4 max-w-(--skeleton-width) flex-1"
           ~attrs:
             [ data "sidebar" "menu-skeleton-text"
             ; Attr.__css_vars_no_kebabs [ "--skeleton-width", width ]
             ]
           []
       ])
;;

let menu_sub ?(attrs = []) ?class_ children =
  Node.ul
    ~attrs:
      (slot "menu-sub"
       @ [ Cn.with_class
             ?class_
             [ "mx-3.5 flex min-w-0 translate-x-px flex-col gap-1 border-l \
                border-sidebar-border px-2.5 py-0.5"
             ; "group-data-[collapsible=icon]:hidden"
             ]
         ]
       @ attrs)
    children
;;

let menu_sub_item ?(attrs = []) ?class_ children =
  Node.li
    ~attrs:
      (slot "menu-sub-item"
       @ [ Cn.with_class ?class_ [ "group/menu-sub-item relative" ] ]
       @ attrs)
    children
;;

module Menu_sub_button_size = struct
  type t =
    | Sm
    | Md
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Sm -> "sm"
    | Md -> "md"
  ;;

  let classes = function
    | Sm -> "text-xs"
    | Md -> "text-sm"
  ;;
end

let menu_sub_button
      ?(attrs = [])
      ?class_
      ?(size = Menu_sub_button_size.Md)
      ?(is_active = false)
      ?href
      children
  =
  Node.a
    ~attrs:
      (slot "menu-sub-button"
       @ [ data "size" (Menu_sub_button_size.name size)
         ; data "active" (Bool.to_string is_active)
         ]
       @ Option.value_map href ~default:[] ~f:(fun href -> [ Attr.href href ])
       @ [ Cn.with_class
             ?class_
             [ "flex h-7 min-w-0 -translate-x-px items-center gap-2 \
                overflow-hidden rounded-md px-2 text-sidebar-foreground \
                ring-sidebar-ring outline-hidden hover:bg-sidebar-accent \
                hover:text-sidebar-accent-foreground focus-visible:ring-2 \
                active:bg-sidebar-accent active:text-sidebar-accent-foreground \
                disabled:pointer-events-none disabled:opacity-50 \
                aria-disabled:pointer-events-none aria-disabled:opacity-50 \
                [&>span:last-child]:truncate [&>svg]:size-4 [&>svg]:shrink-0 \
                [&>svg]:text-sidebar-accent-foreground"
             ; "data-[active=true]:bg-sidebar-accent \
                data-[active=true]:text-sidebar-accent-foreground"
             ; Menu_sub_button_size.classes size
             ; "group-data-[collapsible=icon]:hidden"
             ]
         ]
       @ attrs)
    children
;;
