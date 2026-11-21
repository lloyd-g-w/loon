open! Import

let rec merge ?(defaults = []) attrs (node : Node.t) : Node.t =
  match node with
  | Element e ->
    Element
      (Node.Element.map_attrs e ~f:(fun a ->
         let defaults =
           List.filter_map defaults ~f:(fun (name, attr) ->
             if Attr.Expert.contains_name name a then None else Some attr)
         in
         Attr.many ((a :: defaults) @ attrs)))
  | Lazy { t; _ } -> merge ~defaults attrs (Lazy.force t)
  | Text _ | Fragment _ | None | Widget _ ->
    Node.span ~attrs:(List.map defaults ~f:snd @ attrs) [ node ]
;;
