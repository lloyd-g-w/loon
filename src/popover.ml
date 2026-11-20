open! Import

let view ?attrs ?side ?align ~id ~open_ ~on_change ~trigger content =
  Floating.view
    ?attrs
    ?side
    ?align
    ~id
    ~open_
    ~on_dismiss:(on_change false)
    ~content_attrs:
      [ Attr.classes [ "loon-popover" ]
      ; Attr.role "dialog"
      ; Attr.tabindex (-1)
      ; aria "labelledby" (Floating.trigger_id id)
      ; Floating.focus_on_mount
      ]
    ~trigger:
      (trigger
         (Floating.trigger_attrs ~id ~haspopup:"dialog" ~open_ ~on_toggle:(on_change (not open_))))
    content
;;

let component ?attrs ?side ?align ~trigger content (local_ graph) =
  let open_, set_open = Bonsai.state false graph in
  let id = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr open_ and set_open and id and content in
  let id = "loon" ^ id in
  view
    ?attrs
    ?side
    ?align
    ~id
    ~open_
    ~on_change:set_open
    ~trigger
    (content ~close:(Floating.and_refocus ~id (set_open false)))
;;

let header ?description title =
  Node.div
    ~attrs:[ Attr.class_ "loon-popover-header" ]
    (Node.h4 ~attrs:[ Attr.class_ "loon-popover-title" ] [ Node.text title ]
     ::
     (match description with
      | None -> []
      | Some d -> [ Node.p ~attrs:[ Attr.class_ "loon-popover-description" ] [ Node.text d ] ]))
;;

let footer buttons = Node.div ~attrs:[ Attr.class_ "loon-popover-footer" ] buttons
