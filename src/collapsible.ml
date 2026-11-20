open! Import

let state open_ = if open_ then "open" else "closed"

let view ?attrs:extra ?(disabled = false) ~name ~open_ ~on_change ~trigger content =
  let content_id = name ^ "-content" in
  Node.div
    ~attrs:(attrs ?attrs:extra [ "loon-collapsible" ] @ [ data "state" (state open_) ])
    [ Node.button
        ~attrs:
          ([ Attr.class_ "loon-collapsible-trigger"
           ; Attr.type_ "button"
           ; Attr.id (name ^ "-trigger")
           ; aria_bool "expanded" open_
           ; aria "controls" content_id
           ; data "state" (state open_)
           ; Attr.on_click (fun _ -> on_change (not open_))
           ]
           @ if disabled then [ Attr.disabled ] else [])
        (trigger @ [ Icon.view ~attrs:[ Attr.class_ "loon-collapsible-chevron" ] Chevron_down ])
    ; Node.div
        ~attrs:
          ([ Attr.class_ "loon-collapsible-content"
           ; Attr.id content_id
           ; data "state" (state open_)
           ]
           @ if open_ then [] else [ Attr.create "inert" "" ])
        [ Node.div ~attrs:[ Attr.class_ "loon-collapsible-inner" ] content ]
    ]
;;

let component ?attrs ?disabled ?(default_open = false) ~trigger content (local_ graph) =
  let open_, set_open = Bonsai.state default_open graph in
  let name = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr open_ and set_open and name and trigger and content in
  view ?attrs ?disabled ~name:("loon" ^ name) ~open_ ~on_change:set_open ~trigger content
;;
