open! Core
open Bonsai_web
open Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr
module Picker = Customize_picker
module Ui = Create_ui
module Field = Create_field
module Mode = Loon.Theme.Mode

let rng =
  lazy
    (if Browser.in_browser ()
     then Random.State.make_self_init ()
     else Random.State.make [| 42 |])
;;

let random n = Random.State.int (Lazy.force rng) n
let div cls children = Node.div ~attrs:[ Attr.class_ cls ] children
let text = Node.text
let customizer_id = "create-customizer"

(* {1 What every part needs} *)

module Env = struct
  type t =
    { params : Create_params.t
    ; preset : Create_preset.t
    ; set : Create_preset.t -> unit Effect.t
    ; set_item : string -> unit Effect.t
    ; preview : Create_preset.t option -> unit Effect.t
    ; locks : Field.Set.t
    ; toggle_lock : Field.t -> unit Effect.t
    ; is_mobile : bool
    ; mode : Mode.t
    }

  let set_field t field value = t.set (Field.set t.preset field value)

  let preview_field t field value =
    t.preview (Some (Create_params.normalize (Field.set t.preset field value)))
  ;;

  let clear_preview t = t.preview None
end

(* {1 Pickers} *)

let lock_button (env : Env.t) field =
  let locked = Set.mem env.locks field in
  let label = if locked then "Unlock" else "Lock" in
  Node.button
    ~attrs:
      [ Attr.type_ "button"
      ; Attr.title label
      ; Attr.create "aria-label" label
      ; Attr.create "data-lock" (Field.name field)
      ; Attr.create "data-locked" (Bool.to_string locked)
      ; Attr.on_click (fun _ -> env.toggle_lock field)
      ; Attr.class_
          "flex size-4 cursor-pointer items-center justify-center rounded opacity-0 \
           ring-foreground/60 transition-opacity outline-none \
           group-focus-within/picker:opacity-100 group-hover/picker:opacity-100 \
           focus:opacity-100 focus-visible:ring-1 data-[locked=true]:opacity-100 \
           pointer-coarse:hidden absolute top-1/2 right-8 -translate-y-1/2"
      ]
    [ Loon.Icon.view ~class_:"size-5 text-foreground" (if locked then Lock else Lock_open)
    ]
;;

let indicator_class =
  "pointer-events-none absolute top-1/2 right-4 flex size-4 -translate-y-1/2 \
   items-center justify-center text-base text-foreground select-none md:right-2.5"
;;

let swatch colour =
  Node.div
    ~attrs:
      [ Attr.__css_vars_no_kebabs [ "--color", colour ]
      ; Attr.class_
          "pointer-events-none absolute top-1/2 right-4 size-4 -translate-y-1/2 \
           rounded-full bg-(--color) select-none md:right-2.5"
      ]
    []
;;

let svg_indicator ?(class_ = indicator_class) markup =
  Node.inner_html
    ~tag:"div"
    ~attrs:[ Attr.class_ class_ ]
    ~this_html_is_sanitized_and_is_totally_safe_trust_me:markup
    ()
;;

let trigger_body ~label ~value indicator =
  [ div
      "flex flex-col justify-start text-left"
      [ div "text-xs text-muted-foreground" [ text label ]
      ; div
          "line-clamp-1 max-w-[80%] truncate text-sm font-medium text-foreground"
          [ text value ]
      ]
  ; indicator
  ]
;;

let note children =
  Picker.label
    ~class_:"max-w-52 text-xs leading-snug font-normal whitespace-normal text-neutral-400"
    children
;;

(* A picker's menu, placed as shadcn's: to the right of the customiser, or
   above it on a phone. *)
let content ?class_ (env : Env.t) t items =
  Picker.content
    ?class_
    ~attrs:[ Attr.on_mouseleave (fun _ -> Env.clear_preview env) ]
    ~side:(if env.is_mobile then Top else Right)
    ~align:(if env.is_mobile then Center else Start)
    ?anchor:(if env.is_mobile then Some customizer_id else None)
    t
    items
;;

module Choice = struct
  type t =
    { value : string
    ; title : string
    ; disabled : bool
    }

  let v ?(disabled = false) value title = { value; title; disabled }
end

(* Radio groups, separated, that set (and on hover preview) [field]. *)
let radio_groups (env : Env.t) ~value ~field groups =
  let on_item_preview =
    if env.is_mobile then None else Some (Env.preview_field env field)
  in
  List.filter groups ~f:(fun g -> not (List.is_empty g))
  |> List.map ~f:(fun (choices : Choice.t list) ->
    Picker.group
      [ Picker.radio_group
          ~value
          ~on_value_change:(Env.set_field env field)
          ?on_item_preview
          (List.map choices ~f:(fun (c : Choice.t) ->
             Picker.radio_item
               ~attrs:[ Attr.create "data-value" c.value ]
               ~disabled:c.disabled
               ~close_on_select:env.is_mobile
               ~value:c.value
               [ text c.title ]))
      ])
  |> List.intersperse ~sep:(Picker.separator ())
;;

(* A picker over one field: its trigger, its menu, its lock. *)
let field_picker
  ?content_class
  ?(extra = [])
  ~field
  ~label
  ~value_title
  ~indicator
  groups
  (local_ graph)
  (env : Env.t Bonsai.t)
  =
  let picker =
    Picker.component
      ~on_open_change:
        (let%arr env in
         fun open_ -> if open_ then Effect.Ignore else Env.clear_preview env)
      (let%arr env in
       fun t ->
         let value = Field.get env.preset field in
         [ Picker.trigger
             ~attrs:[ Attr.create "data-picker" (Field.name field) ]
             t
             (trigger_body ~label ~value:(value_title env value) (indicator env value))
         ; content
             ?class_:content_class
             env
             t
             (radio_groups env ~value ~field (groups env) @ extra)
         ])
      graph
  in
  let%arr picker and env in
  Node.div
    ~attrs:[ Attr.class_ "group/picker relative" ]
    [ picker; lock_button env field ]
;;

let theme_title name =
  Option.value_map (Create_config.theme name) ~default:name ~f:(fun t -> t.title)
;;

let theme_colour name =
  match Create_config.theme name with
  | None -> "transparent"
  | Some t ->
    let key =
      if Create_config.is_base_color name then "muted-foreground" else "primary"
    in
    List.Assoc.find t.dark key ~equal:String.equal |> Option.value ~default:"transparent"
;;

let theme_groups (env : Env.t) =
  let themes = Create_config.themes_for_base_color env.preset.base_color in
  let base, accents =
    List.partition_tf themes ~f:(fun (t : Create_theme.t) ->
      Create_config.is_base_color t.name)
  in
  let choices = List.map ~f:(fun (t : Create_theme.t) -> Choice.v t.name t.title) in
  [ choices base; choices accents ]
;;

let find_style name =
  List.find Create_config.styles ~f:(fun (s : Create_style.t) -> String.equal s.name name)
;;

let style_picker graph env =
  field_picker
    ~field:Style
    ~label:"Style"
    ~value_title:(fun _ v ->
      Option.value_map (find_style v) ~default:v ~f:(fun (s : Create_style.t) -> s.title))
    ~indicator:(fun _ v ->
      match find_style v with
      | Some s -> svg_indicator s.icon
      | None -> Node.none)
    ~extra:
      [ Picker.separator ()
      ; note
          [ text "Other styles need different component markup; loon ports new-york-v4." ]
      ]
    (fun _ ->
      [ List.map Create_config.styles ~f:(fun (s : Create_style.t) ->
          Choice.v
            ~disabled:(Option.is_some (Create_config.style_disabled s.name))
            s.name
            s.title)
      ])
    graph
    env
;;

let radix_logo =
  "<svg role='img' viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'><title>Radix \
   UI</title><path fill='currentColor' d='M11.52 24a7.68 7.68 0 0 1-7.68-7.68 7.68 7.68 0 0 \
   1 7.68-7.68V24Zm0-24v7.68H3.84V0h7.68Zm4.8 7.68a3.84 3.84 0 1 1 0-7.68 3.84 3.84 0 0 1 0 \
   7.68Z'/></svg>"
;;

let lucide_logo =
  "<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' fill='none' \
   stroke='currentColor' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' \
   viewBox='0 0 24 24'><path d='M14 12a4 4 0 0 0-8 0 8 8 0 1 0 16 0 11.97 11.97 0 0 \
   0-4-8.944'/><path d='M10 12a4 4 0 0 0 8 0 8 8 0 1 0-16 0 11.97 11.97 0 0 0 4.063 \
   9'/></svg>"
;;

(* The base and icon library: shown as pickers with loon's one choice
   enabled. *)
let fixed_picker ~label ~value ~title ~logo ~options ~why (local_ graph) env =
  let picker =
    Picker.component
      (let%arr (env : Env.t) = env in
       fun t ->
         [ Picker.trigger
             ~attrs:[ Attr.create "data-picker" label ]
             t
             (trigger_body
                ~label
                ~value:title
                (svg_indicator
                   ~class_:(indicator_class ^ " *:[svg]:size-4 *:[svg]:text-foreground!")
                   logo))
         ; content
             env
             t
             [ Picker.group
                 [ Picker.radio_group
                     ~value
                     ~on_value_change:(fun _ -> Effect.Ignore)
                     (List.map options ~f:(fun (o : Create_config.Option_.t) ->
                        Picker.radio_item
                          ~attrs:[ Attr.create "data-value" o.name ]
                          ~disabled:(Option.is_some o.disabled)
                          ~close_on_select:env.is_mobile
                          ~value:o.name
                          [ text o.title ]))
                 ]
             ; Picker.separator ()
             ; note [ text why ]
             ]
         ])
      graph
  in
  let%arr picker in
  Node.div ~attrs:[ Attr.class_ "group/picker relative" ] [ picker ]
;;

let base_picker graph env =
  fixed_picker
    ~label:"Base"
    ~value:Create_config.base
    ~title:"Radix UI"
    ~logo:radix_logo
    ~options:Create_config.bases
    ~why:"loon ports the Radix components."
    graph
    env
;;

let icon_library_picker graph env =
  fixed_picker
    ~label:"Icon Library"
    ~value:Create_config.icon_library
    ~title:"Lucide"
    ~logo:lucide_logo
    ~options:Create_config.icon_libraries
    ~why:"loon's icons are Lucide's."
    graph
    env
;;

let base_color_picker graph env =
  field_picker
    ~field:Base_color
    ~label:"Base Color"
    ~value_title:(fun _ v -> theme_title v)
    ~indicator:(fun _ v -> swatch (theme_colour v))
    (fun _ ->
      [ List.map Create_config.base_colors ~f:(fun (t : Create_theme.t) ->
          Choice.v t.name t.title)
      ])
    graph
    env
;;

let theme_picker graph env =
  field_picker
    ~field:Theme
    ~label:"Theme"
    ~content_class:"max-h-92"
    ~value_title:(fun _ v -> theme_title v)
    ~indicator:(fun _ v -> swatch (theme_colour v))
    theme_groups
    graph
    env
;;

let chart_color_picker graph env =
  field_picker
    ~field:Chart_color
    ~label:"Chart Color"
    ~content_class:"max-h-92"
    ~value_title:(fun _ v -> theme_title v)
    ~indicator:(fun _ v -> swatch (theme_colour v))
    theme_groups
    graph
    env
;;

let font_title name =
  Option.value_map (Create_config.font name) ~default:name ~f:(fun f -> f.title)
;;

let font_groups ~heading (env : Env.t) =
  let inherit_ =
    if heading then [ [ Choice.v "inherit" (font_title env.preset.font) ] ] else []
  in
  inherit_
  @ List.map [ Customize_fonts.Kind.Sans; Mono; Serif ] ~f:(fun kind ->
    List.filter_map Create_config.fonts ~f:(fun (f : Customize_fonts.Font.t) ->
      if Customize_fonts.Kind.equal f.kind kind
      then Some (Choice.v ~disabled:(not f.available) f.name f.title)
      else None))
;;

let font_picker ~heading graph env =
  let field : Field.t = if heading then Font_heading else Font in
  field_picker
    ~field
    ~label:(if heading then "Heading" else "Font")
    ~content_class:"max-h-96"
    ~value_title:(fun (env : Env.t) v ->
      if String.equal v "inherit" then font_title env.preset.font else font_title v)
    ~indicator:(fun (env : Env.t) v ->
      let name = if String.equal v "inherit" then env.preset.font else v in
      Node.div
        ~attrs:
          [ Attr.class_ indicator_class
          ; Attr.style
              (Css_gen.create
                 ~field:"font-family"
                 ~value:
                   (Option.value_map
                      (Create_config.font name)
                      ~default:"inherit"
                      ~f:Create_config.font_family))
          ]
        [ text "Aa" ])
    ~extra:
      (if List.exists Create_config.fonts ~f:(fun f -> not f.available)
       then
         [ Picker.separator ()
         ; note [ text "Fonts without an OFL licence are not bundled." ]
         ]
       else [])
    (font_groups ~heading)
    graph
    env
;;

let radius_picker graph env =
  field_picker
    ~field:Radius
    ~label:"Radius"
    ~value_title:(fun _ v ->
      List.find Create_config.radii ~f:(fun r -> String.equal r.name v)
      |> Option.value_map ~default:v ~f:(fun (r : Create_config.Radius.t) -> r.label))
    ~indicator:(fun _ _ ->
      svg_indicator
        ~class_:(indicator_class ^ " rotate-90")
        "<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 \
         24' class='text-foreground'><path fill='none' stroke='currentColor' \
         stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M4 20v-5C4 \
         8.925 8.925 4 15 4h5'/></svg>")
    (fun _ ->
      match Create_config.radii with
      | [] -> []
      | default :: others ->
        [ [ Choice.v default.name default.label ]
        ; List.map others ~f:(fun (r : Create_config.Radius.t) -> Choice.v r.name r.label)
        ])
    graph
    env
;;

let accent_svg accent =
  sprintf
    "<svg xmlns='http://www.w3.org/2000/svg' width='128' height='128' viewBox='0 0 24 24' \
     fill='none' class='size-4 text-foreground'><path d='M19 12.1294L12.9388 \
     18.207C11.1557 19.9949 10.2641 20.8889 9.16993 20.9877C8.98904 21.0041 8.80705 \
     21.0041 8.62616 20.9877C7.53195 20.8889 6.64039 19.9949 4.85726 18.207L2.83687 \
     16.1811C1.72104 15.0622 1.72104 13.2482 2.83687 12.1294M19 12.1294L10.9184 \
     4.02587M19 12.1294H2.83687M10.9184 4.02587L2.83687 12.1294M10.9184 4.02587L8.89805 \
     2' stroke='currentColor' stroke-width='2' stroke-linecap='round' \
     stroke-linejoin='round' data-accent='%s' class='fill-muted-foreground/30 \
     data-[accent=bold]:fill-foreground'></path><path d='M22 20C22 21.1046 21.1046 22 20 \
     22C18.8954 22 18 21.1046 18 20C18 18.8954 20 17 20 17C20 17 22 18.8954 22 20Z' \
     stroke='currentColor' stroke-width='2' stroke-linecap='round' \
     stroke-linejoin='round' data-accent='%s' class='fill-muted-foreground/30 \
     data-[accent=bold]:fill-foreground'></path></svg>"
    accent
    accent
;;

let accent_picker graph env =
  field_picker
    ~field:Menu_accent
    ~label:"Menu Accent"
    ~value_title:(fun _ v ->
      List.Assoc.find Create_config.menu_accents v ~equal:String.equal
      |> Option.value ~default:v)
    ~indicator:(fun _ v -> svg_indicator (accent_svg v))
    (fun env ->
      [ List.map Create_config.menu_accents ~f:(fun (value, title) ->
          Choice.v
            ~disabled:
              (String.equal value "bold"
               && Create_params.is_translucent_menu_color env.preset.menu_color)
            value
            title)
      ])
    graph
    env
;;

(* menu-picker.tsx: the menu colour as two choices, colour and surface;
   translucent menus have the subtle accent, and going back to solid restores
   the last solid one. *)
let menu_color_value ~inverted ~translucent =
  match inverted, translucent with
  | false, false -> "default"
  | false, true -> "default-translucent"
  | true, false -> "inverted"
  | true, true -> "inverted-translucent"
;;

let with_menu_color ~last_solid_accent (p : Create_preset.t) ~inverted ~translucent =
  let menu_color = menu_color_value ~inverted ~translucent in
  let menu_accent =
    if translucent
    then "subtle"
    else if Create_params.is_translucent_menu_color p.menu_color
    then last_solid_accent
    else p.menu_accent
  in
  Create_params.normalize { p with menu_color; menu_accent }
;;

let menu_picker graph (env : Env.t Bonsai.t) =
  let last_solid_accent, set_last_solid_accent = Bonsai.state "subtle" graph in
  Bonsai.Edge.on_change
    ~equal:[%equal: string * string]
    (let%arr env in
     env.preset.menu_color, env.preset.menu_accent)
    ~callback:
      (let%arr set_last_solid_accent in
       fun (color, accent) ->
         if Create_params.is_translucent_menu_color color
         then Effect.Ignore
         else set_last_solid_accent accent)
    graph;
  let picker =
    Picker.component
      ~on_open_change:
        (let%arr env in
         fun open_ -> if open_ then Effect.Ignore else Env.clear_preview env)
      (let%arr env and last_solid_accent in
       fun t ->
         let p = env.preset in
         let inverted = String.is_prefix p.menu_color ~prefix:"inverted" in
         let translucent = Create_params.is_translucent_menu_color p.menu_color in
         let group ~label ~value ~next choices =
           Picker.group
             [ Picker.label [ text label ]
             ; Picker.radio_group
                 ~value
                 ~on_value_change:(fun v -> env.set (next v))
                 ?on_item_preview:
                   (if env.is_mobile
                    then None
                    else Some (fun v -> env.preview (Some (next v))))
                 (List.map choices ~f:(fun (value, title, disabled) ->
                    Picker.radio_item
                      ~attrs:[ Attr.create "data-value" value ]
                      ~disabled
                      ~close_on_select:env.is_mobile
                      ~value
                      [ text title ]))
             ]
         in
         [ Picker.trigger
             ~attrs:[ Attr.create "data-picker" "menuColor" ]
             t
             (trigger_body
                ~label:"Menu"
                ~value:
                  (List.Assoc.find
                     Create_config.menu_colors
                     p.menu_color
                     ~equal:String.equal
                   |> Option.value ~default:p.menu_color)
                (Node.div
                   ~attrs:[ Attr.class_ indicator_class ]
                   [ Loon.Icon.view ~class_:"size-4" Menu ]))
         ; content
             env
             t
             [ group
                 ~label:"Color"
                 ~value:(if inverted then "inverted" else "default")
                 ~next:(fun v ->
                   with_menu_color
                     ~last_solid_accent
                     p
                     ~inverted:(String.equal v "inverted")
                     ~translucent)
                 [ "default", "Default", false
                 ; "inverted", "Inverted", Mode.equal env.mode Dark
                 ]
             ; Picker.separator ()
             ; group
                 ~label:"Appearance"
                 ~value:(if translucent then "translucent" else "solid")
                 ~next:(fun v ->
                   with_menu_color
                     ~last_solid_accent
                     p
                     ~inverted
                     ~translucent:(String.equal v "translucent"))
                 [ "solid", "Solid", false; "translucent", "Translucent", false ]
             ]
         ])
      graph
  in
  let%arr picker and env in
  Node.div
    ~attrs:[ Attr.class_ "group/picker relative" ]
    [ picker; lock_button env Menu_color ]
;;

(* {1 The menu and buttons} *)

module Actions = struct
  type t =
    { shuffle : unit Effect.t
    ; reset : unit Effect.t (* asks first *)
    ; toggle_mode : unit Effect.t
    ; open_preset : unit Effect.t
    ; undo : unit Effect.t option
    ; redo : unit Effect.t option
    }
end

let main_menu graph (actions : Actions.t Bonsai.t) =
  Picker.component
    (let%arr actions in
     fun t ->
       let mac = Browser.in_browser () && Browser.is_mac () in
       let item ?(disabled = false) ~on_select label shortcut =
         Picker.item
           ~attrs:[ Attr.create "data-action" label ]
           ~disabled
           ~on_select
           [ text label; Picker.shortcut [ text shortcut ] ]
       in
       let optional = Option.value ~default:Effect.Ignore in
       [ Picker.trigger
           ~attrs:[ Attr.create "data-picker" "menu" ]
           ~class_:
             "flex items-center justify-between gap-2 rounded-lg px-1.75 ring-1 \
              ring-foreground/10 focus-visible:ring-1"
           t
           [ Node.span ~attrs:[ Attr.class_ "font-medium" ] [ text "Menu" ]
           ; Loon.Icon.view ~class_:"size-5" Menu
           ]
       ; Picker.content
           ~side:Right
           ~align:Start
           ~align_offset:(-8.)
           t
           [ Picker.group
               [ item ~on_select:actions.open_preset "Open Preset..." "O"
               ; item ~on_select:actions.shuffle "Shuffle" "R"
               ; item ~on_select:actions.toggle_mode "Light/Dark" "D"
               ]
           ; Picker.separator ()
           ; Picker.group
               [ item
                   ~disabled:(Option.is_none actions.undo)
                   ~on_select:(optional actions.undo)
                   "Undo"
                   (if mac then "⌘Z" else "Ctrl+Z")
               ; item
                   ~disabled:(Option.is_none actions.redo)
                   ~on_select:(optional actions.redo)
                   "Redo"
                   (if mac then "⇧⌘Z" else "Ctrl+Shift+Z")
               ; Picker.separator ()
               ; item ~on_select:actions.reset "Reset" "⇧R"
               ]
           ]
       ])
    graph
;;

let footer_button_class =
  "touch-manipulation bg-transparent! px-2! py-0! text-sm! transition-none select-none \
   hover:bg-muted! pointer-coarse:h-10!"
;;

let copy_text code = "--preset " ^ code

let write_clipboard text =
  Effect.of_thunk (fun () ->
    if Browser.in_browser () then Code_block.write_clipboard text)
;;

let copy_preset graph (code : string Bonsai.t) =
  let copied, set_copied = Bonsai.state false graph in
  let sleep = Bonsai.Clock.sleep graph in
  let%arr code and copied and set_copied and sleep in
  let label = if copied then "Copied" else copy_text code in
  Ui.button
    ~variant:Outline
    ~attrs:[ Attr.title label; Attr.create "data-action" "copy-preset" ]
    ~class_:(footer_button_class ^ " min-w-0 flex-1 md:flex-none")
    ~on_click:
      (Effect.Many
         [ write_clipboard (copy_text code)
         ; set_copied true
         ; (let%bind.Effect () = sleep (Time_ns.Span.of_sec 2.) in
            set_copied false)
         ])
    [ Node.span ~attrs:[ Attr.class_ "block min-w-0 truncate" ] [ text label ] ]
;;

(* {1 Dialogs} *)

let preset_example = "b2D0wqNxT"

let open_preset_dialog graph ~open_ ~set_open (env : Env.t Bonsai.t) =
  let input, set_input = Bonsai.state "" graph in
  let%arr open_ and set_open and input and set_input and env in
  let next = Option.bind (Create_preset.parse_input input) ~f:Create_preset.decode in
  let invalid = (not (String.is_empty (String.strip input))) && Option.is_none next in
  let on_open_change o =
    if o then set_open true else Effect.Many [ set_open false; set_input "" ]
  in
  let submit =
    match next with
    | None -> Effect.Ignore
    | Some p -> Effect.Many [ env.set p; on_open_change false ]
  in
  Loon.Dialog.view ~open_ ~on_open_change (fun d ->
    [ Loon.Dialog.content
        ~class_:(Ui.dialog_content_class ^ " dark")
        ~initial_focus:"#preset-code"
        d
        [ Node.create
            "form"
            ~attrs:
              [ Attr.on_submit (fun ev ->
                  Effect.Many [ Loon.Dom_util.prevent_default ev; submit ])
              ]
            [ Loon.Dialog.header
                ~class_:"gap-2"
                [ Loon.Dialog.title ~class_:Ui.dialog_title_class d [ text "Open Preset" ]
                ; Loon.Dialog.description
                    d
                    [ text "Paste a preset code to load a saved configuration." ]
                ]
            ; div
                "py-4"
                [ Node.div
                    ~attrs:
                      ([ Attr.create "data-slot" "field"
                       ; Attr.class_ "group/field flex w-full flex-col gap-2"
                       ]
                       @ if invalid then [ Attr.create "data-invalid" "true" ] else [])
                    [ Node.label
                        ~attrs:[ Attr.for_ "preset-code"; Attr.class_ "sr-only" ]
                        [ text "Preset code" ]
                    ; Node.input
                        ~attrs:
                          [ Attr.id "preset-code"
                          ; Attr.create "data-slot" "input"
                          ; Attr.string_property "value" input
                          ; Attr.placeholder
                              (sprintf "%s or --preset %s" preset_example preset_example)
                          ; Attr.create "autocapitalize" "none"
                          ; Attr.create "autocorrect" "off"
                          ; Attr.create "spellcheck" "false"
                          ; Attr.create "aria-invalid" (Bool.to_string invalid)
                          ; Attr.class_ (Loon.Cn.cn [ Ui.input_class; "h-10 w-full md:h-8" ])
                          ; Attr.on_input (fun _ s -> set_input s)
                          ]
                        ()
                    ]
                ]
            ; Node.div
                ~attrs:
                  [ Attr.create "data-slot" "dialog-footer"
                  ; Attr.class_
                      (Loon.Cn.cn
                         [ "flex flex-col-reverse gap-2 sm:flex-row sm:justify-end"
                         ; Ui.dialog_footer_class
                         ])
                  ]
                [ Ui.button
                    ~variant:Outline
                    ~on_click:(on_open_change false)
                    [ text "Cancel" ]
                ; Node.button
                    ~attrs:
                      ([ Attr.type_ "submit"
                       ; Attr.create "data-slot" "button"
                       ; Attr.create "data-action" "open"
                       ; Attr.class_ (Ui.button_classes ())
                       ]
                       @ if Option.is_none next then [ Attr.disabled ] else [])
                    [ text "Open" ]
                ]
            ]
        ]
    ])
;;

let reset_dialog ~open_ ~set_open ~confirm =
  let%arr open_ and set_open and confirm in
  Loon.Alert_dialog.view ~open_ ~on_open_change:set_open (fun d ->
    [ Loon.Alert_dialog.content
        ~size:Sm
        ~class_:"dark"
        d
        [ Loon.Alert_dialog.header
            [ Loon.Alert_dialog.title d [ text "Reset to defaults?" ]
            ; Loon.Alert_dialog.description
                d
                [ text
                    "This will reset all customization options to their default values."
                ]
            ]
        ; Loon.Alert_dialog.footer
            [ Loon.Alert_dialog.cancel d [ text "Cancel" ]
            ; Loon.Alert_dialog.action
                ~attrs:[ Attr.create "data-action" "confirm-reset" ]
                ~on_click:confirm
                d
                [ text "Reset" ]
            ]
        ]
    ])
;;

module Tab = struct
  type t =
    | Project
    | Theme
  [@@deriving equal]
end

let init_command = "loon init -dir lib/ui"

let code_panel ~name ~copied ~on_copy body =
  Node.div
    ~attrs:
      [ Attr.class_ "w-full min-w-0 overflow-hidden rounded-xl border-0 ring-1 ring-border"
      ]
    [ div
        "flex items-center gap-2 py-1 pr-1.5 pl-3"
        [ div "min-w-0 truncate font-mono text-sm text-muted-foreground" [ text name ]
        ; Ui.button
            ~size:Icon_sm
            ~variant:Ghost
            ~class_:"ml-auto"
            ~attrs:[ Attr.create "data-copy" name ]
            ~on_click:on_copy
            [ Loon.Icon.view (if copied then Check else Copy)
            ; Node.span ~attrs:[ Attr.class_ "sr-only" ] [ text ("Copy " ^ name) ]
            ]
        ]
    ; body
    ]
;;

let get_code_dialog graph (preset : Create_preset.t Bonsai.t) =
  let open_, set_open = Bonsai.state false graph in
  let tab, set_tab = Bonsai.state Tab.Project graph in
  let copied, set_copied = Bonsai.state_opt graph in
  let sleep = Bonsai.Clock.sleep graph in
  let%arr open_ and set_open and tab and set_tab and copied and set_copied and sleep
  and preset in
  let css = Create_theme_css.css preset in
  let copy target text =
    Effect.Many
      [ write_clipboard text
      ; set_copied (Some target)
      ; (let%bind.Effect () = sleep (Time_ns.Span.of_sec 2.) in
         set_copied None)
      ]
  in
  let is_copied target = Option.equal String.equal copied (Some target) in
  let tab_button t label =
    let pressed = Tab.equal tab t in
    Node.button
      ~attrs:
        [ Attr.type_ "button"
        ; Attr.create "data-slot" "toggle-group-item"
        ; Attr.create "data-tab" label
        ; Attr.create "aria-pressed" (Bool.to_string pressed)
        ; Attr.create "data-state" (if pressed then "on" else "off")
        ; Attr.class_
            "inline-flex items-center justify-center hover:text-foreground \
             aria-pressed:bg-muted focus-visible:border-ring focus-visible:ring-ring/50 \
             data-[state=on]:bg-neutral-700/70 gap-1 rounded-lg text-sm font-medium \
             transition-all h-8 min-w-8 px-2.5 outline-none focus-visible:ring-3"
        ; Attr.on_click (fun _ -> set_tab t)
        ]
      [ text label ]
  in
  let pre body =
    div
      "relative no-scrollbar max-h-[45svh] overflow-auto border-t bg-popover p-3"
      [ Node.pre
          ~attrs:[ Attr.class_ "min-w-max font-mono text-xs leading-normal whitespace-pre" ]
          [ Node.code [ text body ] ]
      ]
  in
  let legend title description =
    [ div "mb-1.5 text-sm font-medium" [ text title ]
    ; Node.p
        ~attrs:[ Attr.class_ "text-muted-foreground -mt-1.5 text-left text-sm" ]
        description
    ]
  in
  let code s = Node.code ~attrs:[ Attr.class_ "font-mono text-foreground" ] [ text s ] in
  let body, footer =
    match tab with
    | Project ->
      ( Ui.field_group
          ~class_:"px-6 py-4"
          [ div
              "flex flex-col gap-3"
              (legend
                 "Command"
                 [ text "Make a directory a dune library of components, with the theme." ]
               @ [ code_panel
                     ~name:"command"
                     ~copied:(is_copied "command")
                     ~on_copy:(copy "command" init_command)
                     (pre init_command)
                 ])
          ; Ui.field_separator ~class_:"-mx-6" ()
          ; div
              "flex flex-col gap-3"
              (legend
                 "Theme"
                 [ text "Then put the Theme tab's CSS in place of "
                 ; code ":root"
                 ; text " and "
                 ; code ".dark"
                 ; text " in "
                 ; code "lib/ui/loon.css"
                 ; text ", and add components with "
                 ; code "loon add"
                 ; text "."
                 ])
          ]
      , Ui.button
          ~class_:"h-9 w-full"
          ~attrs:[ Attr.create "data-action" "copy-command" ]
          ~on_click:(copy "command" init_command)
          [ text (if is_copied "command" then "Copied" else "Copy Command") ] )
    | Theme ->
      ( Ui.field_group
          ~class_:"min-w-0 px-6 py-4"
          [ div
              "flex min-w-0 flex-col gap-3"
              (legend "Theme Tokens" [ text "Copy the CSS variables for this preset." ]
               @ [ code_panel
                     ~name:"loon.css"
                     ~copied:(is_copied "theme")
                     ~on_copy:(copy "theme" css)
                     (pre css)
                 ])
          ]
      , Ui.button
          ~class_:"h-9 w-full"
          ~attrs:[ Attr.create "data-action" "copy-theme" ]
          ~on_click:(copy "theme" css)
          [ text (if is_copied "theme" then "Copied" else "Copy Theme") ] )
  in
  Loon.Dialog.view ~open_ ~on_open_change:set_open (fun d ->
    [ Loon.Dialog.trigger
        d
        (Ui.button ~attrs:[ Attr.create "data-action" "get-code" ] [ text "Get Code" ])
    ; Loon.Dialog.content
        ~class_:
          "dark bg-popover text-popover-foreground ring-foreground/10 border-0 ring-1 \
           top-[64px] no-scrollbar flex max-h-[calc(100svh-2rem)] translate-y-0 flex-col \
           gap-0 rounded-2xl p-0 shadow-xl **:data-[slot=dialog-close]:top-4.5 \
           **:data-[slot=dialog-close]:right-4 **:data-[slot=field-separator]:h-2 \
           sm:max-w-md"
        d
        [ div
            "flex min-w-0 flex-1 flex-col gap-0 overflow-hidden rounded-2xl"
            [ Loon.Dialog.header
                ~class_:"border-b px-6 py-5"
                [ Loon.Dialog.title ~class_:"sr-only" d [ text "Get Code" ]
                ; Node.div
                    ~attrs:
                      [ Attr.role "group"
                      ; Attr.create "aria-label" "Project type"
                      ; Attr.class_ "flex items-center gap-2"
                      ]
                    [ tab_button Project "New Project"; tab_button Theme "Theme" ]
                ]
            ; div
                "no-scrollbar overflow-y-auto"
                [ body; div "m-0 flex min-w-0 p-6" [ footer ] ]
            ]
        ]
    ])
;;

(* {1 The preview} *)

let preview_switcher ~item ~set_item =
  Node.div
    ~attrs:
      [ Attr.class_
          "dark absolute right-3 bottom-3 z-20 flex items-center gap-1 rounded-xl \
           bg-card/90 p-1 shadow-xl backdrop-blur-xl"
      ]
    (List.map Create_preview.items ~f:(fun (value, label) ->
       Ui.button
         ~variant:Ghost
         ~size:Sm
         ~attrs:
           [ Attr.create "data-active" (Bool.to_string (String.equal item value))
           ; Attr.create "data-item" value
           ]
         ~class_:
           "h-7 min-w-8 cursor-pointer rounded-lg px-2.5 text-xs font-medium \
            text-muted-foreground transition-colors hover:text-foreground \
            data-[active=true]:bg-accent data-[active=true]:text-accent-foreground"
         ~on_click:(set_item value)
         [ text label ]))
;;

let preview graph ~(env : Env.t Bonsai.t) ~(shown : Create_preset.t Bonsai.t) =
  let item = Bonsai.map env ~f:(fun env -> env.params.item) in
  let block = Create_preview.component item graph in
  let%arr block and env and shown in
  Node.div
    ~attrs:
      [ Attr.class_
          "relative flex flex-1 flex-col justify-center overflow-hidden rounded-2xl ring \
           ring-foreground/10 md:ring-muted dark:ring-foreground/10"
      ]
    [ div
        "relative z-0 mx-auto flex w-full flex-1 flex-col overflow-hidden"
        [ div "absolute inset-0 bg-muted dark:bg-muted/30" []
        ; Node.create "style" [ text (Create_preview_style.css shown) ]
        ; Node.div
            ~attrs:
              (Attr.class_
                 "relative z-10 size-full flex-1 overflow-auto bg-background \
                  text-foreground"
               :: Create_preview_style.attrs ~mode:env.mode shown)
            [ block ]
        ]
    ; preview_switcher ~item:env.params.item ~set_item:env.set_item
    ]
;;

(* {1 The page} *)

let component ~mode ~set_mode ~query ~set_query (local_ graph) =
  let params = Bonsai.map query ~f:Create_params.of_query in
  let is_mobile = Loon.Use_mobile.component graph in
  let locks, set_locks = Bonsai.state Field.Set.empty graph in
  let override, set_override = Bonsai.state_opt graph in
  let history, set_history = Bonsai.state' Create_history.empty graph in
  let open_preset_open, set_open_preset_open = Bonsai.state false graph in
  let reset_open, set_reset_open = Bonsai.state false graph in
  let normal_query = Bonsai.map params ~f:Create_params.to_query in
  (* shadcn writes the preset into a URL without one (hasSyncedPresetToUrl);
     every state is recorded for undo. *)
  Bonsai.Edge.on_change
    ~equal:[%equal: string * string]
    (Bonsai.both query normal_query)
    ~callback:
      (let%arr set_query and set_history in
       fun (query, normal) ->
         let has_preset =
           List.exists (Customize_query.parse query) ~f:(fun (k, _) ->
             String.equal k "preset")
         in
         Effect.Many
           [ (if has_preset then Effect.Ignore else set_query normal)
           ; set_history (fun h -> Create_history.push h normal)
           ])
    graph;
  let env =
    let%arr params and set_query and set_override and override and locks and set_locks
    and is_mobile and mode in
    let write p = set_query (Create_params.to_query p) in
    { Env.params
    ; preset = params.preset
    ; set =
        (fun p ->
          Effect.Many
            [ set_override None; write { params with preset = Create_params.normalize p } ])
    ; set_item = (fun item -> write { params with item })
    ; preview =
        (fun p ->
          if Option.equal Create_preset.equal p override
          then Effect.Ignore
          else set_override p)
    ; locks
    ; toggle_lock =
        (fun f -> set_locks (if Set.mem locks f then Set.remove locks f else Set.add locks f))
    ; is_mobile
    ; mode
    }
  in
  let shown =
    let%arr override and params in
    Option.value override ~default:params.preset
  in
  let actions =
    let%arr env and history and set_history and set_query and mode and set_mode
    and set_open_preset_open and set_reset_open in
    let move step =
      Option.map (step history) ~f:(fun (h, q) ->
        Effect.Many [ set_history (fun _ -> h); set_query q ])
    in
    { Actions.shuffle =
        Effect.lazy_
          (lazy (env.set (Create_random.shuffle ~random ~locks:env.locks env.preset)))
    ; reset = set_reset_open true
    ; toggle_mode = set_mode (Mode.toggle mode)
    ; open_preset = set_open_preset_open true
    ; undo = move Create_history.undo
    ; redo = move Create_history.redo
    }
  in
  let confirm_reset =
    let%arr env in
    env.set Create_config.reset_preset
  in
  let menu = main_menu graph actions in
  let separator = Bonsai.return (Ui.field_separator ~class_:"hidden md:block" ()) in
  let pickers =
    Bonsai.all
      [ base_picker graph env
      ; style_picker graph env
      ; separator
      ; base_color_picker graph env
      ; theme_picker graph env
      ; chart_color_picker graph env
      ; separator
      ; font_picker ~heading:true graph env
      ; font_picker ~heading:false graph env
      ; separator
      ; icon_library_picker graph env
      ; radius_picker graph env
      ; separator
      ; menu_picker graph env
      ; accent_picker graph env
      ]
  in
  let copy = copy_preset graph (Bonsai.map params ~f:Create_params.code) in
  let open_preset =
    open_preset_dialog graph ~open_:open_preset_open ~set_open:set_open_preset_open env
  in
  let reset =
    reset_dialog ~open_:reset_open ~set_open:set_reset_open ~confirm:confirm_reset
  in
  let get_code = get_code_dialog graph (Bonsai.map params ~f:(fun p -> p.preset)) in
  let preview = preview graph ~env ~shown in
  let%arr menu and pickers and copy and open_preset and reset and get_code and preview
  and actions and set_open_preset_open and is_mobile in
  let shortcuts =
    Attr.Global_listeners.keydown ~phase:Bubbling ~f:(fun ev ->
      let open Js_of_ocaml in
      let key =
        match Loon.Dom_util.key ev with
        | KeyR -> "r"
        | KeyD -> "d"
        | KeyO -> "o"
        | KeyZ -> "z"
        | _ -> ""
      in
      let editable = Browser.in_browser () && Browser.active_element_is_editable () in
      match
        Create_shortcuts.of_key
          ~key
          ~shift:(Js.to_bool ev##.shiftKey)
          ~ctrl:(Js.to_bool ev##.ctrlKey || Js.to_bool ev##.metaKey)
          ~alt:(Js.to_bool ev##.altKey)
          ~editable
      with
      | None -> Effect.Ignore
      | Some action ->
        let run =
          match action with
          | Shuffle -> actions.shuffle
          | Reset -> actions.reset
          | Toggle_mode -> actions.toggle_mode
          | Open_preset -> actions.open_preset
          | Undo -> Option.value actions.undo ~default:Effect.Ignore
          | Redo -> Option.value actions.redo ~default:Effect.Ignore
        in
        Effect.Many [ Loon.Dom_util.prevent_default ev; run ])
  in
  let footer_button ~action ?(class_ = "") ~on_click children =
    Ui.button
      ~variant:Outline
      ~attrs:[ Attr.create "data-action" action ]
      ~class_:(footer_button_class ^ " " ^ class_)
      ~on_click
      children
  in
  let customizer =
    Ui.card
      ~attrs:[ Attr.id customizer_id ]
      ~class_:
        "dark top-24 right-12 isolate z-10 max-h-full min-h-0 w-full self-start \
         rounded-2xl bg-card/90 backdrop-blur-xl md:w-(--customizer-width)"
      [ Ui.card_header
          ~class_:"hidden items-center justify-between gap-2 border-b md:flex"
          [ menu ]
      ; Ui.card_content
          ~class_:
            "no-scrollbar min-h-0 flex-1 overflow-x-auto overflow-y-hidden \
             md:overflow-y-auto"
          [ Ui.field_group
              ~class_:
                "flex-row gap-2.5 py-px **:data-[slot=field-separator]:-mx-4 \
                 **:data-[slot=field-separator]:w-auto md:flex-col md:gap-3.25"
              pickers
          ]
      ; Ui.card_footer
          ~class_:
            "flex min-w-0 gap-2 md:flex-col md:rounded-b-none md:**:[button,a]:w-full"
          [ copy
          ; footer_button
              ~action:"open-preset"
              ~class_:"max-w-20 min-w-0 flex-1 sm:max-w-none md:flex-none"
              ~on_click:(set_open_preset_open true)
              [ text (if is_mobile then "Open" else "Open Preset") ]
          ; footer_button
              ~action:"shuffle"
              ~class_:"max-w-20 min-w-0 flex-1 sm:max-w-none md:flex-none"
              ~on_click:actions.shuffle
              [ Node.span
                  ~attrs:[ Attr.class_ "w-full truncate text-center font-medium" ]
                  [ text "Shuffle" ]
              ]
          ; footer_button
              ~action:"reset"
              ~class_:"shrink-0 md:hidden"
              ~on_click:actions.reset
              [ text "Reset" ]
          ]
      ; Ui.card_footer
          ~class_:"-mt-3 flex min-w-0 gap-2 md:flex-col md:**:[button,a]:w-full"
          [ get_code ]
      ]
  in
  Node.div
    ~attrs:
      [ Attr.create "data-tool" "create"
      ; shortcuts
      ; Attr.class_
          "relative z-10 flex h-[calc(100svh-var(--docs-header,3.5rem))] min-h-0 flex-1 \
           flex-col overflow-hidden bg-linear-to-b from-background to-muted/40 \
           dark:bg-none dark:bg-background [--customizer-width:--spacing(48)] \
           [--gap:--spacing(4)] md:[--gap:--spacing(6)] \
           2xl:[--customizer-width:--spacing(56)]"
      ]
    [ Customize_fonts.style
    ; Node.div
        ~attrs:
          [ Attr.create "data-slot" "designer"
          ; Attr.class_
              "flex min-h-0 flex-1 flex-col gap-(--gap) p-(--gap) \
               pt-[calc(var(--gap)*0.25)] md:flex-row-reverse"
          ]
        [ preview; customizer ]
    ; open_preset
    ; reset
    ]
;;
