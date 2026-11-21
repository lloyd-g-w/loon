open! Import

let rec merge ?(defaults = []) attrs (node : Node.t) : Node.t =
  match node with
  | Element e ->
    Element
      (Node.Element.map_attrs e ~f:(fun a ->
         let defaults =
           List.filter_map defaults ~f:(fun (name, attr) ->
             if String.equal name "data-slot"
             then Some (Attr.suppress_merge_warnings attr)
             else if Attr.Expert.contains_name name a
             then None
             else Some attr)
         in
         Attr.many ((a :: attrs) @ defaults)))
  | Lazy { t; _ } -> merge ~defaults attrs (Lazy.force t)
  | Text _ | Fragment _ | None | Widget _ ->
    Node.span ~attrs:(List.map defaults ~f:snd @ attrs) [ node ]
;;
