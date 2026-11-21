open! Core

module Key = struct
  type t =
    | Body
    | Heading
    | Mono
    | Scale
    | Measure
    | Flow
    | Leading
    | Item
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Body -> "body"
    | Heading -> "heading"
    | Mono -> "mono"
    | Scale -> "scale"
    | Measure -> "measure"
    | Flow -> "flow"
    | Leading -> "leading"
    | Item -> "item"
  ;;
end

module Option_ = struct
  type t =
    { value : string
    ; label : string
    }
end

let o value label : Option_.t = { value; label }
let sizes = [ o "14" "14px"; o "15" "15px"; o "16" "16px"; o "18" "18px" ]

let leadings =
  [ o "1.6" "Tight (1.6)"; o "1.75" "Regular (1.75)"; o "1.9" "Loose (1.9)" ]
;;

let flows =
  [ o "1em" "Compact (1em)"
  ; o "1.25em" "Regular (1.25em)"
  ; o "2em" "Airy (2em)"
  ]
;;

let measures =
  [ o "60" "60ch", "28em"
  ; o "70" "70ch", "33em"
  ; o "80" "80ch", "37em"
  ; o "90" "90ch", "42em"
  ]
;;

let content_options =
  [ o "docs" "Docs"
  ; o "chat" "Chat"
  ; o "article" "Article"
  ; o "changelog" "Changelog"
  ; o "notes" "Notes"
  ]
;;

let measure_width m =
  List.find_map measures ~f:(fun ((o : Option_.t), w) ->
    if String.equal o.value m then Some w else None)
;;

type t =
  { body : string
  ; heading : string
  ; mono : string
  ; scale : string
  ; measure : string
  ; flow : string
  ; leading : string
  ; item : string
  }
[@@deriving sexp_of, equal]

let default =
  { body = "geist"
  ; heading = "inherit"
  ; mono = "geist-mono"
  ; scale = "15"
  ; measure = "80"
  ; flow = "1.25em"
  ; leading = "1.75"
  ; item = "docs"
  }
;;

let get t (key : Key.t) =
  match key with
  | Body -> t.body
  | Heading -> t.heading
  | Mono -> t.mono
  | Scale -> t.scale
  | Measure -> t.measure
  | Flow -> t.flow
  | Leading -> t.leading
  | Item -> t.item
;;

let set t (key : Key.t) v =
  match key with
  | Body -> { t with body = v }
  | Heading -> { t with heading = v }
  | Mono -> { t with mono = v }
  | Scale -> { t with scale = v }
  | Measure -> { t with measure = v }
  | Flow -> { t with flow = v }
  | Leading -> { t with leading = v }
  | Item -> { t with item = v }
;;

let font_ids =
  List.map Typeset_fonts.all ~f:(fun (f : Typeset_fonts.t) -> f.name)
;;

let option_values = List.map ~f:(fun (o : Option_.t) -> o.value)

let values (key : Key.t) =
  match key with
  | Body | Mono -> font_ids
  | Heading -> "inherit" :: font_ids
  | Scale -> option_values sizes
  | Measure -> option_values (List.map measures ~f:fst)
  | Flow -> option_values flows
  | Leading -> option_values leadings
  | Item -> option_values content_options
;;

let coerce key v =
  if List.mem (values key) v ~equal:String.equal then Some v else None
;;

let of_query q =
  let kvs = Customize_query.parse q in
  List.fold Key.all ~init:default ~f:(fun t key ->
    match
      Option.bind (Customize_query.find kvs (Key.name key)) ~f:(coerce key)
    with
    | Some v -> set t key v
    | None -> t)
;;

let to_query t =
  List.filter_map Key.all ~f:(fun key ->
    let v = get t key in
    if String.equal v (get default key) then None else Some (Key.name key, v))
  |> Customize_query.to_string
;;

let apply t overrides =
  List.fold overrides ~init:t ~f:(fun t (k, v) -> set t k v)
;;
