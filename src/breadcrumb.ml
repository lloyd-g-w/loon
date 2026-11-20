open! Import

module Item = struct
  type t =
    { label : string
    ; href : string option
    ; on_click : unit Effect.t option
    }

  let create ?href ?on_click label = { label; href; on_click }
end

let view ?attrs:extra ?max_items ?separator items =
  let n = List.length items in
  let shown =
    match max_items with
    | Some max when n > max && max >= 3 ->
      (`Item (List.hd_exn items) :: [ `Ellipsis (List.length items - (max - 1)) ])
      @ List.map (List.drop items (n - (max - 2))) ~f:(fun i -> `Item i)
    | _ -> List.map items ~f:(fun i -> `Item i)
  in
  let last = List.length shown - 1 in
  let separator () =
    Node.li
      ~attrs:[ Attr.class_ "loon-breadcrumb-separator"; Attr.role "presentation"; aria "hidden" "true" ]
      [ Option.value separator ~default:(Icon.view Chevron_right) ]
  in
  let entry i = function
    | `Ellipsis hidden ->
      Node.li
        ~attrs:[ Attr.class_ "loon-breadcrumb-item" ]
        [ Node.span
            ~attrs:
              [ Attr.class_ "loon-breadcrumb-ellipsis"
              ; aria "label" (sprintf "%d more" hidden)
              ; Attr.role "img"
              ]
            [ Icon.view More_horizontal ]
        ]
    | `Item (item : Item.t) ->
      let current = i = last in
      let content =
        match current, item.href, item.on_click with
        | true, _, _ | false, None, None ->
          Node.span
            ~attrs:
              (Attr.class_ "loon-breadcrumb-page"
               :: (if current then [ aria "current" "page" ] else []))
            [ Node.text item.label ]
        | false, href, on_click ->
          Node.a
            ~attrs:
              (Attr.class_ "loon-breadcrumb-link"
               :: Attr.href (Option.value href ~default:"#")
               :: Option.value_map on_click ~default:[] ~f:(fun effect ->
                 [ Attr.on_click (fun ev ->
                     Effect.Many [ Dom_util.prevent_default ev; effect ])
                 ]))
            [ Node.text item.label ]
      in
      Node.li ~attrs:[ Attr.class_ "loon-breadcrumb-item" ] [ content ]
  in
  Node.nav
    ~attrs:(attrs ?attrs:extra [ "loon-breadcrumb" ] @ [ aria "label" "Breadcrumb" ])
    [ Node.ol
        ~attrs:[ Attr.class_ "loon-breadcrumb-list" ]
        (List.concat_mapi shown ~f:(fun i e ->
           if i = 0 then [ entry i e ] else [ separator (); entry i e ]))
    ]
;;
