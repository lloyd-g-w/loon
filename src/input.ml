open! Import

module Type = struct
  type t =
    | Text
    | Email
    | Password
    | Search
    | Number
    | Url
    | Tel
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let view
  ?attrs:extra
  ?(type_ = Type.Text)
  ?placeholder
  ?(disabled = false)
  ?(invalid = false)
  ?leading
  ?trailing
  ?on_enter
  ~value
  ~on_input
  ()
  =
  let input =
    Node.input
      ~attrs:
        (attrs ?attrs:extra [ "loon-input" ]
         @ [ Attr.type_ (Type.name type_)
           ; Attr.value value
           ; Attr.on_input (fun _ s -> on_input s)
           ]
         @ Option.value_map placeholder ~default:[] ~f:(fun p -> [ Attr.placeholder p ])
         @ (if disabled then [ Attr.disabled ] else [])
         @ (if invalid then [ aria "invalid" "true" ] else [])
         @
         match on_enter with
         | None -> []
         | Some effect ->
           [ Attr.on_keydown (fun ev ->
               match Dom_util.key ev with
               | Enter -> effect
               | _ -> Effect.Ignore)
           ])
      ()
  in
  match leading, trailing with
  | None, None -> input
  | _ ->
    Node.div
      ~attrs:
        [ Attr.classes
            ([ "loon-input-group" ]
             @ (if Option.is_some leading then [ "loon-input-group-leading" ] else [])
             @ if Option.is_some trailing then [ "loon-input-group-trailing" ] else [])
        ; data "disabled" (Bool.to_string disabled)
        ]
      (List.filter_opt
         [ Option.map leading ~f:(fun icon ->
             Icon.view ~attrs:[ Attr.class_ "loon-input-icon" ] icon)
         ; Some input
         ; Option.map trailing ~f:(fun addon ->
             Node.div ~attrs:[ Attr.class_ "loon-input-addon" ] [ addon ])
         ])
;;

let component ?attrs ?type_ ?placeholder ?disabled ?leading ?trailing ?(default = "")
  (local_ graph)
  =
  Control.make
    ~equal:String.equal
    default
    ~view:(fun value set ->
      view
        ?attrs
        ?type_
        ?placeholder
        ?disabled
        ?leading
        ?trailing
        ~value
        ~on_input:set
        ())
    graph
;;
