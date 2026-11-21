open! Core

type t =
  { preset : Create_preset.t
  ; item : string
  ; extra : (string * string) list
  }
[@@deriving sexp_of, equal]

let default_item = "preview-02"

let is_translucent_menu_color = function
  | "default-translucent" | "inverted-translucent" -> true
  | _ -> false
;;

let normalize (p : Create_preset.t) =
  let p =
    { p with
      style = Create_config.style
    ; icon_library = Create_config.icon_library
    ; font_heading =
        (if String.equal p.font_heading p.font
         then "inherit"
         else p.font_heading)
    }
  in
  let available =
    Create_config.themes_for_base_color p.base_color
    |> List.map ~f:(fun (t : Create_theme.t) -> t.name)
  in
  let valid name = List.mem available name ~equal:String.equal in
  let fallback = Option.value (List.hd available) ~default:p.base_color in
  let p =
    { p with
      theme = (if valid p.theme then p.theme else fallback)
    ; chart_color =
        Some
          (match p.chart_color with
           | Some c when valid c -> c
           | _ -> fallback)
    }
  in
  if String.equal p.menu_accent "bold" && is_translucent_menu_color p.menu_color
  then { p with menu_accent = "subtle" }
  else p
;;

let design_system_keys =
  [ "style"
  ; "baseColor"
  ; "theme"
  ; "chartColor"
  ; "iconLibrary"
  ; "font"
  ; "fontHeading"
  ; "radius"
  ; "menuAccent"
  ; "menuColor"
  ]
;;

(* DEFAULT_CONFIG, for the keys read without a preset. *)
let default_config : Create_preset.t =
  { style = "nova"
  ; base_color = "neutral"
  ; theme = "neutral"
  ; chart_color = Some "neutral"
  ; icon_library = "lucide"
  ; font = "inter"
  ; font_heading = "inherit"
  ; radius = "default"
  ; menu_accent = "subtle"
  ; menu_color = "default"
  }
;;

let of_query query =
  let kvs = Customize_query.parse query in
  let find k = List.Assoc.find kvs k ~equal:String.equal in
  (* nuqs' parseAsStringLiteral: an unknown value is the default. *)
  let literal k values default =
    match find k with
    | Some v when List.mem values v ~equal:String.equal -> v
    | _ -> default
  in
  let font_names = List.map Create_config.fonts ~f:(fun f -> f.name) in
  let theme_names = List.map Create_themes.all ~f:(fun t -> t.name) in
  let preset_code = Option.value (find "preset") ~default:"b0" in
  let preset =
    match
      Option.bind
        (Option.some_if (Create_preset.is_preset_code preset_code) preset_code)
        ~f:Create_preset.decode
    with
    | Some decoded ->
      let font_heading =
        if List.Assoc.mem kvs "fontHeading" ~equal:String.equal
        then
          literal
            "fontHeading"
            ("inherit" :: font_names)
            default_config.font_heading
        else decoded.font_heading
      in
      let from_decoded =
        match decoded.chart_color with
        | Some c -> c
        | None ->
          List.Assoc.find
            Create_preset.v1_chart_color_map
            decoded.theme
            ~equal:String.equal
          |> Option.value ~default:decoded.theme
      in
      let chart_color =
        if List.Assoc.mem kvs "chartColor" ~equal:String.equal
        then literal "chartColor" theme_names "neutral"
        else from_decoded
      in
      { decoded with font_heading; chart_color = Some chart_color }
    | None ->
      let d = default_config in
      { style =
          literal
            "style"
            (List.map Create_config.styles ~f:(fun s -> s.name))
            d.style
      ; base_color =
          literal
            "baseColor"
            (List.map Create_config.base_colors ~f:(fun t -> t.name))
            d.base_color
      ; theme = literal "theme" theme_names d.theme
      ; chart_color = Some (literal "chartColor" theme_names "neutral")
      ; icon_library =
          literal
            "iconLibrary"
            (List.map Create_config.icon_libraries ~f:(fun i -> i.name))
            d.icon_library
      ; font = literal "font" font_names d.font
      ; font_heading =
          literal "fontHeading" ("inherit" :: font_names) d.font_heading
      ; radius =
          literal
            "radius"
            (List.map Create_config.radii ~f:(fun r -> r.name))
            d.radius
      ; menu_accent =
          literal
            "menuAccent"
            (List.map Create_config.menu_accents ~f:fst)
            d.menu_accent
      ; menu_color =
          literal
            "menuColor"
            (List.map Create_config.menu_colors ~f:fst)
            d.menu_color
      }
  in
  let item = Option.value (find "item") ~default:default_item in
  let extra =
    List.filter kvs ~f:(fun (k, _) ->
      not
        (List.mem
           ("preset" :: "item" :: design_system_keys)
           k
           ~equal:String.equal))
  in
  { preset = normalize preset; item; extra }
;;

let code t = Create_preset.encode t.preset

let to_query t =
  Customize_query.to_string ([ "preset", code t; "item", t.item ] @ t.extra)
;;
