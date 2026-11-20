open! Import

let view ?attrs:extra ?icon ?description ?(actions = []) ?(bordered = false) title =
  Node.div
    ~attrs:
      (attrs
         ?attrs:extra
         ("loon-empty" :: (if bordered then [ "loon-empty-bordered" ] else [])))
    (List.filter_opt
       [ Option.map icon ~f:(fun icon ->
           Node.div ~attrs:[ Attr.class_ "loon-empty-icon" ] [ Icon.view icon ])
       ; Some (Node.h3 ~attrs:[ Attr.class_ "loon-empty-title" ] [ Node.text title ])
       ; Option.map description ~f:(fun d ->
           Node.p ~attrs:[ Attr.class_ "loon-empty-description" ] [ Node.text d ])
       ; (if List.is_empty actions
          then None
          else Some (Node.div ~attrs:[ Attr.class_ "loon-empty-actions" ] actions))
       ])
;;
