open! Import

module Size = struct
  type t =
    | Sm
    | Md
    | Lg
    | Xl
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let header ~id ?description title =
  Node.div
    ~attrs:[ Attr.class_ "loon-dialog-header" ]
    (Node.h2
       ~attrs:[ Attr.class_ "loon-dialog-title"; Attr.id (Modal.title_id id) ]
       [ Node.text title ]
     ::
     (match description with
      | None -> []
      | Some d ->
        [ Node.p
            ~attrs:[ Attr.class_ "loon-dialog-description"; Attr.id (Modal.description_id id) ]
            [ Node.text d ]
        ]))
;;

let footer buttons = Node.div ~attrs:[ Attr.class_ "loon-dialog-footer" ] buttons

let view
  ?attrs:extra
  ?(size = Size.Md)
  ?description
  ?footer:buttons
  ?(close_button = true)
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
      ~class_:"loon-dialog"
      ~id
      ~open_
      ~on_close
      ~has_description:(Option.is_some description)
      ~panel_attrs:(attrs ?attrs:extra [ "loon-dialog-" ^ Size.name size ])
      (List.concat
         [ [ header ~id ?description title ]
         ; (match body with
            | [] -> []
            | body -> [ Node.div ~attrs:[ Attr.class_ "loon-dialog-body" ] body ])
         ; Option.value_map buttons ~default:[] ~f:(fun b -> [ footer b ])
         ; (if close_button
            then
              [ Node.button
                  ~attrs:
                    [ Attr.type_ "button"
                    ; Attr.class_ "loon-dialog-close"
                    ; aria "label" "Close"
                    ; Attr.on_click (fun _ -> Modal.close ~id ~on_close)
                    ]
                  [ Icon.view X ]
              ]
            else [])
         ])
  in
  Modal.with_trigger ?trigger ~id ~open_ ~on_change modal
;;

let component ?attrs ?size ?description ?close_button ~trigger ~title content (local_ graph)
  =
  let open_, set_open = Bonsai.state false graph in
  let id = Bonsai.path_id graph in
  let open Bonsai.Let_syntax in
  let%arr open_ and set_open and id and content in
  let id = "loon" ^ id in
  let body, footer = content ~close:(Modal.close ~id ~on_close:(set_open false)) in
  view
    ?attrs
    ?size
    ?description
    ~footer
    ?close_button
    ~trigger
    ~id
    ~open_
    ~on_change:set_open
    ~title
    body
;;
