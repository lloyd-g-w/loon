open! Core

type t =
  { light : (string * string) list
  ; dark : (string * string) list
  }
[@@deriving sexp_of]

(* Object spread: keys keep their first position, values the last. *)
let merge base over =
  let set acc (k, v) =
    if List.Assoc.mem acc k ~equal:String.equal
    then
      List.map acc ~f:(fun (k', v') ->
        if String.equal k k' then k', v else k', v')
    else acc @ [ k, v ]
  in
  List.fold over ~init:base ~f:set
;;

let get vars k = List.Assoc.find vars k ~equal:String.equal

let theme_or_neutral name =
  match Create_config.theme name with
  | Some t -> t
  | None -> Option.value_exn (Create_config.theme "neutral")
;;

let of_preset (p : Create_preset.t) =
  let base =
    if Create_config.is_base_color p.base_color
    then theme_or_neutral p.base_color
    else theme_or_neutral "neutral"
  in
  let theme = theme_or_neutral p.theme in
  let light = merge base.light theme.light in
  let dark = merge base.dark theme.dark in
  let charts vars chart =
    List.filter_map (List.range 1 6) ~f:(fun i ->
      let k = sprintf "chart-%d" i in
      Option.map (get chart k) ~f:(fun v -> k, v))
    |> merge vars
  in
  let light, dark =
    match Option.bind p.chart_color ~f:Create_config.theme with
    | None -> light, dark
    | Some chart -> charts light chart.light, charts dark chart.dark
  in
  let bold vars =
    merge
      vars
      (List.filter_opt
         [ Option.map (get vars "primary") ~f:(fun v -> "accent", v)
         ; Option.map (get vars "primary-foreground") ~f:(fun v ->
             "accent-foreground", v)
         ])
  in
  let light, dark =
    if String.equal p.menu_accent "bold"
    then bold light, bold dark
    else light, dark
  in
  let radius =
    match
      List.find Create_config.radii ~f:(fun r -> String.equal r.name p.radius)
    with
    | Some r when not (String.is_empty r.value) -> r.value
    | _ -> Option.value (get light "radius") ~default:"0.625rem"
  in
  { light = merge light [ "radius", radius ]; dark }
;;

let rule selector vars =
  sprintf
    "%s {\n%s\n}"
    selector
    (List.map vars ~f:(fun (k, v) -> sprintf "  --%s: %s;" k v)
     |> String.concat ~sep:"\n")
;;

let theme_css p =
  let t = of_preset p in
  rule ":root" t.light ^ "\n\n" ^ rule ".dark" t.dark
;;

let font_css (p : Create_preset.t) =
  let family name =
    Option.value_map
      (Create_config.font name)
      ~default:"sans-serif"
      ~f:(fun f -> f.family)
  in
  let body = family p.font in
  let heading =
    if String.equal p.font_heading "inherit"
    then body
    else family p.font_heading
  in
  sprintf
    "@theme inline {\n  --font-sans: %s;\n  --font-heading: %s;\n}"
    body
    heading
;;

let css p = theme_css p ^ "\n\n" ^ font_css p
