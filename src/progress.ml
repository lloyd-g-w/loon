open! Import

module Tone = struct
  type t =
    | Primary
    | Accent
    | Success
    | Warning
    | Danger
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

module Size = struct
  type t =
    | Sm
    | Md
    | Lg
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let view
  ?attrs:extra
  ?(tone = Tone.Primary)
  ?(size = Size.Md)
  ?max:(maximum = 100.)
  ?label
  ?value
  ()
  =
  let fraction =
    Option.map value ~f:(fun v ->
      if Float.(maximum <= 0.) then 0. else Float.clamp_exn (v /. maximum) ~min:0. ~max:1.)
  in
  let state =
    match fraction with
    | None -> "indeterminate"
    | Some f when Float.(f >= 1.) -> "complete"
    | Some _ -> "loading"
  in
  Node.div
    ~attrs:
      (attrs
         ?attrs:extra
         [ "loon-progress"; "loon-progress-" ^ Tone.name tone; "loon-progress-" ^ Size.name size ]
       @ [ Attr.role "progressbar"
         ; aria "valuemin" "0"
         ; aria "valuemax" (Float.to_string_hum ~strip_zero:true maximum)
         ; data "state" state
         ]
       @ (match value with
          | None -> []
          | Some v ->
            [ aria "valuenow" (Float.to_string_hum ~strip_zero:true (Float.clamp_exn v ~min:0. ~max:maximum)) ])
       @ Option.value_map label ~default:[] ~f:(fun l -> [ aria "label" l ]))
    [ Node.div
        ~attrs:
          (Attr.class_ "loon-progress-indicator"
           ::
           (match fraction with
            | None -> []
            | Some f ->
              [ Attr.style
                  (Css_gen.create
                     ~field:"transform"
                     ~value:(sprintf "translateX(-%.2f%%)" (100. *. (1. -. f))))
              ]))
        []
    ]
;;
