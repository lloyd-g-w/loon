open! Core
module Attr = Virtual_dom.Vdom.Attr

let font_family name =
  Option.map (Create_config.font name) ~f:Create_config.font_family
;;

let variables ~(mode : Loon.Theme.Mode.t) (p : Create_preset.t) =
  let theme = Create_theme_css.of_preset p in
  let colours =
    match mode with
    | Light -> theme.light
    | Dark ->
      (* The radius is only in [light]. *)
      theme.dark
      @ List.filter theme.light ~f:(fun (k, _) -> String.equal k "radius")
  in
  let body = Option.value (font_family p.font) ~default:"sans-serif" in
  let heading =
    if String.equal p.font_heading "inherit"
    then body
    else Option.value (font_family p.font_heading) ~default:body
  in
  List.map colours ~f:(fun (k, v) -> "--" ^ k, v)
  @ [ "--font-sans", body; "--font-heading", heading ]
;;

let attrs ~mode (p : Create_preset.t) =
  [ Attr.create "data-create-preview" ""
  ; Attr.create "data-menu-color" p.menu_color
  ; Attr.__css_vars_no_kebabs (variables ~mode p)
  ; Attr.classes
      ([ Customize_fonts.root_class ]
       @
       match mode with
       | Dark -> [ "dark" ]
       | Light -> [])
  ]
;;

let menus =
  [ "dropdown-menu-content"
  ; "dropdown-menu-sub-content"
  ; "context-menu-content"
  ; "context-menu-sub-content"
  ; "menubar-content"
  ; "menubar-sub-content"
  ; "select-content"
  ; "combobox-content"
  ]
  |> List.map ~f:(sprintf "[data-slot=%s]")
  |> String.concat ~sep:", "
;;

let titles =
  [ "card-title"
  ; "dialog-title"
  ; "alert-dialog-title"
  ; "sheet-title"
  ; "drawer-title"
  ; "empty-title"
  ]
  |> List.map ~f:(sprintf "[data-slot=%s]")
  |> String.concat ~sep:", "
;;

let css (p : Create_preset.t) =
  let root = "[data-create-preview]" in
  let dark = (Create_theme_css.of_preset p).dark in
  String.concat
    ~sep:"\n"
    [ sprintf "%s { font-family: var(--font-sans); }" root
    ; sprintf "%s :is(%s) { font-family: var(--font-heading); }" root titles
    ; sprintf
        "%s:is([data-menu-color=inverted], [data-menu-color=inverted-translucent]) :is(%s) \
         { color-scheme: dark; %s }"
        root
        menus
        (String.concat
           ~sep:" "
           (List.map dark ~f:(fun (k, v) -> sprintf "--%s: %s;" k v)))
    ; sprintf
        "%s:is([data-menu-color=default-translucent], \
         [data-menu-color=inverted-translucent]) :is(%s) { animation: none !important; \
         background-color: color-mix(in oklab, var(--popover) 70%%, transparent); \
         backdrop-filter: blur(40px) saturate(1.5); }"
        root
        menus
    ; sprintf
        "%s:is([data-menu-color=default-translucent], \
         [data-menu-color=inverted-translucent]) :is(%s) :is([data-slot$=-item], \
         [data-slot$=-trigger]):is(:focus, [data-highlighted]) { background-color: \
         color-mix(in oklab, var(--foreground) 10%%, transparent); }"
        root
        menus
    ]
;;
