open! Core
module P = Loon_docs.Create_preset
module Css = Loon_docs.Create_theme_css
module Params = Loon_docs.Create_params

let vega = Loon_docs.Create_config.reset_preset

let%expect_test "the default theme's globals.css" =
  print_endline (Css.css vega);
  [%expect
    {|
    :root {
      --background: oklch(1 0 0);
      --foreground: oklch(0.145 0 0);
      --card: oklch(1 0 0);
      --card-foreground: oklch(0.145 0 0);
      --popover: oklch(1 0 0);
      --popover-foreground: oklch(0.145 0 0);
      --primary: oklch(0.205 0 0);
      --primary-foreground: oklch(0.985 0 0);
      --secondary: oklch(0.97 0 0);
      --secondary-foreground: oklch(0.205 0 0);
      --muted: oklch(0.97 0 0);
      --muted-foreground: oklch(0.556 0 0);
      --accent: oklch(0.97 0 0);
      --accent-foreground: oklch(0.205 0 0);
      --destructive: oklch(0.577 0.245 27.325);
      --border: oklch(0.922 0 0);
      --input: oklch(0.922 0 0);
      --ring: oklch(0.708 0 0);
      --chart-1: oklch(0.87 0 0);
      --chart-2: oklch(0.556 0 0);
      --chart-3: oklch(0.439 0 0);
      --chart-4: oklch(0.371 0 0);
      --chart-5: oklch(0.269 0 0);
      --radius: 0.625rem;
      --sidebar: oklch(0.985 0 0);
      --sidebar-foreground: oklch(0.145 0 0);
      --sidebar-primary: oklch(0.205 0 0);
      --sidebar-primary-foreground: oklch(0.985 0 0);
      --sidebar-accent: oklch(0.97 0 0);
      --sidebar-accent-foreground: oklch(0.205 0 0);
      --sidebar-border: oklch(0.922 0 0);
      --sidebar-ring: oklch(0.708 0 0);
    }

    .dark {
      --background: oklch(0.145 0 0);
      --foreground: oklch(0.985 0 0);
      --card: oklch(0.205 0 0);
      --card-foreground: oklch(0.985 0 0);
      --popover: oklch(0.205 0 0);
      --popover-foreground: oklch(0.985 0 0);
      --primary: oklch(0.922 0 0);
      --primary-foreground: oklch(0.205 0 0);
      --secondary: oklch(0.269 0 0);
      --secondary-foreground: oklch(0.985 0 0);
      --muted: oklch(0.269 0 0);
      --muted-foreground: oklch(0.708 0 0);
      --accent: oklch(0.269 0 0);
      --accent-foreground: oklch(0.985 0 0);
      --destructive: oklch(0.704 0.191 22.216);
      --border: oklch(1 0 0 / 10%);
      --input: oklch(1 0 0 / 15%);
      --ring: oklch(0.556 0 0);
      --chart-1: oklch(0.87 0 0);
      --chart-2: oklch(0.556 0 0);
      --chart-3: oklch(0.439 0 0);
      --chart-4: oklch(0.371 0 0);
      --chart-5: oklch(0.269 0 0);
      --sidebar: oklch(0.205 0 0);
      --sidebar-foreground: oklch(0.985 0 0);
      --sidebar-primary: oklch(0.488 0.243 264.376);
      --sidebar-primary-foreground: oklch(0.985 0 0);
      --sidebar-accent: oklch(0.269 0 0);
      --sidebar-accent-foreground: oklch(0.985 0 0);
      --sidebar-border: oklch(1 0 0 / 10%);
      --sidebar-ring: oklch(0.556 0 0);
    }

    @theme inline {
      --font-sans: 'Inter Variable', sans-serif;
      --font-heading: 'Inter Variable', sans-serif;
    }
    |}]
;;

let%expect_test "an accent, a chart colour, bold menus and a radius" =
  let t =
    Css.of_preset
      { vega with
        base_color = "zinc"
      ; theme = "blue"
      ; chart_color = Some "emerald"
      ; menu_accent = "bold"
      ; radius = "large"
      ; font = "geist"
      ; font_heading = "lora"
      }
  in
  let pick vars =
    List.filter vars ~f:(fun (k, _) ->
      List.mem
        [ "background"
        ; "primary"
        ; "accent"
        ; "accent-foreground"
        ; "chart-1"
        ; "chart-5"
        ; "radius"
        ]
        k
        ~equal:String.equal)
  in
  print_s
    [%sexp
      (pick t.light : (string * string) list)
    , (pick t.dark : (string * string) list)];
  print_endline
    (Css.font_css { vega with font = "geist"; font_heading = "lora" });
  print_endline (Css.font_css { vega with font = "jetbrains-mono" });
  [%expect
    {|
    (((background "oklch(1 0 0)") (primary "oklch(0.488 0.243 264.376)")
      (accent "oklch(0.488 0.243 264.376)")
      (accent-foreground "oklch(0.97 0.014 254.604)")
      (chart-1 "oklch(0.845 0.143 164.978)")
      (chart-5 "oklch(0.432 0.095 166.913)") (radius 0.875rem))
     ((background "oklch(0.141 0.005 285.823)")
      (primary "oklch(0.424 0.199 265.638)")
      (accent "oklch(0.424 0.199 265.638)")
      (accent-foreground "oklch(0.97 0.014 254.604)")
      (chart-1 "oklch(0.845 0.143 164.978)")
      (chart-5 "oklch(0.432 0.095 166.913)")))
    @theme inline {
      --font-sans: 'Geist Variable', sans-serif;
      --font-heading: 'Lora Variable', serif;
    }
    @theme inline {
      --font-sans: 'JetBrains Mono Variable', monospace;
      --font-heading: 'JetBrains Mono Variable', monospace;
    }
    |}]
;;

let%expect_test "params from the query" =
  let show q =
    let p = Params.of_query q in
    print_s [%message q (Params.to_query p) (p.preset : P.t)]
  in
  (* no preset: shadcn's default b0, as Vega *)
  show "";
  (* a preset in another style becomes Vega; overrides of the heading and charts *)
  show
    "preset=b4DxGlzePJ&item=preview&fontHeading=geist&chartColor=rose&template=vite";
  (* v1 codes take the charts their theme had *)
  show "preset=a0";
  (* an invalid code: the individual keys *)
  show "preset=nope&baseColor=stone&theme=stone&font=lora&radius=small";
  (* a theme of another base colour, and bold with translucent menus *)
  show
    ("preset="
     ^ P.encode
         { vega with
           base_color = "zinc"
         ; theme = "stone"
         ; menu_accent = "bold"
         ; menu_color = "default-translucent"
         });
  [%expect
    {|
    ("" preset=b0&item=preview-02
     (p.preset
      ((style nova) (base_color neutral) (theme neutral) (chart_color (neutral))
       (icon_library lucide) (font inter) (font_heading inherit) (radius default)
       (menu_accent subtle) (menu_color default))))
    (preset=b4DxGlzePJ&item=preview&fontHeading=geist&chartColor=rose&template=vite
     preset=b5021FUqX&item=preview&template=vite
     (p.preset
      ((style vega) (base_color zinc) (theme blue) (chart_color (rose))
       (icon_library lucide) (font geist) (font_heading inherit) (radius large)
       (menu_accent bold) (menu_color inverted))))
    (preset=a0 preset=b1YmpVh4a&item=preview-02
     (p.preset
      ((style nova) (base_color neutral) (theme neutral) (chart_color (blue))
       (icon_library lucide) (font inter) (font_heading inherit) (radius default)
       (menu_accent subtle) (menu_color default))))
    (preset=nope&baseColor=stone&theme=stone&font=lora&radius=small
     preset=bJMSkiUy&item=preview-02
     (p.preset
      ((style nova) (base_color stone) (theme stone) (chart_color (stone))
       (icon_library lucide) (font lora) (font_heading inherit) (radius small)
       (menu_accent subtle) (menu_color default))))
    (preset=bJLHEYk preset=bd1gAJJi&item=preview-02
     (p.preset
      ((style vega) (base_color zinc) (theme zinc) (chart_color (zinc))
       (icon_library lucide) (font inter) (font_heading inherit) (radius default)
       (menu_accent subtle) (menu_color default-translucent))))
    |}]
;;
