open! Import

module Size = struct
  type t =
    | Sm
    | Md
    | Lg
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let view ?attrs:extra ?(size = Size.Md) ?(label = "Loading") () =
  Node.span
    ~attrs:
      (attrs ?attrs:extra [ "loon-spinner"; "loon-spinner-" ^ Size.name size ]
       @ [ Attr.role "status"; aria "label" label ])
    [ Node.create_svg
        "svg"
        ~attrs:[ Attr.create "viewBox" "0 0 24 24"; aria "hidden" "true" ]
        [ Node.create_svg
            "circle"
            ~attrs:
              [ Attr.class_ "loon-spinner-track"
              ; Attr.create "cx" "12"
              ; Attr.create "cy" "12"
              ; Attr.create "r" "9.5"
              ]
            []
        ; Node.create_svg
            "path"
            ~attrs:[ Attr.class_ "loon-spinner-arc"; Attr.create "d" "M21.5 12a9.5 9.5 0 0 0-9.5-9.5" ]
            []
        ]
    ]
;;
