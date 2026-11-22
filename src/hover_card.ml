open! Import

type t =
  { id : string
  ; open_delay : float
  ; close_delay : float
  ; open_ : bool
  ; on_open_change : bool -> unit Effect.t
  }

let view ?(id = "hover-card") ?(open_delay = 700.) ?(close_delay = 300.) ~open_ ~on_open_change f =
  Node.fragment (f { id; open_delay; close_delay; open_; on_open_change })
;;

let component ?(default_open = false) ?open_delay ?close_delay f (local_ graph) =
  let open Bonsai.Let_syntax in
  let open_, set_open = Bonsai.state default_open graph in
  let id = Bonsai.path_id graph in
  let%arr open_ and set_open and id and f in
  view ~id ?open_delay ?close_delay ~open_ ~on_open_change:set_open f
;;

let trigger_id t = t.id ^ "-trigger"
let state t = data "state" (if t.open_ then "open" else "closed")

let open_later t =
  if t.open_
  then Delay.cancel ~key:t.id
  else Delay.schedule ~key:t.id ~ms:t.open_delay (t.on_open_change true)
;;

let close_later t =
  if t.open_
  then Delay.schedule ~key:t.id ~ms:t.close_delay (t.on_open_change false)
  else Delay.cancel ~key:t.id
;;

let trigger ?(attrs = []) t node =
  Slot.merge
    ~defaults:[ "data-slot", data "slot" "hover-card-trigger" ]
    ([ Attr.id (trigger_id t)
     ; state t
     ; Attr.on_mouseenter (fun _ -> open_later t)
     ; Attr.on_mouseleave (fun _ -> close_later t)
     ; Attr.on_focus (fun _ -> open_later t)
     ; Attr.on_blur (fun _ -> close_later t)
     ]
     @ attrs)
    node
;;

let content_class =
  "cn-hover-card-content z-50 origin-(--radix-hover-card-content-transform-origin) \
   outline-hidden"
;;

let content
  ?(attrs = [])
  ?class_
  ?(side = Popper.Side.Bottom)
  ?(side_offset = 4.)
  ?(align = Popper.Align.Center)
  ?align_offset
  ?avoid_collisions
  t
  children
  =
  if not t.open_
  then Node.none
  else (
    let content =
      Node.div
        ~attrs:
          ([ data "slot" "hover-card-content"
           ; Cn.with_class ?class_ [ content_class ]
           ; state t
           ; Attr.on_mouseenter (fun _ -> open_later t)
           ; Attr.on_mouseleave (fun _ -> close_later t)
           ]
           @ Popper.content_attrs ~side ~align ()
           @ attrs)
        children
    in
    Node.div
      ~attrs:
        [ Attr.style (Css_gen.create ~field:"display" ~value:"contents")
        ; Presence.attr
        ; Dismiss.attr
            ~inside:[ trigger_id t ]
            ~on_dismiss:(fun _ ->
              Effect.Many [ Delay.cancel ~key:t.id; t.on_open_change false ])
            ()
        ]
      [ Popper.wrapper
          ~name:"hover-card"
          ~side
          ~side_offset
          ~align
          ?align_offset
          ?avoid_collisions
          ~anchor:(Element (trigger_id t))
          content
      ])
;;
