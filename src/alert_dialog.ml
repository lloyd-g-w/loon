open! Import

let view
  ?attrs:extra
  ?(confirm_label = "Continue")
  ?(cancel_label = "Cancel")
  ?(danger = false)
  ?trigger
  ~id
  ~open_
  ~on_change
  ~title
  ~description
  ~on_confirm
  ()
  =
  let close = Modal.close ~id ~on_close:(on_change false) in
  let modal =
    Modal.view
      ~role:"alertdialog"
      ~class_:"loon-alert-dialog"
      ~dismiss_on_scrim:false
      ~has_description:true
      ~id
      ~open_
      ~on_close:(on_change false)
      ~panel_attrs:(attrs ?attrs:extra [])
      [ Dialog.header ~id ~description title
      ; Dialog.footer
          [ Button.view
              ~attrs:[ Floating.focus_on_mount ]
              ~variant:Outline
              ~on_click:close
              [ Node.text cancel_label ]
          ; Button.view
              ~variant:(if danger then Destructive else Default)
              ~on_click:(Effect.Many [ close; on_confirm ])
              [ Node.text confirm_label ]
          ]
      ]
  in
  Modal.with_trigger ?trigger ~id ~open_ ~on_change modal
;;

let component
  ?attrs
  ?confirm_label
  ?cancel_label
  ?danger
  ~trigger
  ~title
  ~description
  on_confirm
  (local_ graph)
  =
  let open_, set_open = Bonsai.state false graph in
  let id = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr open_ and set_open and id and on_confirm in
  view
    ?attrs
    ?confirm_label
    ?cancel_label
    ?danger
    ~trigger
    ~id:("loon" ^ id)
    ~open_
    ~on_change:set_open
    ~title
    ~description
    ~on_confirm
    ()
;;
