open! Import

let container ?attrs:extra children =
  Node.div ~attrs:(attrs ?attrs:extra [ "loon-card" ]) children
;;

let header ?attrs:extra children =
  Node.div ~attrs:(attrs ?attrs:extra [ "loon-card-header" ]) children
;;

let title ?attrs:extra text =
  Node.h3 ~attrs:(attrs ?attrs:extra [ "loon-card-title" ]) [ Node.text text ]
;;

let description ?attrs:extra text =
  Node.p ~attrs:(attrs ?attrs:extra [ "loon-card-description" ]) [ Node.text text ]
;;

let content ?attrs:extra children =
  Node.div ~attrs:(attrs ?attrs:extra [ "loon-card-content" ]) children
;;

let footer ?attrs:extra children =
  Node.div ~attrs:(attrs ?attrs:extra [ "loon-card-footer" ]) children
;;

let view ?attrs ?title:title_text ?description:description_text ?action ?footer:foot children
  =
  let heading =
    List.filter_opt
      [ Option.map title_text ~f:(fun t -> title t)
      ; Option.map description_text ~f:(fun d -> description d)
      ]
  in
  let header =
    match heading, action with
    | [], None -> []
    | heading, None -> [ header heading ]
    | heading, Some action ->
      [ header
          [ Node.div ~attrs:[ Attr.class_ "loon-card-heading" ] heading
          ; Node.div ~attrs:[ Attr.class_ "loon-card-action" ] [ action ]
          ]
      ]
  in
  container
    ?attrs
    (header
     @ (if List.is_empty children then [] else [ content children ])
     @
     match foot with
     | None -> []
     | Some foot -> [ footer foot ])
;;
