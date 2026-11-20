open! Import

module Side = struct
  type t =
    | Left
    | Right
    | Top
    | Bottom
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let view
  ?attrs:extra
  ?(side = Side.Right)
  ?(keep_side_on_phones = false)
  ?description
  ?footer
  ?trigger
  ~id
  ~open_
  ~on_change
  ~title
  body
  =
  let on_close = on_change false in
  let modal =
    Modal.view
      ~role:"dialog"
      ~class_:"loon-sheet"
      ~id
      ~open_
      ~on_close
      ~has_description:(Option.is_some description)
      ~panel_attrs:
        (attrs ?attrs:extra []
         @ [ data "side" (Side.name side) ]
         @ if keep_side_on_phones then [ data "keep-side" "" ] else [])
      (List.concat
         [ [ Node.div ~attrs:[ Attr.class_ "loon-sheet-handle"; aria "hidden" "true" ] []
           ; Dialog.header ~id ?description title
           ; Node.div ~attrs:[ Attr.class_ "loon-sheet-body" ] body
           ]
         ; Option.value_map footer ~default:[] ~f:(fun b -> [ Dialog.footer b ])
         ; [ Node.button
               ~attrs:
                 [ Attr.type_ "button"
                 ; Attr.class_ "loon-dialog-close"
                 ; aria "label" "Close"
                 ; Attr.on_click (fun _ -> Modal.close ~id ~on_close)
                 ]
               [ Icon.view X ]
           ]
         ])
  in
  Modal.with_trigger ?trigger ~id ~open_ ~on_change modal
;;

let component
  ?attrs
  ?side
  ?keep_side_on_phones
  ?description
  ~trigger
  ~title
  content
  (local_ graph)
  =
  let open_, set_open = Bonsai.state false graph in
  let id = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr open_ and set_open and id and content in
  let id = "loon" ^ id in
  let body, footer = content ~close:(Modal.close ~id ~on_close:(set_open false)) in
  view
    ?attrs
    ?side
    ?keep_side_on_phones
    ?description
    ~footer
    ~trigger
    ~id
    ~open_
    ~on_change:set_open
    ~title
    body
;;
