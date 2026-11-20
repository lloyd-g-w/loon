open! Import

module Side = struct
  type t =
    | Top
    | Right
    | Bottom
    | Left
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

module Align = struct
  type t =
    | Start
    | Center
    | End
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let trigger_id id = id ^ "-trigger"
let content_id id = id ^ "-content"

let trigger_attrs ~id ~haspopup ~open_ ~on_toggle =
  [ Attr.id (trigger_id id)
  ; aria "haspopup" haspopup
  ; aria_bool "expanded" open_
  ; aria "controls" (content_id id)
  ; data "state" (if open_ then "open" else "closed")
  ; Attr.on_click (fun _ -> on_toggle)
  ]
;;

let and_refocus ~id eff =
  Effect.Many [ eff; Dom_util.focus_selector ("#" ^ trigger_id id) ]
;;

let focus_on_mount =
  Attr.Always_focus_hook.attr `Read_the_docs__this_hook_is_unpredictable
;;

let view
      ?attrs:extra
      ?(side = Side.Bottom)
      ?(align = Align.Start)
      ?(match_width = false)
      ?(content_attrs = [])
      ~id
      ~open_
      ~on_dismiss
      ~trigger
      content
  =
  let on_keydown ev =
    match Dom_util.key ev with
    | Escape -> Effect.Many [ Dom_util.stop ev; and_refocus ~id on_dismiss ]
    | _ -> Effect.Ignore
  in
  Node.div
    ~attrs:
      (attrs ?attrs:extra [ "loon-floating" ]
       @ [ data "state" (if open_ then "open" else "closed") ])
    (trigger
     ::
     (if not open_
      then []
      else
        [ Node.div
            ~attrs:
              [ Attr.class_ "loon-click-away"
              ; aria "hidden" "true"
              ; Attr.on_click (fun _ -> on_dismiss)
              ]
            []
        ; Node.div
            ~attrs:
              ([ Attr.class_ "loon-floating-content"
               ; Attr.id (content_id id)
               ; data "side" (Side.name side)
               ; data "align" (Align.name align)
               ; Keep_in_view.attr
               ; Attr.on_keydown on_keydown
               ]
               @ (if match_width then [ data "match-width" "" ] else [])
               @ content_attrs)
            content
        ]))
;;
