open! Core

(* Never reorder these lists, only append: a code stores indices. *)
let bases = [ "radix"; "base"; "aria" ]
let styles = [ "nova"; "vega"; "maia"; "lyra"; "mira"; "luma"; "sera"; "rhea" ]

let base_colors =
  [ "neutral"; "stone"; "zinc"; "gray"; "mauve"; "olive"; "mist"; "taupe" ]
;;

let themes =
  [ "neutral"
  ; "stone"
  ; "zinc"
  ; "gray"
  ; "amber"
  ; "blue"
  ; "cyan"
  ; "emerald"
  ; "fuchsia"
  ; "green"
  ; "indigo"
  ; "lime"
  ; "orange"
  ; "pink"
  ; "purple"
  ; "red"
  ; "rose"
  ; "sky"
  ; "teal"
  ; "violet"
  ; "yellow"
  ; "mauve"
  ; "olive"
  ; "mist"
  ; "taupe"
  ]
;;

let chart_colors = themes

let v1_chart_color_map =
  [ "neutral", "blue"
  ; "stone", "lime"
  ; "zinc", "amber"
  ; "mauve", "emerald"
  ; "olive", "violet"
  ; "mist", "rose"
  ; "taupe", "cyan"
  ]
;;

let icon_libraries =
  [ "lucide"; "hugeicons"; "tabler"; "phosphor"; "remixicon" ]
;;

let fonts =
  [ "inter"
  ; "noto-sans"
  ; "nunito-sans"
  ; "figtree"
  ; "roboto"
  ; "raleway"
  ; "dm-sans"
  ; "public-sans"
  ; "outfit"
  ; "jetbrains-mono"
  ; "geist"
  ; "geist-mono"
  ; "lora"
  ; "merriweather"
  ; "playfair-display"
  ; "noto-serif"
  ; "roboto-slab"
  ; "oxanium"
  ; "manrope"
  ; "space-grotesk"
  ; "montserrat"
  ; "ibm-plex-sans"
  ; "source-sans-3"
  ; "instrument-sans"
  ; "eb-garamond"
  ; "instrument-serif"
  ]
;;

let font_headings = "inherit" :: fonts
let radii = [ "default"; "none"; "small"; "medium"; "large" ]
let menu_accents = [ "subtle"; "bold" ]

let menu_colors =
  [ "default"; "inverted"; "default-translucent"; "inverted-translucent" ]
;;

type t =
  { style : string
  ; base_color : string
  ; theme : string
  ; chart_color : string option
  ; icon_library : string
  ; font : string
  ; font_heading : string
  ; radius : string
  ; menu_accent : string
  ; menu_color : string
  }
[@@deriving sexp_of, equal, compare]

(* PRESET_FIELDS_V2, in order: (values, bits, get, set). The first eight
   are v1's. *)
type field =
  { values : string list
  ; bits : int
  ; get : t -> string
  ; set : t -> string -> t
  }

let fields_v2 =
  [ { values = menu_colors
    ; bits = 3
    ; get = (fun t -> t.menu_color)
    ; set = (fun t v -> { t with menu_color = v })
    }
  ; { values = menu_accents
    ; bits = 3
    ; get = (fun t -> t.menu_accent)
    ; set = (fun t v -> { t with menu_accent = v })
    }
  ; { values = radii
    ; bits = 4
    ; get = (fun t -> t.radius)
    ; set = (fun t v -> { t with radius = v })
    }
  ; { values = fonts
    ; bits = 6
    ; get = (fun t -> t.font)
    ; set = (fun t v -> { t with font = v })
    }
  ; { values = icon_libraries
    ; bits = 6
    ; get = (fun t -> t.icon_library)
    ; set = (fun t v -> { t with icon_library = v })
    }
  ; { values = themes
    ; bits = 6
    ; get = (fun t -> t.theme)
    ; set = (fun t v -> { t with theme = v })
    }
  ; { values = base_colors
    ; bits = 6
    ; get = (fun t -> t.base_color)
    ; set = (fun t v -> { t with base_color = v })
    }
  ; { values = styles
    ; bits = 6
    ; get = (fun t -> t.style)
    ; set = (fun t v -> { t with style = v })
    }
  ; { values = chart_colors
    ; bits = 6
    ; get = (fun t -> Option.value t.chart_color ~default:"")
    ; set = (fun t v -> { t with chart_color = Some v })
    }
  ; { values = font_headings
    ; bits = 5
    ; get = (fun t -> t.font_heading)
    ; set = (fun t v -> { t with font_heading = v })
    }
  ]
;;

let fields_v1 = List.take fields_v2 8

let default =
  { style = List.hd_exn styles
  ; base_color = List.hd_exn base_colors
  ; theme = List.hd_exn themes
  ; chart_color = Some (List.hd_exn chart_colors)
  ; icon_library = List.hd_exn icon_libraries
  ; font = List.hd_exn fonts
  ; font_heading = List.hd_exn font_headings
  ; radius = List.hd_exn radii
  ; menu_accent = List.hd_exn menu_accents
  ; menu_color = List.hd_exn menu_colors
  }
;;

let alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

(* Numbers are JavaScript's (doubles), as in preset.ts: a code holds 51
   bits, more than js_of_ocaml's 32-bit [int]. *)
let to_base62_float num =
  if Float.( = ) num 0.
  then "0"
  else (
    let rec go n acc =
      if Float.( <= ) n 0.
      then acc
      else (
        let digit = Float.to_int (Float.mod_float n 62.) in
        go (Float.round_down (n /. 62.)) (String.make 1 alphabet.[digit] ^ acc))
    in
    go num "")
;;

let to_base62 = to_base62_float

let of_base62_float s =
  String.fold_until
    s
    ~init:0.
    ~f:(fun acc c ->
      match String.index alphabet c with
      | None -> Stop (-1.)
      | Some i -> Continue ((acc *. 62.) +. Float.of_int i))
    ~finish:Fn.id
;;

let of_base62 = of_base62_float

let index values v =
  List.findi values ~f:(fun _ x -> String.equal x v)
  |> Option.value_map ~default:0 ~f:fst
;;

let encode t =
  let bits, _ =
    List.fold fields_v2 ~init:(0., 0) ~f:(fun (bits, offset) f ->
      ( bits
        +. (Float.of_int (index f.values (f.get t))
            *. (2. ** Float.of_int offset))
      , offset + f.bits ))
  in
  "b" ^ to_base62_float bits
;;

let decode code =
  if String.length code < 2
  then None
  else (
    let fields =
      match code.[0] with
      | 'a' -> Some fields_v1
      | 'b' -> Some fields_v2
      | _ -> None
    in
    match fields with
    | None -> None
    | Some fields ->
      let bits = of_base62_float (String.drop_prefix code 1) in
      if Float.( < ) bits 0.
      then None
      else (
        let t, _ =
          List.fold
            fields
            ~init:({ default with chart_color = None }, 0)
            ~f:(fun (t, offset) f ->
              let idx =
                Float.mod_float
                  (Float.round_down (bits /. (2. ** Float.of_int offset)))
                  (2. ** Float.of_int f.bits)
                |> Float.to_int
              in
              let v =
                match List.nth f.values idx with
                | Some v -> v
                | None -> List.hd_exn f.values
              in
              f.set t v, offset + f.bits)
        in
        Some
          (if Char.equal code.[0] 'a'
           then { t with font_heading = "inherit" }
           else t)))
;;

let is_preset_code s =
  let n = String.length s in
  n >= 2
  && n <= 10
  && (Char.equal s.[0] 'a' || Char.equal s.[0] 'b')
  && String.for_all (String.drop_prefix s 1) ~f:(fun c -> String.mem alphabet c)
;;

let parse_input value =
  let input = String.strip value in
  if String.is_empty input
  then None
  else (
    (* /^--preset\b\s+(.+)$/i *)
    let preset =
      let lower = String.lowercase input in
      if String.is_prefix lower ~prefix:"--preset"
      then (
        let rest = String.drop_prefix input 8 in
        if (not (String.is_empty rest)) && Char.is_whitespace rest.[0]
        then (
          let rest = String.strip rest in
          if String.is_empty rest then input else rest)
        else input)
      else input
    in
    Option.some_if (is_preset_code preset) preset)
;;

let parse_style style =
  match
    List.find bases ~f:(fun base -> String.is_prefix style ~prefix:(base ^ "-"))
  with
  | Some base -> Some base, String.drop_prefix style (String.length base + 1)
  | None -> None, style
;;
