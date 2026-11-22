open! Core

let pick ~random = function
  | [] -> None
  | l -> List.nth l (random (List.length l))
;;

let keep ~locks (current : Create_preset.t) (next : Create_preset.t) =
  Set.fold locks ~init:next ~f:(fun p field ->
    Create_field.set p field (Create_field.get current field))
;;

let shuffle ~random ~locks (current : Create_preset.t) =
  let code = Create_preset.encode current in
  let codes =
    match List.filter Create_shuffle.presets ~f:(fun c -> not (String.equal c code)) with
    | [] -> Create_shuffle.presets
    | l -> l
  in
  match Option.bind (pick ~random codes) ~f:Create_preset.decode with
  | None -> current
  | Some decoded ->
    let decoded =
      { decoded with chart_color = Some (Option.value decoded.chart_color ~default:decoded.theme) }
    in
    Create_params.normalize (keep ~locks current decoded)
;;

(* CHART_COLOR_PAIRINGS *)
let chart_color_pairings =
  [ "red", [ "teal"; "sky" ]
  ; "orange", [ "teal"; "blue" ]
  ; "amber", [ "cyan"; "indigo" ]
  ; "yellow", [ "sky"; "violet" ]
  ; "lime", [ "indigo"; "pink" ]
  ; "green", [ "purple"; "rose" ]
  ; "emerald", [ "purple"; "red" ]
  ; "teal", [ "fuchsia"; "red" ]
  ; "cyan", [ "rose"; "amber" ]
  ; "sky", [ "red"; "yellow" ]
  ; "blue", [ "orange"; "yellow" ]
  ; "indigo", [ "amber"; "yellow" ]
  ; "violet", [ "yellow"; "lime" ]
  ; "purple", [ "green"; "lime" ]
  ; "fuchsia", [ "lime"; "teal" ]
  ; "pink", [ "green"; "cyan" ]
  ; "rose", [ "emerald"; "sky" ]
  ]
;;

let true_random ~random ~locks (current : Create_preset.t) =
  let locked f = Set.mem locks f in
  let choose field options =
    if locked field
    then Create_field.get current field
    else Option.value (pick ~random options) ~default:(Create_field.get current field)
  in
  let style = choose Style (List.map Create_config.styles ~f:(fun s -> s.name)) in
  let base_color =
    choose Base_color (List.map Create_config.base_colors ~f:(fun t -> t.name))
  in
  let themes =
    Create_config.themes_for_base_color base_color |> List.map ~f:(fun t -> t.name)
  in
  let theme = choose Theme themes in
  let chart_colors =
    match List.Assoc.find chart_color_pairings theme ~equal:String.equal with
    | Some pairing ->
      (match List.filter themes ~f:(List.mem pairing ~equal:String.equal) with
       | [] -> themes
       | l -> l)
    | None -> themes
  in
  let chart_color = choose Chart_color chart_colors in
  let fonts = List.filter Create_config.fonts ~f:(fun f -> f.available) in
  (* shadcn's biases: Lyra takes JetBrains Mono and no radius, Rhea no large
     radius. *)
  let fonts =
    if String.equal style "lyra"
    then List.filter fonts ~f:(fun f -> String.equal f.name "jetbrains-mono")
    else fonts
  in
  let font = choose Font (List.map fonts ~f:(fun f -> f.name)) in
  let font_heading =
    if locked Font_heading
    then current.font_heading
    else if random 10 < 7
    then "inherit"
    else (
      let kind =
        List.find fonts ~f:(fun f -> String.equal f.name font) |> Option.map ~f:(fun f -> f.kind)
      in
      let contrast =
        List.filter fonts ~f:(fun f ->
          (not ([%equal: Customize_fonts.Kind.t option] (Some f.kind) kind))
          && not (String.equal f.name font))
      in
      let from = if List.is_empty contrast then fonts else contrast in
      Option.value_map (pick ~random from) ~default:"inherit" ~f:(fun f -> f.name))
  in
  let radius =
    choose
      Radius
      (List.map Create_config.radii ~f:(fun r -> r.name)
       |> List.filter ~f:(fun r ->
         match style with
         | "lyra" -> String.equal r "none"
         | "rhea" -> not (String.equal r "large")
         | _ -> true))
  in
  let menu_colors =
    let all = List.map Create_config.menu_colors ~f:fst in
    if (not (locked Menu_color)) && locked Menu_accent && String.equal current.menu_accent "bold"
    then List.filter all ~f:(fun c -> not (Create_params.is_translucent_menu_color c))
    else all
  in
  let menu_color = choose Menu_color menu_colors in
  let menu_accent =
    if locked Menu_accent || Create_params.is_translucent_menu_color menu_color
    then
      if String.equal current.menu_accent "bold"
         && Create_params.is_translucent_menu_color menu_color
      then "subtle"
      else current.menu_accent
    else choose Menu_accent (List.map Create_config.menu_accents ~f:fst)
  in
  Create_params.normalize
    { style
    ; base_color
    ; theme
    ; chart_color = Some chart_color
    ; icon_library = Create_config.icon_library
    ; font
    ; font_heading
    ; radius
    ; menu_accent
    ; menu_color
    }
;;
