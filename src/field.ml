open! Import

module Orientation = struct
  type t =
    | Vertical
    | Horizontal
  [@@deriving enumerate, sexp_of, compare, equal]
end

let view
      ?attrs:extra
      ?(orientation = Orientation.Vertical)
      ?description
      ?error
      ?(required = false)
      ~id
      ~label
      control
  =
  let description_id = id ^ "-description" in
  let error_id = id ^ "-error" in
  let described_by =
    List.filter_opt
      [ Option.map description ~f:(fun _ -> description_id)
      ; Option.map error ~f:(fun _ -> error_id)
      ]
  in
  let control =
    control
      ([ Attr.id id ]
       @ (if List.is_empty described_by
          then []
          else [ aria "describedby" (String.concat ~sep:" " described_by) ])
       @ (if Option.is_some error then [ aria "invalid" "true" ] else [])
       @ if required then [ aria "required" "true" ] else [])
  in
  let label = Label.text ~for_:id ~required label in
  let description =
    Option.map description ~f:(fun d ->
      Node.p
        ~attrs:[ Attr.class_ "loon-field-description"; Attr.id description_id ]
        [ Node.text d ])
  in
  let error =
    Option.map error ~f:(fun e ->
      Node.p
        ~attrs:
          [ Attr.class_ "loon-field-error"
          ; Attr.id error_id
          ; Attr.role "alert"
          ]
        [ Icon.view Circle_exclamation_point; Node.text e ])
  in
  let orientation_class =
    match orientation with
    | Vertical -> "loon-field-vertical"
    | Horizontal -> "loon-field-horizontal"
  in
  Node.div
    ~attrs:
      (attrs ?attrs:extra [ "loon-field"; orientation_class ]
       @ if Option.is_some error then [ data "invalid" "true" ] else [])
    (match orientation with
     | Vertical ->
       List.filter_opt [ Some label; Some control; description; error ]
     | Horizontal ->
       [ control
       ; Node.div
           ~attrs:[ Attr.class_ "loon-field-text" ]
           (List.filter_opt [ Some label; description; error ])
       ])
;;

let set ?attrs:extra ?description ~legend children =
  Node.fieldset
    ~attrs:(attrs ?attrs:extra [ "loon-fieldset" ])
    (Node.legend
       ~attrs:[ Attr.class_ "loon-fieldset-legend" ]
       [ Node.text legend ]
     :: (Option.value_map description ~default:[] ~f:(fun d ->
           [ Node.p
               ~attrs:[ Attr.class_ "loon-field-description" ]
               [ Node.text d ]
           ])
         @ children))
;;
