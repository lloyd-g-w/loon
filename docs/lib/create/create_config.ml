open! Core

module Option_ = struct
  type t =
    { name : string
    ; title : string
    ; disabled : string option
    }
end

let style = "vega"
let styles = Create_styles.all

let style_disabled name =
  if String.equal name style
  then None
  else Some "Needs different component markup: loon ports new-york-v4 (Vega)."
;;

let base = "radix"

let bases : Option_.t list =
  [ { name = "base"
    ; title = "Base UI"
    ; disabled = Some "loon's components follow Radix."
    }
  ; { name = "aria"
    ; title = "React Aria"
    ; disabled = Some "loon's components follow Radix."
    }
  ; { name = "radix"; title = "Radix UI"; disabled = None }
  ]
;;

let icon_library = "lucide"

let icon_libraries : Option_.t list =
  let other = Some "loon's components draw Lucide icons." in
  [ { name = "lucide"; title = "Lucide"; disabled = None }
  ; { name = "tabler"; title = "Tabler Icons"; disabled = other }
  ; { name = "hugeicons"; title = "HugeIcons"; disabled = other }
  ; { name = "phosphor"; title = "Phosphor Icons"; disabled = other }
  ; { name = "remixicon"; title = "Remix Icon"; disabled = other }
  ]
;;

let base_color_names =
  [ "neutral"; "stone"; "zinc"; "mauve"; "olive"; "mist"; "taupe" ]
;;

let is_base_color name = List.mem base_color_names name ~equal:String.equal

let base_colors =
  List.filter Create_themes.all ~f:(fun (t : Create_theme.t) ->
    is_base_color t.name)
;;

let theme name =
  List.find Create_themes.all ~f:(fun (t : Create_theme.t) ->
    String.equal t.name name)
;;

let themes_for_base_color base_color =
  List.filter Create_themes.all ~f:(fun (t : Create_theme.t) ->
    String.equal t.name base_color || not (is_base_color t.name))
;;

module Radius = struct
  type t =
    { name : string
    ; label : string
    ; value : string
    }
end

let radii : Radius.t list =
  [ { name = "default"; label = "Default"; value = "" }
  ; { name = "none"; label = "None"; value = "0" }
  ; { name = "small"; label = "Small"; value = "0.45rem" }
  ; { name = "medium"; label = "Medium"; value = "0.625rem" }
  ; { name = "large"; label = "Large"; value = "0.875rem" }
  ]
;;

let menu_accents = [ "subtle", "Subtle"; "bold", "Bold" ]

let menu_colors =
  [ "default", "Default"
  ; "inverted", "Inverted"
  ; "default-translucent", "Default Translucent"
  ; "inverted-translucent", "Inverted Translucent"
  ]
;;

let fonts =
  List.map
    [ "geist"
    ; "inter"
    ; "noto-sans"
    ; "nunito-sans"
    ; "figtree"
    ; "roboto"
    ; "raleway"
    ; "dm-sans"
    ; "public-sans"
    ; "outfit"
    ; "oxanium"
    ; "manrope"
    ; "space-grotesk"
    ; "montserrat"
    ; "ibm-plex-sans"
    ; "source-sans-3"
    ; "instrument-sans"
    ; "geist-mono"
    ; "jetbrains-mono"
    ; "noto-serif"
    ; "roboto-slab"
    ; "merriweather"
    ; "lora"
    ; "playfair-display"
    ; "eb-garamond"
    ; "instrument-serif"
    ]
    ~f:(fun name -> Option.value_exn (Customize_fonts.find name))
;;

let font name =
  List.find fonts ~f:(fun (f : Customize_fonts.Font.t) ->
    String.equal f.name name)
;;

let font_family (f : Customize_fonts.Font.t) =
  sprintf "var(%s), %s" f.preview_variable f.family
;;

let reset_preset : Create_preset.t =
  { style = "vega"
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
