open! Core
module P = Loon_docs.Create_preset

let show code = print_s [%sexp (code : string), (P.decode code : P.t option)]

let%expect_test "base62" =
  List.iter
    [ 0.; 1.; 61.; 62.; 3843.; 1e15; 2. ** 51. ]
    ~f:(fun n ->
      let s = P.to_base62 n in
      printf "%.0f %s %b\n" n s (Float.equal (P.of_base62 s) n));
  printf "%.0f\n" (P.of_base62 "!@#");
  [%expect
    {|
    0 0 true
    1 1 true
    61 z true
    62 10 true
    3843 zz true
    1000000000000000 4ZxYle1gW true
    2251799813685248 AJQCIzMf2 true
    -1
    |}]
;;

(* Codes from shadcn's encodePreset (packages/registry/src/preset/preset.ts,
   run under node). *)
let%expect_test "codes shadcn makes" =
  let vega = { P.default with style = "vega" } in
  print_endline (P.encode P.default);
  print_endline (P.encode vega);
  print_endline
    (P.encode
       { style = "vega"
       ; base_color = "zinc"
       ; theme = "blue"
       ; chart_color = Some "emerald"
       ; icon_library = "lucide"
       ; font = "geist"
       ; font_heading = "lora"
       ; radius = "large"
       ; menu_accent = "bold"
       ; menu_color = "inverted"
       });
  print_endline
    (P.encode
       { vega with
         base_color = "taupe"
       ; theme = "taupe"
       ; chart_color = Some "taupe"
       ; font = "instrument-serif"
       ; font_heading = "instrument-serif"
       ; radius = "none"
       ; menu_color = "inverted-translucent"
       ; icon_library = "remixicon"
       });
  [%expect
    {|
    b0
    bIkeymG
    b4DxGlzePJ
    b8V1pOqCO3
    |}]
;;

let%expect_test "decoding as shadcn does" =
  List.iter
    [ "a0"; "b0"; "b1"; "aZZZZ"; "a2Vl4"; "bzzzzzzzz"; "b4DxGlzePJ" ]
    ~f:show;
  [%expect
    {|
    (a0
     (((style nova) (base_color neutral) (theme neutral) (chart_color ())
       (icon_library lucide) (font inter) (font_heading inherit) (radius default)
       (menu_accent subtle) (menu_color default))))
    (b0
     (((style nova) (base_color neutral) (theme neutral) (chart_color (neutral))
       (icon_library lucide) (font inter) (font_heading inherit) (radius default)
       (menu_accent subtle) (menu_color default))))
    (b1
     (((style nova) (base_color neutral) (theme neutral) (chart_color (neutral))
       (icon_library lucide) (font inter) (font_heading inherit) (radius default)
       (menu_accent subtle) (menu_color inverted))))
    (aZZZZ
     (((style nova) (base_color neutral) (theme zinc) (chart_color ())
       (icon_library hugeicons) (font instrument-sans) (font_heading inherit)
       (radius default) (menu_accent subtle) (menu_color inverted))))
    (a2Vl4
     (((style nova) (base_color neutral) (theme neutral) (chart_color ())
       (icon_library lucide) (font outfit) (font_heading inherit)
       (radius default) (menu_accent subtle) (menu_color default-translucent))))
    (bzzzzzzzz
     (((style nova) (base_color mauve) (theme sky) (chart_color (cyan))
       (icon_library lucide) (font inter) (font_heading nunito-sans)
       (radius medium) (menu_accent subtle) (menu_color default))))
    (b4DxGlzePJ
     (((style vega) (base_color zinc) (theme blue) (chart_color (emerald))
       (icon_library lucide) (font geist) (font_heading lora) (radius large)
       (menu_accent bold) (menu_color inverted))))
    |}]
;;

let%expect_test "invalid codes" =
  List.iter [ ""; "b"; "c0"; "b!@#" ] ~f:show;
  [%expect
    {|
    ("" ())
    (b ())
    (c0 ())
    (b!@# ())
    |}]
;;

let%expect_test "round trips every value of every field" =
  let check name values set get =
    List.iter values ~f:(fun v ->
      let t = set P.default v in
      match P.decode (P.encode t) with
      | Some d when String.equal (get d) v && P.equal d t -> ()
      | d -> print_s [%message "mismatch" name v (d : P.t option)])
  in
  check "style" P.styles (fun t v -> { t with style = v }) (fun t -> t.style);
  check
    "base_color"
    P.base_colors
    (fun t v -> { t with base_color = v })
    (fun t -> t.base_color);
  check "theme" P.themes (fun t v -> { t with theme = v }) (fun t -> t.theme);
  check
    "chart_color"
    P.chart_colors
    (fun t v -> { t with chart_color = Some v })
    (fun t -> Option.value_exn t.chart_color);
  check
    "icon_library"
    P.icon_libraries
    (fun t v -> { t with icon_library = v })
    (fun t -> t.icon_library);
  check "font" P.fonts (fun t v -> { t with font = v }) (fun t -> t.font);
  check
    "font_heading"
    P.font_headings
    (fun t v -> { t with font_heading = v })
    (fun t -> t.font_heading);
  check "radius" P.radii (fun t v -> { t with radius = v }) (fun t -> t.radius);
  check
    "menu_accent"
    P.menu_accents
    (fun t v -> { t with menu_accent = v })
    (fun t -> t.menu_accent);
  check
    "menu_color"
    P.menu_colors
    (fun t v -> { t with menu_color = v })
    (fun t -> t.menu_color);
  (* Codes stay short, and start with the version. *)
  let longest =
    { P.default with
      style = List.last_exn P.styles
    ; theme = List.last_exn P.themes
    ; chart_color = Some (List.last_exn P.chart_colors)
    ; font = List.last_exn P.fonts
    ; font_heading = List.last_exn P.font_headings
    ; menu_color = List.last_exn P.menu_colors
    }
  in
  let code = P.encode longest in
  print_s
    [%message code (String.length code : int) (P.is_preset_code code : bool)];
  [%expect
    {| (b8V3brcgZX ("String.length code" 10) ("P.is_preset_code code" true)) |}]
;;

let%expect_test "is_preset_code" =
  List.iter
    [ "a0"
    ; "b0"
    ; "c0"
    ; ""
    ; "https://ui.shadcn.com/init?foo=bar"
    ; "radix-nova"
    ; "A1234567890"
    ; "A!@#"
    ; "b123456789"
    ; "b1234567890"
    ]
    ~f:(fun s -> printf "%S %b\n" s (P.is_preset_code s));
  [%expect
    {|
    "a0" true
    "b0" true
    "c0" false
    "" false
    "https://ui.shadcn.com/init?foo=bar" false
    "radix-nova" false
    "A1234567890" false
    "A!@#" false
    "b123456789" true
    "b1234567890" false
    |}]
;;

(* parse-preset-input.test.ts *)
let%expect_test "parse_input" =
  List.iter
    [ "b0"
    ; "  b2D0vL  "
    ; "--preset b0"
    ; "--PRESET   a2Vl4 "
    ; "pnpm dlx shadcn@latest init --preset b0"
    ; "--preset"
    ; "--presetb0"
    ; "radix-nova"
    ; ""
    ]
    ~f:(fun s ->
      print_s [%sexp (s : string), (P.parse_input s : string option)]);
  [%expect
    {|
    (b0 (b0))
    ("  b2D0vL  " (b2D0vL))
    ("--preset b0" (b0))
    ("--PRESET   a2Vl4 " (a2Vl4))
    ("pnpm dlx shadcn@latest init --preset b0" ())
    (--preset ())
    (--presetb0 ())
    (radix-nova ())
    ("" ())
    |}]
;;

let%expect_test "parse_style" =
  List.iter [ "aria-nova"; "base-vega"; "new-york"; "radix-luma" ] ~f:(fun s ->
    print_s [%sexp (s : string), (P.parse_style s : string option * string)]);
  [%expect
    {|
    (aria-nova ((aria) nova))
    (base-vega ((base) vega))
    (new-york (() new-york))
    (radix-luma ((radix) luma))
    |}]
;;
