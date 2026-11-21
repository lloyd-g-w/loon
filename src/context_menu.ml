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
      "relative flex cursor-default items-center gap-2 rounded-sm py-1.5 pr-2 pl-8 \
       text-sm outline-hidden select-none focus:bg-accent \
       focus:text-accent-foreground data-[disabled]:pointer-events-none \
       data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 \
       [&_svg:not([class*='size-'])]:size-4"
  ; radio_item =
      "relative flex cursor-default items-center gap-2 rounded-sm py-1.5 pr-2 pl-8 \
       text-sm outline-hidden select-none focus:bg-accent \
       focus:text-accent-foreground data-[disabled]:pointer-events-none \
       data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 \
       [&_svg:not([class*='size-'])]:size-4"
  ; indicator =
      "pointer-events-none absolute left-2 flex size-3.5 items-center justify-center"
  ; label = "px-2 py-1.5 text-sm font-medium text-foreground data-[inset]:pl-8"
  ; separator = "-mx-1 my-1 h-px bg-border"
  ; shortcut = "ml-auto text-xs tracking-widest text-muted-foreground"
  ; sub_trigger =
      "flex cursor-default items-center rounded-sm px-2 py-1.5 text-sm outline-hidden \
       select-none focus:bg-accent focus:text-accent-foreground data-[inset]:pl-8 \
       data-[state=open]:bg-accent \
       data-[state=open]:text-accent-foreground [&_svg]:pointer-events-none \
       [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 \
       [&_svg:not([class*='text-'])]:text-muted-foreground"
  ; sub_trigger_icon = "ml-auto"
  ; sub_content =
      "z-50 min-w-[8rem] origin-(--radix-context-menu-content-transform-origin) \
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
  "z-50 max-h-(--radix-context-menu-content-available-height) min-w-[8rem] \
   origin-(--radix-context-menu-content-transform-origin) overflow-x-hidden \
   overflow-y-auto rounded-md border bg-popover p-1 text-popover-foreground \
   shadow-md data-[side=bottom]:slide-in-from-top-2 \
   data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 \
   data-[side=top]:slide-in-from-bottom-2 data-[state=closed]:animate-out \
   data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 \
   data-[state=open]:animate-in data-[state=open]:fade-in-0 \
   data-[state=open]:zoom-in-95"
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
       @ Option.value_map class_ ~default:[] ~f:(fun c -> [ Attr.class_ c ])
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
let radio_item = Menu.radio_item
let separator = Menu.separator
let shortcut = Menu.shortcut classes
let sub = Menu.sub
let sub_trigger = Menu.sub_trigger
let sub_content = Menu.sub_content
