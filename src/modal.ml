open! Import

let title_id id = id ^ "-title"
let description_id id = id ^ "-description"
let close ~id ~on_close = Floating.and_refocus ~id on_close

let view
      ?(panel_attrs = [])
      ?(dismiss_on_scrim = true)
      ?(has_description = false)
      ~role
      ~class_
      ~id
      ~open_
      ~on_close
      content
  =
  if not open_
  then Node.none
  else (
    let on_keydown ev =
      match Dom_util.key ev with
      | Escape -> Effect.Many [ Dom_util.stop ev; close ~id ~on_close ]
      | _ -> Effect.Ignore
    in
    let panel_id = Floating.content_id id in
    Node.div
      ~attrs:
        [ Attr.classes [ "loon-modal"; class_ ^ "-root" ]
        ; Attr.on_keydown on_keydown
        ]
      [ Node.div
          ~attrs:
            ([ Attr.class_ "loon-scrim"; aria "hidden" "true" ]
             @
             if dismiss_on_scrim
             then [ Attr.on_click (fun _ -> close ~id ~on_close) ]
             else [])
          []
      ; Focus.guard ~id:panel_id `Start
      ; Node.div
          ~attrs:
            ([ Attr.class_ class_
             ; Attr.id panel_id
             ; Attr.role role
             ; aria "modal" "true"
             ; aria "labelledby" (title_id id)
             ; Attr.tabindex (-1)
             ; data "state" "open"
             ; Floating.focus_on_mount
             ]
             @ (if has_description
                then [ aria "describedby" (description_id id) ]
                else [])
             @ panel_attrs)
          content
      ; Focus.guard ~id:panel_id `End
      ])
;;

let with_trigger ?trigger ~id ~open_ ~on_change modal =
  match trigger with
  | None -> modal
  | Some trigger ->
    Node.div
      ~attrs:[ Attr.class_ "loon-modal-anchor" ]
      [ trigger
          (Floating.trigger_attrs
             ~id
             ~haspopup:"dialog"
             ~open_
             ~on_toggle:(on_change (not open_)))
      ; modal
      ]
;;
