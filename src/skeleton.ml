open! Import

module Shape = struct
  type t =
    | Rect
    | Circle
    | Text
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let view ?attrs:extra ?(shape = Shape.Rect) ?width ?height () =
  let style =
    List.filter_opt
      [ Option.map width ~f:(fun w -> Css_gen.create ~field:"width" ~value:w)
      ; Option.map height ~f:(fun h -> Css_gen.create ~field:"height" ~value:h)
      ]
  in
  Node.div
    ~attrs:
      (attrs ?attrs:extra [ "loon-skeleton"; "loon-skeleton-" ^ Shape.name shape ]
       @ [ aria "hidden" "true" ]
       @ if List.is_empty style then [] else [ Attr.style (Css_gen.concat style) ])
    []
;;

let text ?attrs:extra ?(lines = 3) () =
  Node.div
    ~attrs:(attrs ?attrs:extra [ "loon-skeleton-lines" ] @ [ aria "hidden" "true" ])
    (List.init lines ~f:(fun i ->
       view ~shape:Text ?width:(if i = lines - 1 && lines > 1 then Some "60%" else None) ()))
;;
