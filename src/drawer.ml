open! Import
open Js_of_ocaml

module Direction = struct
  type t =
    | Top
    | Bottom
    | Left
    | Right
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Top -> "top"
    | Bottom -> "bottom"
    | Left -> "left"
    | Right -> "right"
  ;;

  (* vaul's own stylesheet slides the panel; these are tw-animate's
     equivalents. *)
  let animation = function
    | Top -> "data-[state=open]:slide-in-from-top data-[state=closed]:slide-out-to-top"
    | Bottom ->
      "data-[state=open]:slide-in-from-bottom data-[state=closed]:slide-out-to-bottom"
    | Left -> "data-[state=open]:slide-in-from-left data-[state=closed]:slide-out-to-left"
    | Right ->
      "data-[state=open]:slide-in-from-right data-[state=closed]:slide-out-to-right"
  ;;
end

type t =
  { modal : Modal.t
  ; direction : Direction.t
  }

let view ?id ?trigger_id ?(direction = Direction.Bottom) ~open_ ~on_open_change f =
  Modal.view ?id ?trigger_id ~open_ ~on_open_change (fun modal -> f { modal; direction })
;;

let component ?(default_open = false) ?direction f (local_ graph) =
  let open Bonsai.Let_syntax in
  let open_, set_open = Bonsai.state default_open graph in
  let id = Bonsai.path_id graph in
  let%arr open_ and set_open and id and f in
  view ~id ?direction ~open_ ~on_open_change:set_open f
;;

let trigger ?attrs t node = Modal.trigger ~slot:"drawer-trigger" ?attrs t.modal node
let close ?attrs t node = Modal.close ~slot:"drawer-close" ?attrs t.modal node

let overlay_class =
  "cn-drawer-overlay fixed inset-0 z-50 data-open:animate-in data-open:fade-in-0 \
   data-closed:animate-out data-closed:fade-out-0"
;;

let content_class =
  [ "cn-drawer-content group/drawer-content fixed z-50 \
     data-[vaul-drawer-direction=bottom]:inset-x-0 \
     data-[vaul-drawer-direction=bottom]:bottom-0 \
     data-[vaul-drawer-direction=bottom]:mt-24 \
     data-[vaul-drawer-direction=bottom]:max-h-[80vh] \
     data-[vaul-drawer-direction=left]:inset-y-0 data-[vaul-drawer-direction=left]:left-0 \
     data-[vaul-drawer-direction=left]:w-3/4 data-[vaul-drawer-direction=right]:inset-y-0 \
     data-[vaul-drawer-direction=right]:right-0 data-[vaul-drawer-direction=right]:w-3/4 \
     data-[vaul-drawer-direction=top]:inset-x-0 data-[vaul-drawer-direction=top]:top-0 \
     data-[vaul-drawer-direction=top]:mb-24 data-[vaul-drawer-direction=top]:max-h-[80vh] \
     data-[vaul-drawer-direction=left]:sm:max-w-sm \
     data-[vaul-drawer-direction=right]:sm:max-w-sm"
  ; "data-[vaul-drawer-direction=top]:inset-x-0 data-[vaul-drawer-direction=top]:top-0 \
     data-[vaul-drawer-direction=top]:mb-24 data-[vaul-drawer-direction=top]:max-h-[80vh] \
     data-[vaul-drawer-direction=top]:rounded-b-lg data-[vaul-drawer-direction=top]:border-b"
  ; "data-[vaul-drawer-direction=bottom]:inset-x-0 \
     data-[vaul-drawer-direction=bottom]:bottom-0 data-[vaul-drawer-direction=bottom]:mt-24 \
     data-[vaul-drawer-direction=bottom]:max-h-[80vh] \
     data-[vaul-drawer-direction=bottom]:rounded-t-lg \
     data-[vaul-drawer-direction=bottom]:border-t"
  ; "data-[vaul-drawer-direction=right]:inset-y-0 \
     data-[vaul-drawer-direction=right]:right-0 data-[vaul-drawer-direction=right]:w-3/4 \
     data-[vaul-drawer-direction=right]:border-l \
     data-[vaul-drawer-direction=right]:sm:max-w-sm"
  ; "data-[vaul-drawer-direction=left]:inset-y-0 data-[vaul-drawer-direction=left]:left-0 \
     data-[vaul-drawer-direction=left]:w-3/4 data-[vaul-drawer-direction=left]:border-r \
     data-[vaul-drawer-direction=left]:sm:max-w-sm"
  ]
;;

let handle_class =
  "cn-drawer-handle mx-auto hidden shrink-0 \
   group-data-[vaul-drawer-direction=bottom]/drawer-content:block"
;;

(* Dragging a bottom drawer down: the panel follows the pointer, and closes
   when let go a quarter of its height down (or flicked down), else springs
   back. *)
module Drag = Vdom.Attr.Hooks.Make (struct
    module Input = struct
      type t = unit Effect.t

      let sexp_of_t _ = Sexp.Atom "<close>"
      let combine _ second = second
    end

    module State = struct
      type t =
        { mutable close : Input.t
        ; mutable listeners : Dom.event_listener_id list
        }
    end

    let init close _ = { State.close; listeners = [] }

    let interactive (target : Dom_html.element Js.t) =
      Js.Opt.test
        ((Js.Unsafe.coerce target)##closest
           (Js.string "input, textarea, select, button, a, [contenteditable]")
         : Dom_html.element Js.t Js.opt)
    ;;

    let on_mount =
      `Schedule_immediately_after_this_dom_patch_completes
        (fun _ (state : State.t) (el : Dom_html.element Js.t) ->
          let start = ref None in
          let set_y y =
            el##.style##.transform := Js.string (sprintf "translate3d(0, %gpx, 0)" y)
          in
          let down =
            Dom_html.addEventListener
              el
              Dom_html.Event.pointerdown
              (Dom_html.handler (fun (ev : Dom_html.pointerEvent Js.t) ->
                 let target_ok =
                   Js.Opt.case ev##.target (fun () -> false) (fun t -> not (interactive t))
                 in
                 if target_ok && ev##.button = 0
                 then (
                   start := Some (Js.to_float ev##.clientY, Js.to_float (new%js Js.date_now)##getTime);
                   el##.style##.transition := Js.string "none");
                 Js._true))
              Js._false
          in
          let move =
            Dom_html.addEventListener
              Dom_html.window
              Dom_html.Event.pointermove
              (Dom_html.handler (fun (ev : Dom_html.pointerEvent Js.t) ->
                 (match !start with
                  | Some (y0, _) ->
                    let dy = Js.to_float ev##.clientY -. y0 in
                    set_y (if Float.(dy > 0.) then dy else dy /. 8.)
                  | None -> ());
                 Js._true))
              Js._false
          in
          let up =
            Dom_html.addEventListener
              Dom_html.window
              Dom_html.Event.pointerup
              (Dom_html.handler (fun (ev : Dom_html.pointerEvent Js.t) ->
                 (match !start with
                  | Some (y0, t0) ->
                    start := None;
                    let dy = Js.to_float ev##.clientY -. y0 in
                    let dt = Float.max 1. (Js.to_float (new%js Js.date_now)##getTime -. t0) in
                    let height = Float.of_int el##.offsetHeight in
                    el##.style##.transition
                    := Js.string "transform 0.5s cubic-bezier(0.32, 0.72, 0, 1)";
                    if Float.(dy > height *. 0.25 || (dy > 20. && dy /. dt > 0.4))
                    then (
                      set_y height;
                      Effect.Expert.handle_non_dom_event_exn state.close)
                    else set_y 0.
                  | None -> ());
                 Js._true))
              Js._false
          in
          state.listeners <- [ down; move; up ])
    ;;

    let update ~old_input:_ ~new_input (state : State.t) _ = state.close <- new_input

    let destroy _ (state : State.t) _ =
      List.iter state.listeners ~f:Dom_html.removeEventListener
    ;;
  end)

let content ?(attrs = []) ?class_ t children =
  let m = t.modal in
  Modal.content
    ~auto_focus:false
    ~overlay:(Modal.overlay ~slot:"drawer-overlay" ~class_:overlay_class m)
    ~content_attrs:
      ([ data "slot" "drawer-content"
       ; data "vaul-drawer-direction" (Direction.name t.direction)
       ; Cn.with_class
           ?class_
           (content_class
            @ [ "data-[state=open]:animate-in data-[state=closed]:animate-out \
                 duration-500 ease-[cubic-bezier(0.32,0.72,0,1)]"
              ; Direction.animation t.direction
              ])
       ]
       @ (match t.direction with
          | Bottom ->
            [ Vdom.Attr.create_hook "loon-drawer-drag" (Drag.create (m.on_open_change false))
            ; Attr.style (Css_gen.create ~field:"touch-action" ~value:"none")
            ]
          | Top | Left | Right -> [])
       @ attrs)
    m
    (Node.div ~attrs:[ Attr.class_ handle_class ] [] :: children)
;;

let header ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ data "slot" "drawer-header"
       ; Cn.with_class
           ?class_
           [ "cn-drawer-header flex flex-col \
              group-data-[vaul-drawer-direction=bottom]/drawer-content:text-center \
              group-data-[vaul-drawer-direction=top]/drawer-content:text-center"
           ]
       ]
       @ attrs)
    children
;;

let footer ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ data "slot" "drawer-footer"; Cn.with_class ?class_ [ "cn-drawer-footer mt-auto \
                                                               flex flex-col" ] ]
       @ attrs)
    children
;;

let title ?attrs ?class_ t children =
  Modal.title
    ~slot:"drawer-title"
    ~class_:(Cn.cn [ "cn-drawer-title cn-font-heading"; Option.value class_ ~default:"" ])
    ?attrs
    t.modal
    children
;;

let description ?attrs ?class_ t children =
  Modal.description
    ~slot:"drawer-description"
    ~class_:(Cn.cn [ "cn-drawer-description"; Option.value class_ ~default:"" ])
    ?attrs
    t.modal
    children
;;
