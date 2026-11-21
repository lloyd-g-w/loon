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
  let%arr open_
  and set_open
  and open_mobile
  and set_open_mobile
  and is_mobile in
  create
    ~persist
    ~open_
    ~on_open_change:set_open
    ~open_mobile
    ~on_open_mobile_change:set_open_mobile
    ~is_mobile
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

(* The sheet the sidebar becomes on phones: shadcn's [SheetContent] with
   its overlay, a modal dialog (Esc or a click on the overlay closes it,
   Tab stays inside). *)
let mobile_sheet ~attrs ~side t children =
  if not t.open_mobile
  then Node.none
  else (
    let id = "sidebar-mobile" in
    let close = t.set_open_mobile false in
    let focus_inside (el : Dom_html.element Js.t) =
      let active : Dom_html.element Js.t Js.opt =
        (Js.Unsafe.coerce Dom_html.document)##.activeElement
      in
      let inside =
        Js.Opt.case
          active
          (fun () -> false)
          (fun active -> Js.to_bool ((Js.Unsafe.coerce el)##contains active))
      in
      if not inside
      then Effect.Expert.handle_non_dom_event_exn (Focus.first_in id)
    in
    let side_classes =
      match (side : Side.t) with
      | Left ->
        "inset-y-0 left-0 h-full w-3/4 border-r \
         data-[state=closed]:slide-out-to-left \
         data-[state=open]:slide-in-from-left sm:max-w-sm"
      | Right ->
        "inset-y-0 right-0 h-full w-3/4 border-l \
         data-[state=closed]:slide-out-to-right \
         data-[state=open]:slide-in-from-right sm:max-w-sm"
    in
    Node.div
      [ Node.div
          ~attrs:
            [ data "state" "open"
            ; data "slot" "sheet-overlay"
            ; Attr.class_
                "fixed inset-0 z-50 bg-black/50 \
                 data-[state=closed]:animate-out \
                 data-[state=closed]:fade-out-0 data-[state=open]:animate-in \
                 data-[state=open]:fade-in-0"
            ; Attr.on_click (fun _ -> close)
            ]
          []
      ; Focus.guard ~id `Start
      ; Node.div
          ~attrs:
            ([ Attr.id id
             ; Attr.role "dialog"
             ; aria "modal" "true"
             ; aria "labelledby" (id ^ "-title")
             ; aria "describedby" (id ^ "-description")
             ; data "state" "open"
             ; Attr.tabindex (-1)
             ; data "sidebar" "sidebar"
             ; data "slot" "sidebar"
             ; data "mobile" "true"
             ; Attr.__css_vars_no_kebabs [ "--sidebar-width", width_mobile ]
             ; Cn.attr
                 [ "fixed z-50 flex flex-col gap-4 bg-background shadow-lg \
                    transition ease-in-out data-[state=closed]:animate-out \
                    data-[state=closed]:duration-300 \
                    data-[state=open]:animate-in \
                    data-[state=open]:duration-500"
                 ; side_classes
                 ; "w-(--sidebar-width) bg-sidebar p-0 text-sidebar-foreground \
                    [&>button]:hidden"
                 ]
             ; Attr.on_keydown (fun ev ->
                 match Dom_util.key ev with
                 | Escape -> Effect.Many [ Dom_util.stop ev; close ]
                 | _ -> Effect.Ignore)
             ; After_render.attr ~name:"sidebar-mobile-focus" focus_inside
             ]
             @ attrs)
          [ Node.div
              ~attrs:
                [ data "slot" "sheet-header"
                ; Attr.class_ "flex flex-col gap-1.5 p-4 sr-only"
                ]
              [ Node.h2
                  ~attrs:
                    [ Attr.id (id ^ "-title")
                    ; data "slot" "sheet-title"
                    ; Attr.class_ "font-semibold text-foreground"
                    ]
                  [ Node.text "Sidebar" ]
              ; Node.p
                  ~attrs:
                    [ Attr.id (id ^ "-description")
                    ; data "slot" "sheet-description"
                    ; Attr.class_ "text-sm text-muted-foreground"
                    ]
                  [ Node.text "Displays the mobile sidebar." ]
              ]
          ; Node.div
              ~attrs:[ Attr.class_ "flex h-full w-full flex-col" ]
              children
          ]
      ; Focus.guard ~id `End
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

(* The tooltip of a menu button: in the page after it (Radix puts it in a
   portal), shown while the button is hovered or focused and the sidebar
   is collapsed to its icons; [fixed], so the sidebar's [overflow-hidden]
   does not clip it, and placed at the button's right when shown. *)
let place_tooltip (ev : #Dom_html.event Js.t) =
  Effect.of_thunk (fun () ->
    Js.Opt.iter
      (Js.Unsafe.coerce ev)##.currentTarget
      (fun (button : Dom_html.element Js.t) ->
         Js.Opt.iter
           (Js.Unsafe.coerce button)##.nextElementSibling
           (fun (tip : Dom_html.element Js.t) ->
              let rect = button##getBoundingClientRect in
              let style = (Js.Unsafe.coerce tip)##.style in
              style##.left
              := Js.string (sprintf "%gpx" (Js.to_float rect##.right +. 5.));
              style##.top
              := Js.string
                   (sprintf
                      "%gpx"
                      ((Js.to_float rect##.top +. Js.to_float rect##.bottom)
                       /. 2.)))))
;;

let tooltip_view text =
  Node.div
    ~attrs:
      [ Attr.role "tooltip"
      ; data "slot" "tooltip-content"
      ; data "side" "right"
      ; Attr.class_
          (Cn.cn
             [ "z-50 w-fit origin-(--radix-tooltip-content-transform-origin) \
                animate-in rounded-md bg-foreground px-3 py-1.5 text-xs \
                text-balance text-background fade-in-0 zoom-in-95 \
                data-[side=bottom]:slide-in-from-top-2 \
                data-[side=left]:slide-in-from-right-2 \
                data-[side=right]:slide-in-from-left-2 \
                data-[side=top]:slide-in-from-bottom-2 \
                data-[state=closed]:animate-out data-[state=closed]:fade-out-0 \
                data-[state=closed]:zoom-out-95"
             ; "pointer-events-none fixed hidden -translate-y-1/2 \
                group-data-[collapsible=icon]:peer-hover/menu-button:block \
                group-data-[collapsible=icon]:peer-focus-visible/menu-button:block"
             ])
      ]
    [ Node.text text
    ; Node.div
        ~attrs:
          [ Attr.class_
              "absolute top-1/2 left-0 z-50 size-2.5 -translate-x-1/2 \
               -translate-y-1/2 rotate-45 rounded-[2px] bg-foreground \
               fill-foreground"
          ]
        []
    ]
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
    @ (match tooltip with
       | None -> []
       | Some _ ->
         [ Attr.on_pointerenter place_tooltip; Attr.on_focus place_tooltip ])
    @ attrs
  in
  let button =
    match href with
    | Some href -> Node.a ~attrs:(Attr.href href :: attrs) children
    | None -> Node.button ~attrs:(Attr.type_ "button" :: attrs) children
  in
  match tooltip with
  | None -> button
  | Some text -> Node.fragment [ button; tooltip_view text ]
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
