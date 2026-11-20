open! Import

module Variant = struct
  type t =
    | Neutral
    | Info
    | Success
    | Warning
    | Danger
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))

  let icon : t -> Icon.t = function
    | Neutral | Info -> Info
    | Success -> Check_circle
    | Warning -> Alert_triangle
    | Danger -> Alert_circle
  ;;
end

let view ?attrs:extra ?(variant = Variant.Neutral) ?icon ?title ?action description =
  let icon =
    match icon with
    | None -> Some (Variant.icon variant)
    | Some icon -> icon
  in
  let role =
    match variant with
    | Warning | Danger -> "alert"
    | Neutral | Info | Success -> "status"
  in
  Node.div
    ~attrs:
      (attrs ?attrs:extra [ "loon-alert"; "loon-alert-" ^ Variant.name variant ]
       @ [ Attr.role role ])
    (List.filter_opt
       [ Option.map icon ~f:(fun icon ->
           Icon.view ~attrs:[ Attr.class_ "loon-alert-icon" ] icon)
       ; Some
           (Node.div
              ~attrs:[ Attr.class_ "loon-alert-body" ]
              (List.filter_opt
                 [ Option.map title ~f:(fun title ->
                     Node.div ~attrs:[ Attr.class_ "loon-alert-title" ] [ Node.text title ])
                 ; (if List.is_empty description
                    then None
                    else
                      Some
                        (Node.div
                           ~attrs:[ Attr.class_ "loon-alert-description" ]
                           description))
                 ]))
       ; Option.map action ~f:(fun action ->
           Node.div ~attrs:[ Attr.class_ "loon-alert-action" ] [ action ])
       ])
;;
