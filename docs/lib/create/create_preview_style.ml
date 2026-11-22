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
  (* An attribute, not [Attr.style] (which drops custom properties) nor a
     css-vars hook (which tests cannot see). *)
  ; Attr.create
      "style"
      (List.map (variables ~mode p) ~f:(fun (field, value) ->
         Css_gen.create ~field ~value)
       |> Css_gen.concat
       |> Css_gen.to_string_css)
  ; Attr.class_ Customize_fonts.root_class
  ]
  @ Loon.Theme.attrs
      ~mode
      ?style:(Loon.Theme.Style.of_name p.style)
      ?menu_color:(Loon.Theme.Menu_color.of_name p.menu_color)
      ()
;;

(* The inverted menus take the preset's dark variables (the stylesheet's
   are the default theme's). *)
let css (p : Create_preset.t) =
  let dark = (Create_theme_css.of_preset p).dark in
  sprintf
    "[data-create-preview] .cn-menu-target:where(.menu-inverted *) { color-scheme: dark; \
     %s }"
    (String.concat ~sep:" " (List.map dark ~f:(fun (k, v) -> sprintf "--%s: %s;" k v)))
;;
