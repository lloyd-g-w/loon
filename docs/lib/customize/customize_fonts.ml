open! Core

module Kind = struct
  type t =
    | Sans
    | Mono
    | Serif
  [@@deriving sexp_of, compare, equal]

  let name = function
    | Sans -> "sans"
    | Mono -> "mono"
    | Serif -> "serif"
  ;;
end

module Font = struct
  type t =
    { name : string
    ; title : string
    ; kind : Kind.t
    ; family : string
    ; registry_variable : string
    ; preview_variable : string
    ; import : string
    ; dependency : string
    ; weight : string list
    ; available : bool
    }
  [@@deriving sexp_of]
end

let all : Font.t list =
  [ { name = "geist"
    ; title = "Geist"
    ; kind = Sans
    ; family = "'Geist Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-geist-sans"
    ; import = "Geist"
    ; dependency = "@fontsource-variable/geist"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "inter"
    ; title = "Inter"
    ; kind = Sans
    ; family = "'Inter Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-inter"
    ; import = "Inter"
    ; dependency = "@fontsource-variable/inter"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "noto-sans"
    ; title = "Noto Sans"
    ; kind = Sans
    ; family = "'Noto Sans Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-noto-sans"
    ; import = "Noto_Sans"
    ; dependency = "@fontsource-variable/noto-sans"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "nunito-sans"
    ; title = "Nunito Sans"
    ; kind = Sans
    ; family = "'Nunito Sans Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-nunito-sans"
    ; import = "Nunito_Sans"
    ; dependency = "@fontsource-variable/nunito-sans"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "figtree"
    ; title = "Figtree"
    ; kind = Sans
    ; family = "'Figtree Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-figtree"
    ; import = "Figtree"
    ; dependency = "@fontsource-variable/figtree"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "roboto"
    ; title = "Roboto"
    ; kind = Sans
    ; family = "'Roboto Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-roboto"
    ; import = "Roboto"
    ; dependency = "@fontsource-variable/roboto"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "raleway"
    ; title = "Raleway"
    ; kind = Sans
    ; family = "'Raleway Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-raleway"
    ; import = "Raleway"
    ; dependency = "@fontsource-variable/raleway"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "dm-sans"
    ; title = "DM Sans"
    ; kind = Sans
    ; family = "'DM Sans Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-dm-sans"
    ; import = "DM_Sans"
    ; dependency = "@fontsource-variable/dm-sans"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "public-sans"
    ; title = "Public Sans"
    ; kind = Sans
    ; family = "'Public Sans Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-public-sans"
    ; import = "Public_Sans"
    ; dependency = "@fontsource-variable/public-sans"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "outfit"
    ; title = "Outfit"
    ; kind = Sans
    ; family = "'Outfit Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-outfit"
    ; import = "Outfit"
    ; dependency = "@fontsource-variable/outfit"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "oxanium"
    ; title = "Oxanium"
    ; kind = Sans
    ; family = "'Oxanium Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-oxanium"
    ; import = "Oxanium"
    ; dependency = "@fontsource-variable/oxanium"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "manrope"
    ; title = "Manrope"
    ; kind = Sans
    ; family = "'Manrope Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-manrope"
    ; import = "Manrope"
    ; dependency = "@fontsource-variable/manrope"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "space-grotesk"
    ; title = "Space Grotesk"
    ; kind = Sans
    ; family = "'Space Grotesk Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-space-grotesk"
    ; import = "Space_Grotesk"
    ; dependency = "@fontsource-variable/space-grotesk"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "montserrat"
    ; title = "Montserrat"
    ; kind = Sans
    ; family = "'Montserrat Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-montserrat"
    ; import = "Montserrat"
    ; dependency = "@fontsource-variable/montserrat"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "ibm-plex-sans"
    ; title = "IBM Plex Sans"
    ; kind = Sans
    ; family = "'IBM Plex Sans Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-ibm-plex-sans"
    ; import = "IBM_Plex_Sans"
    ; dependency = "@fontsource-variable/ibm-plex-sans"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "source-sans-3"
    ; title = "Source Sans 3"
    ; kind = Sans
    ; family = "'Source Sans 3 Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-source-sans-3"
    ; import = "Source_Sans_3"
    ; dependency = "@fontsource-variable/source-sans-3"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "instrument-sans"
    ; title = "Instrument Sans"
    ; kind = Sans
    ; family = "'Instrument Sans Variable', sans-serif"
    ; registry_variable = "--font-sans"
    ; preview_variable = "--font-instrument-sans"
    ; import = "Instrument_Sans"
    ; dependency = "@fontsource-variable/instrument-sans"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "jetbrains-mono"
    ; title = "JetBrains Mono"
    ; kind = Mono
    ; family = "'JetBrains Mono Variable', monospace"
    ; registry_variable = "--font-mono"
    ; preview_variable = "--font-jetbrains-mono"
    ; import = "JetBrains_Mono"
    ; dependency = "@fontsource-variable/jetbrains-mono"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "geist-mono"
    ; title = "Geist Mono"
    ; kind = Mono
    ; family = "'Geist Mono Variable', monospace"
    ; registry_variable = "--font-mono"
    ; preview_variable = "--font-geist-mono"
    ; import = "Geist_Mono"
    ; dependency = "@fontsource-variable/geist-mono"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "noto-serif"
    ; title = "Noto Serif"
    ; kind = Serif
    ; family = "'Noto Serif Variable', serif"
    ; registry_variable = "--font-serif"
    ; preview_variable = "--font-noto-serif"
    ; import = "Noto_Serif"
    ; dependency = "@fontsource-variable/noto-serif"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "roboto-slab"
    ; title = "Roboto Slab"
    ; kind = Serif
    ; family = "'Roboto Slab Variable', serif"
    ; registry_variable = "--font-serif"
    ; preview_variable = "--font-roboto-slab"
    ; import = "Roboto_Slab"
    ; dependency = "@fontsource-variable/roboto-slab"
    ; weight = [  ]
    ; available = false
    }
  ;    { name = "merriweather"
    ; title = "Merriweather"
    ; kind = Serif
    ; family = "'Merriweather Variable', serif"
    ; registry_variable = "--font-serif"
    ; preview_variable = "--font-merriweather"
    ; import = "Merriweather"
    ; dependency = "@fontsource-variable/merriweather"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "lora"
    ; title = "Lora"
    ; kind = Serif
    ; family = "'Lora Variable', serif"
    ; registry_variable = "--font-serif"
    ; preview_variable = "--font-lora"
    ; import = "Lora"
    ; dependency = "@fontsource-variable/lora"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "playfair-display"
    ; title = "Playfair Display"
    ; kind = Serif
    ; family = "'Playfair Display Variable', serif"
    ; registry_variable = "--font-serif"
    ; preview_variable = "--font-playfair-display"
    ; import = "Playfair_Display"
    ; dependency = "@fontsource-variable/playfair-display"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "eb-garamond"
    ; title = "EB Garamond"
    ; kind = Serif
    ; family = "'EB Garamond Variable', serif"
    ; registry_variable = "--font-serif"
    ; preview_variable = "--font-eb-garamond"
    ; import = "EB_Garamond"
    ; dependency = "@fontsource-variable/eb-garamond"
    ; weight = [  ]
    ; available = true
    }
  ;    { name = "instrument-serif"
    ; title = "Instrument Serif"
    ; kind = Serif
    ; family = "'Instrument Serif', serif"
    ; registry_variable = "--font-serif"
    ; preview_variable = "--font-instrument-serif"
    ; import = "Instrument_Serif"
    ; dependency = "@fontsource/instrument-serif"
    ; weight = [ "400" ]
    ; available = true
    }
  ]
;;

let find name = List.find all ~f:(fun (f : Font.t) -> String.equal f.name name)

(* The weights each bundled file covers (its wght axis). *)
let weights =
  [ "geist", "100 900"
  ; "inter", "100 900"
  ; "noto-sans", "100 900"
  ; "nunito-sans", "200 1000"
  ; "figtree", "300 900"
  ; "roboto", "100 900"
  ; "raleway", "100 900"
  ; "dm-sans", "100 1000"
  ; "public-sans", "100 900"
  ; "outfit", "100 900"
  ; "oxanium", "200 800"
  ; "manrope", "200 800"
  ; "space-grotesk", "300 700"
  ; "montserrat", "100 900"
  ; "ibm-plex-sans", "100 700"
  ; "source-sans-3", "200 900"
  ; "instrument-sans", "400 700"
  ; "jetbrains-mono", "100 800"
  ; "geist-mono", "100 900"
  ; "noto-serif", "100 900"
  ; "merriweather", "300 900"
  ; "lora", "400 700"
  ; "playfair-display", "400 900"
  ; "eb-garamond", "400 800"
  ; "instrument-serif", "400"
  ]
;;

let root_class = "customize-fonts"

(* "'Inter Variable', sans-serif" -> "'Inter Variable'" *)
let face_name (f : Font.t) =
  match String.lsplit2 f.family ~on:',' with
  | Some (first, _) -> String.strip first
  | None -> f.family
;;

let css =
  let faces =
    List.filter_map all ~f:(fun f ->
      if not f.available
      then None
      else
        Some
          (sprintf
             "@font-face{font-family:%s;font-style:normal;font-weight:%s;font-display:swap;src:url(fonts/%s.woff2) format(\"woff2\")}"
             (face_name f)
             (List.Assoc.find weights ~equal:String.equal f.name
              |> Option.value ~default:"400")
             f.name))
  in
  let vars =
    List.filter_map all ~f:(fun f ->
      if f.available then Some (sprintf "%s:%s" f.preview_variable (face_name f)) else None)
  in
  String.concat ~sep:"\n" faces
  ^ sprintf "\n.%s{%s}" root_class (String.concat ~sep:";" vars)
;;

let style = Virtual_dom.Vdom.Node.create "style" [ Virtual_dom.Vdom.Node.text css ]
