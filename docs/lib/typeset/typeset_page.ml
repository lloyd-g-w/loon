open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Js_of_ocaml
module Node = Vdom.Node
module Attr = Vdom.Attr
module Params = Typeset_params
module Key = Params.Key
module Picker = Customize_picker
module Nova = Typeset_nova

let data name value = Attr.create ("data-" ^ name) value

(* As an attribute: [Attr.style] sets properties one by one, which drops
   custom properties. *)
let style css = Attr.create "style" (Css_gen.to_string_css css)
let customizer_id = "typeset-customizer"

(* {1 State} *)

module History = struct
  (* use-history.tsx: every committed change is an entry; undo and redo
     restore one. *)
  type t =
    { past : Params.t list
    ; future : Params.t list
    }
  [@@deriving sexp_of, equal]

  let empty = { past = []; future = [] }
end

(* What the parts of the page share. *)
type ctx =
  { params : Params.t
  ; commit : Params.t -> unit Effect.t
  ; locks : Key.t list
  ; toggle_lock : Key.t -> unit Effect.t
  ; set_override : (Key.t * string) list -> unit Effect.t
  ; clear_override : unit Effect.t
  ; is_mobile : bool
  ; shuffle : unit Effect.t
  ; reset : unit Effect.t
  ; undo : unit Effect.t
  ; redo : unit Effect.t
  ; can_undo : bool
  ; can_redo : bool
  ; toggle_theme : unit Effect.t
  }

let is_locked ctx key = List.mem ctx.locks key ~equal:Key.equal

let random_state =
  lazy
    (if Browser.in_browser ()
     then Random.State.make_self_init ()
     else Random.State.make [| 0 |])
;;

(* use-shuffle.tsx: random fonts, size, measure and rhythm; the item and
   the locked params stay. Only the bundled fonts are drawn. *)
let shuffled (params : Params.t) ~locks =
  let state = Lazy.force random_state in
  let pick l = List.nth_exn l (Random.State.int state (List.length l)) in
  let ids kinds =
    List.filter_map Typeset_fonts.all ~f:(fun (f : Typeset_fonts.t) ->
      if f.available && kinds f.kind then Some f.name else None)
  in
  let body_fonts = ids (fun k -> not (Customize_fonts.Kind.equal k Mono)) in
  let mono_fonts = ids (Customize_fonts.Kind.equal Mono) in
  let values l = List.map l ~f:(fun (o : Params.Option_.t) -> o.value) in
  let next =
    [ Key.Body, pick body_fonts
    ; Heading, pick ("inherit" :: body_fonts)
    ; Mono, pick mono_fonts
    ; Scale, pick (values Params.sizes)
    ; Measure, pick (values (List.map Params.measures ~f:fst))
    ; Leading, pick (values Params.leadings)
    ; Flow, pick (values Params.flows)
    ]
  in
  Params.apply
    params
    (List.filter next ~f:(fun (k, _) -> not (List.mem locks k ~equal:Key.equal)))
;;

(* {1 The customiser} *)

let lock_button ctx key =
  let locked = is_locked ctx key in
  let label = if locked then "Unlock" else "Lock" in
  Node.button
    ~attrs:
      [ Attr.type_ "button"
      ; Attr.title label
      ; Attr.create "aria-label" label
      ; data "locked" (Bool.to_string locked)
      ; Attr.on_click (fun _ -> ctx.toggle_lock key)
      ; Attr.class_
          "flex size-4 cursor-pointer items-center justify-center rounded opacity-0 \
           ring-foreground/60 transition-opacity outline-none \
           group-focus-within/picker:opacity-100 group-hover/picker:opacity-100 \
           focus:opacity-100 focus-visible:ring-1 data-[locked=true]:opacity-100 \
           max-md:hidden pointer-coarse:hidden absolute top-1/2 right-8 -translate-y-1/2"
      ]
    [ Loon.Icon.view ~class_:"size-5 text-foreground" (if locked then Lock else Lock_open)
    ]
;;

(* customizer.tsx's LineHeightIcon. *)
let line_height_icon =
  let path d =
    Node.create_svg
      "path"
      ~attrs:
        [ Attr.create "d" d
        ; Attr.create "stroke" "currentColor"
        ; Attr.create "stroke-linecap" "round"
        ; Attr.create "stroke-width" "1.5"
        ]
      []
  in
  Node.create_svg
    "svg"
    ~attrs:
      [ Attr.create "width" "24"
      ; Attr.create "height" "24"
      ; Attr.create "viewBox" "0 0 24 24"
      ; Attr.create "fill" "none"
      ; Attr.create "class" "size-4.5"
      ]
    [ path "M4.5 3.5H19.5"
    ; path "M4.5 20.5H19.5"
    ; path
        "M17 17L14.8905 11.4741C13.9109 8.90801 13.4211 7.625 12.625 7.625C11.8289 \
         7.625 11.3391 8.90801 10.3595 11.4741L8.25 17"
    ; path "M9.5 13H15.75"
    ]
;;

(* Names the parts, for tests and scripts. *)
let param_attr key = data "param" (Key.name key)
let action_attr name = data "action" name

let lucide icon = Loon.Icon.view ~class_:"size-4.5" icon

let picker_content ?class_ ctx picker items =
  Picker.content
    ?class_
    ~attrs:[ Attr.on_mouseleave (fun _ -> ctx.clear_override) ]
    ?anchor:(if ctx.is_mobile then Some customizer_id else None)
    ~side:(if ctx.is_mobile then Top else Right)
    ~align:(if ctx.is_mobile then Center else Start)
    picker
    items
;;

(* Hover previews, on desktop only. *)
let preview_handler ctx key =
  if ctx.is_mobile
  then None
  else
    Some
      (fun v ->
        match Params.coerce key v with
        | Some v -> ctx.set_override [ key, v ]
        | None -> Effect.Ignore)
;;

let set_param ctx key v =
  match Params.coerce key v with
  | Some v -> ctx.commit (Params.set ctx.params key v)
  | None -> Effect.Ignore
;;

let clear_on_close ctx =
  Bonsai.map ctx ~f:(fun ctx open_ -> if open_ then Effect.Ignore else ctx.clear_override)
;;

let trigger_label ~label ~value_class value =
  Node.div
    ~attrs:[ Attr.class_ "text-xs text-muted-foreground" ]
    [ Node.text label ]
  :: [ Node.div ~attrs:[ Attr.class_ value_class ] [ Node.text value ] ]
;;

(* option-picker.tsx *)
let option_picker ?(class_ = "") ~label ~key ~icon ~options ctx (local_ graph) =
  let picker =
    Picker.component
      ~on_open_change:(clear_on_close ctx)
      (let%arr ctx in
       fun picker ->
         let value = Params.get ctx.params key in
         let current =
           List.find options ~f:(fun (o : Params.Option_.t) -> String.equal o.value value)
         in
         [ Picker.trigger
             picker
             [ Node.div
                 ~attrs:[ Attr.class_ "flex min-w-0 flex-col justify-start pr-8 text-left" ]
                 (trigger_label
                    ~label
                    ~value_class:"line-clamp-1 text-sm font-medium text-foreground"
                    (Option.value_map current ~default:"" ~f:(fun o -> o.label)))
             ; Node.div
                 ~attrs:
                   [ Attr.class_
                       "pointer-events-none absolute top-1/2 right-4 flex size-4 \
                        -translate-y-1/2 items-center justify-center text-foreground \
                        select-none md:right-2.5"
                   ]
                 [ icon ]
             ]
         ; picker_content
             ctx
             picker
             [ Picker.radio_group
                 ?on_item_preview:(preview_handler ctx key)
                 ~value
                 ~on_value_change:(set_param ctx key)
                 (List.map options ~f:(fun (o : Params.Option_.t) ->
                    Picker.radio_item
                      ~attrs:[ data "value" o.value ]
                      ~value:o.value
                      [ Node.text o.label ]))
             ]
         ])
      graph
  in
  let%arr picker and ctx in
  Node.div
    ~attrs:[ Loon.Cn.attr [ "group/picker relative"; class_ ]; param_attr key ]
    [ picker; lock_button ctx key ]
;;

(* font-picker.tsx: every font in each picker, grouped by kind; those not
   bundled are disabled. *)
let font_picker ~label ~key ctx (local_ graph) =
  let picker =
    Picker.component
      ~on_open_change:(clear_on_close ctx)
      (let%arr ctx in
       fun picker ->
         let value = Params.get ctx.params key in
         let body_font =
           match Typeset_fonts.find ctx.params.body with
           | Some f -> f
           | None -> List.hd_exn Typeset_fonts.all
         in
         let current =
           if Key.equal key Heading && String.equal value "inherit"
           then body_font
           else Option.value (Typeset_fonts.find value) ~default:body_font
         in
         let radio_group items =
           Picker.radio_group
             ?on_item_preview:(preview_handler ctx key)
             ~value
             ~on_value_change:(set_param ctx key)
             items
         in
         let font_item (f : Typeset_fonts.t) =
           Picker.radio_item
             ~attrs:[ data "value" f.name ]
             ~disabled:(not f.available)
             ~value:f.name
             (Node.span ~attrs:[ Attr.class_ "whitespace-nowrap" ] [ Node.text f.title ]
              ::
              (if f.available
               then []
               else
                 [ Node.span
                     ~attrs:[ Attr.class_ "ml-auto pl-2 text-xs whitespace-nowrap text-neutral-400!" ]
                     [ Node.text "Not bundled" ]
                 ]))
         in
         let kind_group label kind =
           Picker.group
             [ Picker.label [ Node.text label ]
             ; radio_group
                 (List.filter_map Typeset_fonts.all ~f:(fun (f : Typeset_fonts.t) ->
                    if Customize_fonts.Kind.equal f.kind kind then Some (font_item f) else None))
             ]
         in
         (* Base UI's radio group may hold labels and separators; loon's
            holds items, so each section has a group of its own. *)
         let sections =
           (if Key.equal key Heading
            then
              [ Picker.group
                  [ radio_group
                      [ Picker.radio_item
                        ~attrs:[ data "value" "inherit" ]
                        ~value:"inherit"
                        [ Node.text body_font.title ] ]
                  ]
              ; Picker.separator ()
              ]
            else [])
           @ [ kind_group "Sans" Sans; kind_group "Serif" Serif; kind_group "Mono" Mono ]
         in
         [ Picker.trigger
             picker
             [ Node.div
                 ~attrs:[ Attr.class_ "flex flex-col justify-start text-left" ]
                 (trigger_label
                    ~label
                    ~value_class:
                      "line-clamp-1 max-w-[80%] truncate text-sm font-medium \
                       text-foreground"
                    current.title)
             ; Node.div
                 ~attrs:
                   [ Attr.class_
                       "pointer-events-none absolute top-1/2 right-4 flex size-4 \
                        -translate-y-1/2 items-center justify-center text-base \
                        text-foreground select-none md:right-2.5"
                   ; style
                       (Css_gen.create ~field:"font-family" ~value:(Typeset_fonts.value current))
                   ]
                 [ Node.text "Aa" ]
             ]
         ; picker_content ~class_:"max-h-96" ctx picker sections
         ])
      graph
  in
  let%arr picker and ctx in
  Node.div
    ~attrs:[ Attr.class_ "group/picker relative"; param_attr key ]
    [ picker; lock_button ctx key ]
;;

let shortcut text = Picker.shortcut [ Node.text text ]

(* main-menu.tsx *)
let main_menu ctx (local_ graph) =
  Picker.component
    (let%arr ctx in
     fun picker ->
       let mac = Browser.in_browser () && Browser.is_mac () in
       [ Picker.trigger
           ~class_:
             "flex items-center justify-between gap-2 rounded-lg px-1.75 ring-1 \
              ring-foreground/10 focus-visible:ring-1"
           picker
           [ Node.span ~attrs:[ Attr.class_ "font-medium" ] [ Node.text "Menu" ]
           ; Loon.Icon.view ~class_:"size-5" Menu
           ]
       ; Picker.content
           ~side:Right
           ~align:Start
           ~align_offset:(-8.)
           picker
           [ Picker.group
               [ Picker.item ~attrs:[ action_attr "shuffle" ] ~on_select:ctx.shuffle [ Node.text "Shuffle "; shortcut "R" ]
               ; Picker.item
                   ~attrs:[ action_attr "theme" ]
                   ~on_select:ctx.toggle_theme
                   [ Node.text "Light/Dark "; shortcut "D" ]
               ]
           ; Picker.separator ()
           ; Picker.group
               [ Picker.item
                   ~attrs:[ action_attr "undo" ]
                   ~disabled:(not ctx.can_undo)
                   ~on_select:ctx.undo
                   [ Node.text "Undo "; shortcut (if mac then "⌘Z" else "Ctrl+Z") ]
               ; Picker.item
                   ~attrs:[ action_attr "redo" ]
                   ~disabled:(not ctx.can_redo)
                   ~on_select:ctx.redo
                   [ Node.text "Redo "; shortcut (if mac then "⇧⌘Z" else "Ctrl+Shift+Z") ]
               ; Picker.separator ()
               ; Picker.item ~attrs:[ action_attr "reset" ] ~on_select:ctx.reset [ Node.text "Reset "; shortcut "⇧R" ]
               ]
           ]
       ])
    graph
;;

let footer_button_class =
  "touch-manipulation bg-transparent! px-2! py-0! text-sm! transition-none select-none \
   hover:bg-muted! pointer-coarse:h-10!"
;;

let nova_button ?(attrs = []) ?on_click ~class_ children =
  Node.button
    ~attrs:
      ([ Attr.type_ "button"
       ; data "slot" "button"
       ; Attr.class_ (Nova.Button.classes ~class_ Outline Default)
       ]
       @ Option.value_map on_click ~default:[] ~f:(fun e -> [ Attr.on_click (fun _ -> e) ])
       @ attrs)
    children
;;

(* get-code-drawer.tsx: the trigger, in the card's footer, and the drawer,
   which the page draws outside the card (shadcn's is in a portal: it is
   not [dark], and the footer's [**:[button]:w-full] misses it). *)
let get_code_drawer ctx (local_ graph) =
  let open_, set_open = Bonsai.state false graph in
  let content = Typeset_docs.content (Bonsai.map ctx ~f:(fun ctx -> ctx.params)) graph in
  let%arr open_ and set_open and content and ctx in
  let drawer f =
    Loon.Drawer.view
      ~id:"typeset-get-code"
      ~direction:(if ctx.is_mobile then Bottom else Right)
      ~open_
      ~on_open_change:set_open
      (fun drawer -> [ f drawer ])
  in
  let trigger =
    drawer (fun drawer ->
      Loon.Drawer.trigger
        drawer
        (nova_button
           ~class_:("min-w-0 flex-1 md:flex-none xl:hidden " ^ footer_button_class)
           [ Node.text "Get Code" ]))
  in
  let content =
    drawer (fun drawer ->
      Loon.Drawer.content
        ~attrs:[ data "mobile" (Bool.to_string ctx.is_mobile) ]
        ~class_:
          "bg-popover text-sm text-popover-foreground \
           data-[vaul-drawer-direction=bottom]:rounded-t-xl \
           data-[vaul-drawer-direction=right]:rounded-l-xl \
           data-[vaul-drawer-direction=right]:sm:max-w-96 data-[mobile=true]:max-h-[85svh]"
        drawer
        [ Loon.Drawer.header
            ~class_:
              "gap-0.5 p-4 pb-0 group-data-[vaul-drawer-direction=bottom]/drawer-content:text-center \
               md:gap-0.5 md:text-left"
            [ Loon.Drawer.title
                ~class_:"text-base font-medium text-foreground"
                drawer
                [ Node.text "Get Code" ]
            ; Loon.Drawer.description
                ~class_:"text-sm text-balance text-muted-foreground"
                drawer
                [ Node.text "Install typeset with the values you picked." ]
            ]
        ; content
        ; Loon.Drawer.footer
            ~class_:"mt-auto flex shrink-0 flex-col gap-2 p-4 pt-0"
            [ Loon.Drawer.close drawer (nova_button ~class_:"" [ Node.text "Done" ]) ]
        ])
  in
  trigger, content
;;

(* customizer.tsx *)
let customizer ctx (local_ graph) =
  let option ?class_ ~label ~key ~icon ~options () =
    option_picker ?class_ ~label ~key ~icon ~options ctx graph
  in
  let measure =
    option
      ~class_:"max-[28rem]:hidden"
      ~label:"Measure"
      ~key:Measure
      ~icon:(lucide Move_horizontal)
      ~options:(List.map Params.measures ~f:fst)
      ()
  in
  let heading = font_picker ~label:"Heading" ~key:Heading ctx graph in
  let body = font_picker ~label:"Body" ~key:Body ctx graph in
  let mono = font_picker ~label:"Mono" ~key:Mono ctx graph in
  let size =
    option ~label:"Size" ~key:Scale ~icon:(lucide A_large_small) ~options:Params.sizes ()
  in
  let leading =
    option ~label:"Leading" ~key:Leading ~icon:line_height_icon ~options:Params.leadings ()
  in
  let flow = option ~label:"Flow" ~key:Flow ~icon:(lucide Pilcrow) ~options:Params.flows () in
  let menu = main_menu ctx graph in
  let get_code = get_code_drawer ctx graph in
  let%arr measure
  and heading
  and body
  and mono
  and size
  and leading
  and flow
  and menu
  and get_code
  and ctx in
  let separator =
    Node.div
      ~attrs:
        [ data "slot" "field-separator"
        ; Loon.Cn.attr [ Nova.field_separator; "hidden md:block" ]
        ]
      [ Loon.Separator.view ~class_:"absolute inset-0 top-1/2" () ]
  in
  ( Node.div
    ~attrs:
      [ Attr.id customizer_id
      ; data "slot" "card"
      ; data "size" "sm"
      ; Loon.Cn.attr
          [ Nova.card
          ; "dark isolate z-10 max-h-full min-h-0 w-full self-start rounded-2xl \
             bg-card/90 backdrop-blur-xl md:w-(--customizer-width)"
          ]
      ]
    [ Node.div
        ~attrs:
          [ data "slot" "card-header"
          ; Loon.Cn.attr
              [ Nova.card_header
              ; "hidden items-center justify-between gap-2 border-b md:flex"
              ]
          ]
        [ menu ]
    ; Node.div
        ~attrs:
          [ data "slot" "card-content"
          ; Loon.Cn.attr
              [ Nova.card_content
              ; "no-scrollbar min-h-0 flex-1 overflow-x-auto overflow-y-hidden \
                 max-md:px-0 md:overflow-y-auto"
              ]
          ]
        [ Node.div
            ~attrs:
              [ data "slot" "field-group"
              ; Loon.Cn.attr
                  [ Nova.field_group
                  ; "flex-row gap-2.5 py-px **:data-[slot=field-separator]:-mx-4 \
                     **:data-[slot=field-separator]:w-auto max-md:px-3 md:flex-col \
                     md:gap-3.25"
                  ]
              ]
            [ measure
            ; separator
            ; heading
            ; body
            ; mono
            ; separator
            ; size
            ; leading
            ; flow
            ; Node.div
                ~attrs:
                  [ Attr.create "aria-hidden" "true"; Attr.class_ "w-0.5 shrink-0 md:hidden" ]
                []
            ]
        ]
    ; Node.div
        ~attrs:
          [ data "slot" "card-footer"
          ; Loon.Cn.attr
              [ Nova.card_footer
              ; "flex min-w-0 flex-row-reverse gap-2 border-t md:flex-col \
                 md:**:[button]:w-full"
              ]
          ]
        [ nova_button
            ~attrs:[ action_attr "shuffle" ]
            ~on_click:ctx.shuffle
            ~class_:(footer_button_class ^ " min-w-0 flex-1 md:flex-none")
            [ Node.span
                ~attrs:[ Attr.class_ "w-full truncate text-center font-medium" ]
                [ Node.text "Shuffle" ]
            ]
        ; fst get_code
        ]
    ]
  , snd get_code )
;;

(* {1 The preview} *)

let preview_only_hash (p : Params.t) =
  Customize_query.to_hash
    ~slug:"typeset"
    (Customize_query.to_string
       (Customize_query.parse (Params.to_query p) @ [ "view", "preview" ]))
;;

(* toolbar.tsx *)
let toolbar ctx (local_ graph) =
  let pills =
    List.mapi Params.content_options ~f:(fun i (o : Params.Option_.t) ->
      Loon.Tooltip.component
        (let%arr ctx in
         fun tooltip ->
           [ Loon.Tooltip.trigger
               tooltip
               (Loon.Button.view
                  ~variant:Ghost
                  ~size:Sm
                  ~attrs:
                    [ data "item" o.value
                    ; data "active" (Bool.to_string (String.equal ctx.params.item o.value))
                    ]
                  ~class_:
                    "h-7 min-w-7 cursor-pointer rounded-lg px-2 text-xs font-medium \
                     text-muted-foreground transition-colors hover:text-foreground \
                     data-[active=true]:bg-accent data-[active=true]:text-accent-foreground"
                  ~on_click:(ctx.commit { ctx.params with item = o.value })
                  [ Node.text (sprintf "%02d" (i + 1)) ])
           ; Loon.Tooltip.content ~side:Top ~side_offset:10. tooltip [ Node.text o.label ]
           ])
        graph)
    |> Bonsai.all
  in
  let%arr pills and ctx in
  let bar =
    "dark flex items-center gap-1 rounded-xl bg-card/90 p-1 shadow-xl backdrop-blur-xl"
  in
  Node.div
    ~attrs:
      [ Attr.class_
          "absolute bottom-3 left-1/2 z-20 flex -translate-x-1/2 items-center \
           justify-center gap-1.5"
      ]
    [ Node.div ~attrs:[ Attr.class_ bar ] pills
    ; Node.div
        ~attrs:[ Attr.class_ bar ]
        [ Loon.Button.link
            ~variant:Ghost
            ~size:Sm
            ~class_:
              "h-7 cursor-pointer rounded-lg px-2.5 text-xs font-medium \
               text-muted-foreground transition-colors hover:text-foreground"
            ~attrs:[ Attr.target "_blank"; Attr.create "rel" "noreferrer" ]
            ~href:(preview_only_hash ctx.params)
            [ Loon.Icon.view ~class_:"size-3.5 md:hidden" External_link
            ; Node.span
                ~attrs:[ Attr.class_ "max-md:sr-only" ]
                [ Node.text "Open in New Tab" ]
            ]
        ]
    ]
;;

(* preview-provider.tsx's variables, set on the preview's root. *)
let preview_style (p : Params.t) =
  let body = Option.map (Typeset_fonts.find p.body) ~f:Typeset_fonts.value in
  let heading =
    if String.equal p.heading "inherit"
    then body
    else Option.map (Typeset_fonts.find p.heading) ~f:Typeset_fonts.value
  in
  [ "--preview-size", Some (p.scale ^ "px")
  ; "--preview-leading", Some p.leading
  ; "--preview-flow", Some p.flow
  ; "--preview-measure", Params.measure_width p.measure
  ; "--preview-font", body
  ; "--preview-font-heading", heading
  ; "--preview-font-mono", Option.map (Typeset_fonts.find p.mono) ~f:Typeset_fonts.value
  ]
  |> List.filter_map ~f:(fun (field, value) ->
    Option.map value ~f:(fun value -> Css_gen.create ~field ~value))
  |> Css_gen.concat
;;

let default_font id =
  Option.value_map (Typeset_fonts.find id) ~default:"" ~f:Typeset_fonts.value
;;

(* Links in the documents: #anchors scroll the preview (the hash is the
   docs' route), web links open in a new tab, others do nothing (shadcn's
   preview is an iframe, which they would navigate). *)
let on_preview_click (ev : Dom_html.mouseEvent Js.t) =
  let link : Dom_html.element Js.t Js.opt =
    Js.Opt.bind ev##.target (fun t ->
      Js.Unsafe.meth_call t "closest" [| Js.Unsafe.inject (Js.string "a[href]") |])
  in
  match Js.Opt.to_option link with
  | None -> Effect.Ignore
  | Some a ->
    let href =
      Js.Opt.case (a##getAttribute (Js.string "href")) (fun () -> "") Js.to_string
    in
    Effect.Many
      [ Loon.Dom_util.prevent_default ev
      ; Effect.of_thunk (fun () ->
          match String.chop_prefix href ~prefix:"#" with
          | Some id ->
            Js.Opt.iter
              (Dom_html.document##getElementById (Js.string id))
              (fun el -> el##scrollIntoView Js._true)
          | None ->
            if String.is_prefix href ~prefix:"http"
            then
              ignore
                (Dom_html.window##open_ (Js.string href) (Js.string "_blank") Js.null
                 : Dom_html.window Js.t Js.opt))
      ]
;;

(* (view)/preview/typeset: the document in its layout, sized by the
   preview's width as shadcn's iframe is. *)
let document (p : Params.t) =
  let html =
    List.Assoc.find Typeset_fixtures.all p.item ~equal:String.equal
    |> Option.value ~default:""
  in
  let content =
    Node.div
      ~key:p.item
      ~attrs:[ Attr.class_ "contents" ]
      [ Node.inner_html
          ~tag:"div"
          ~attrs:[ Attr.class_ "typeset w-full" ]
          ~this_html_is_sanitized_and_is_totally_safe_trust_me:html
          ()
      ]
  in
  let content =
    if String.equal p.item "chat"
    then
      Node.div
        ~attrs:[ Attr.class_ "flex w-full flex-col gap-10" ]
        [ Node.div
            ~attrs:
              [ Attr.class_ "ml-auto w-fit max-w-[65%] rounded-3xl bg-muted px-4 py-2.5" ]
            [ Node.text Typeset_fixtures.chat_question ]
        ; content
        ]
    else content
  in
  let d = Params.default in
  Node.div
    ~attrs:
      [ Attr.class_
          "flex min-h-full justify-center px-6 pt-8 pb-24 \
           @min-[48rem]/typeset-preview:pt-24 @min-[48rem]/typeset-preview:pb-32"
      ; style
          (Css_gen.concat
             [ Css_gen.create
                 ~field:"font-family"
                 ~value:(sprintf "var(--preview-font, %s)" (default_font d.body))
             ; Css_gen.create
                 ~field:"--font-heading"
                 ~value:(sprintf "var(--preview-font-heading, %s)" (default_font d.body))
             ; Css_gen.create
                 ~field:"--font-mono"
                 ~value:(sprintf "var(--preview-font-mono, %s)" (default_font d.mono))
             ])
      ]
    [ Node.div
        ~attrs:
          [ Attr.class_ "preview-params w-full"
          ; style
              (Css_gen.concat
                 [ Css_gen.create
                     ~field:"font-size"
                     ~value:(sprintf "var(--preview-size, %spx)" d.scale)
                 ; Css_gen.create
                     ~field:"max-width"
                     ~value:
                       (sprintf
                          "var(--preview-measure, %s)"
                          (Option.value (Params.measure_width d.measure) ~default:""))
                 ])
          ]
        [ content ]
    ]
;;

let preview_root p =
  Node.div
    ~attrs:
      [ data "slot" "typeset-preview"
      ; Attr.create "role" "region"
      ; Attr.create "aria-label" "typeset preview"
      ; Attr.class_ "@container/typeset-preview size-full overflow-y-auto"
      ; style (preview_style p)
      ; Attr.on_click on_preview_click
      ]
    [ document p ]
;;

(* preview.tsx: the committed params, under a hover's. *)
let preview ~override ctx (local_ graph) =
  let toolbar = toolbar ctx graph in
  let%arr toolbar and ctx and override in
  let shown = Params.apply ctx.params (Option.value override ~default:[]) in
  Node.div
    ~attrs:
      [ Attr.class_
          "relative isolate flex size-full min-h-0 flex-1 overflow-hidden rounded-2xl \
           bg-background ring-1 ring-foreground/10"
      ]
    [ preview_root shown; toolbar ]
;;

(* {1 The page} *)

(* main-menu.tsx's, use-history.tsx's and use-theme-toggle.tsx's keys. *)
let keys ctx =
  Attr.Global_listeners.keydown ~phase:Bubbling ~f:(fun ev ->
    let ctrl = Js.to_bool ev##.ctrlKey in
    let meta = Js.to_bool ev##.metaKey in
    let alt = Js.to_bool ev##.altKey in
    let shift = Js.to_bool ev##.shiftKey in
    let go e = Effect.Many [ Loon.Dom_util.prevent_default ev; e ] in
    if Browser.in_browser () && Browser.active_element_is_editable ()
    then Effect.Ignore
    else (
      match Loon.Dom_util.key ev with
      | KeyR when not (ctrl || meta || alt) -> go (if shift then ctx.reset else ctx.shuffle)
      | KeyD when not (ctrl || meta || alt) -> go ctx.toggle_theme
      | KeyZ when (ctrl || meta) && shift -> go ctx.redo
      | KeyY when ctrl -> go ctx.redo
      | KeyZ when ctrl || meta -> go ctx.undo
      | _ -> Effect.Ignore))
;;

(* typeset/page.tsx's, with section-soft's colours and the height below the
   docs' header. *)
let page_class =
  "relative z-10 flex min-h-0 flex-1 flex-col overflow-hidden bg-linear-to-b \
   from-background to-[oklch(0.98_0_0)]/40 dark:bg-background \
   dark:to-[oklch(0.2_0_0)]/40 \
   [--customizer-width:--spacing(48)] [--gap:--spacing(4)] md:[--gap:--spacing(6)] \
   2xl:[--customizer-width:--spacing(56)] h-[calc(100svh-var(--docs-header))]"
;;

let component ~mode ~set_mode ~query ~set_query (local_ graph) =
  let params = Bonsai.map query ~f:Params.of_query in
  let preview_only =
    Bonsai.map query ~f:(fun q ->
      Option.equal
        String.equal
        (Customize_query.find (Customize_query.parse q) "view")
        (Some "preview"))
  in
  let history, set_history = Bonsai.state History.empty graph in
  let locks, set_locks = Bonsai.state [] graph in
  let override, set_override = Bonsai.state None graph in
  let is_mobile = Loon.Use_mobile.component graph in
  let ctx =
    let%arr params
    and history
    and set_history
    and locks
    and set_locks
    and set_override
    and override
    and is_mobile
    and set_query
    and mode
    and set_mode in
    let write p = set_query (Params.to_query p) in
    let commit next =
      if Params.equal next params
      then Effect.Ignore
      else
        Effect.Many
          [ set_history { History.past = params :: history.past; future = [] }
          ; set_override None
          ; write next
          ]
    in
    let undo =
      match history.past with
      | [] -> Effect.Ignore
      | p :: past ->
        Effect.Many [ set_history { past; future = params :: history.future }; write p ]
    in
    let redo =
      match history.future with
      | [] -> Effect.Ignore
      | p :: future ->
        Effect.Many [ set_history { past = params :: history.past; future }; write p ]
    in
    { params
    ; commit
    ; locks
    ; toggle_lock =
        (fun key ->
          set_locks
            (if List.mem locks key ~equal:Key.equal
             then List.filter locks ~f:(fun k -> not (Key.equal k key))
             else locks @ [ key ]))
    ; set_override =
        (fun o ->
          if Option.equal (List.equal [%equal: Key.t * string]) override (Some o)
          then Effect.Ignore
          else set_override (Some o))
    ; clear_override =
        (match override with
         | None -> Effect.Ignore
         | Some _ -> set_override None)
    ; is_mobile
    ; shuffle = Effect.bind (Effect.of_thunk (fun () -> shuffled params ~locks)) ~f:commit
    ; reset = commit Params.default
    ; undo
    ; redo
    ; can_undo = not (List.is_empty history.past)
    ; can_redo = not (List.is_empty history.future)
    ; toggle_theme = set_mode (Loon.Theme.Mode.toggle mode)
    }
  in
  let panel = Typeset_docs.panel params graph in
  let preview = preview ~override ctx graph in
  let customizer = customizer ctx graph in
  let%arr panel
  and preview
  and customizer, get_code_drawer = customizer
  and ctx
  and preview_only
  and params in
  if preview_only
  then
    Node.div
      ~attrs:
        [ data "tool" "typeset"
        ; Loon.Cn.attr
            [ "h-[calc(100svh-var(--docs-header))]"; Customize_fonts.root_class ]
        ]
      [ Customize_fonts.style; preview_root params ]
  else
    Node.div
      ~attrs:
        [ data "tool" "typeset"
        ; Loon.Cn.attr [ page_class; Customize_fonts.root_class ]
        ; keys ctx
        ]
      [ Customize_fonts.style
      ; Node.div
          ~attrs:
            [ data "slot" "designer"
            ; Attr.class_
                "flex min-h-0 flex-1 flex-col items-start gap-(--gap) p-(--gap) \
                 pt-[calc(var(--gap)*0.25)] md:flex-row-reverse"
            ]
          [ panel; preview; customizer ]
      ; get_code_drawer
      ]
;;
