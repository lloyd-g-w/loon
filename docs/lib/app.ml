open! Core
open Bonsai_web
open Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr
module Icon = Loon.Icon
module Theme = Loon.Theme

let github = "https://github.com/lloyd-g-w/loon"

let pages =
  let group_index g =
    List.findi_exn Doc.Group.all ~f:(fun _ x -> Doc.Group.equal g x) |> fst
  in
  List.sort Pages.all ~compare:(fun (a : Doc.Page.t) (b : Doc.Page.t) ->
    Comparable.lexicographic
      [ (fun (a : Doc.Page.t) (b : Doc.Page.t) ->
          Int.compare (group_index a.group) (group_index b.group))
      ; (fun a b -> Int.compare a.order b.order)
      ; (fun a b -> String.compare a.title b.title)
      ]
      a
      b)
;;

let find_page slug = List.find pages ~f:(fun p -> String.equal p.slug slug)

let first_component =
  List.find pages ~f:(fun p -> not (Doc.Group.equal p.group Guide))
  |> Option.value_map ~default:Route.home_slug ~f:(fun p -> p.slug)
;;

let href slug =
  if String.equal slug Route.home_slug then "#/" else Route.to_hash (Page slug)
;;

(* The page shown: its slug, or "" for one that does not exist. *)
module Shown = struct
  type t = string [@@deriving compare, equal, sexp_of]

  let all = "" :: List.map pages ~f:(fun p -> p.slug)
end

let shown_of_hash hash =
  let slug = Route.slug (Route.of_hash hash) in
  if Option.is_some (find_page slug) then slug else ""
;;

let accent_of_name name =
  List.find Theme.Accent.all ~f:(fun a -> String.equal (Theme.Accent.name a) name)
;;

let mode_name : Theme.Mode.t -> string = function
  | Light -> "light"
  | Dark -> "dark"
;;

let external_attrs = [ Attr.create "target" "_blank"; Attr.create "rel" "noopener" ]
let kbd text = Node.kbd ~attrs:[ Attr.class_ "docs-kbd" ] [ Node.text text ]

(* {1 Pieces} *)

let icon_button ?(attrs = []) ~label ?on_click icon =
  Node.button
    ~attrs:
      ([ Attr.type_ "button"
       ; Attr.class_ "docs-icon-button"
       ; Attr.create "aria-label" label
       ; Attr.title label
       ]
       @ (match on_click with
          | None -> []
          | Some e -> [ Attr.on_click (fun _ -> e) ])
       @ attrs)
    [ icon ]
;;

let brand =
  Node.a
    ~attrs:[ Attr.href "#/"; Attr.class_ "docs-brand"; Attr.create "aria-label" "loon home" ]
    [ Node.create
        "img"
        ~attrs:[ Attr.src "icon.svg"; Attr.create "alt" ""; Attr.class_ "docs-logo" ]
        []
    ; Node.span ~attrs:[ Attr.class_ "docs-wordmark" ] [ Node.text "loon" ]
    ]
;;

let sidebar ~current =
  Node.nav
    ~attrs:[ Attr.class_ "docs-nav"; Attr.create "aria-label" "Documentation" ]
    (List.filter_map Doc.Group.all ~f:(fun group ->
       match List.filter pages ~f:(fun p -> Doc.Group.equal p.group group) with
       | [] -> None
       | in_group ->
         Some
           (Node.div
              ~attrs:[ Attr.class_ "docs-nav-group" ]
              [ Node.div
                  ~attrs:[ Attr.class_ "docs-nav-heading" ]
                  [ Node.text (Doc.Group.title group) ]
              ; Node.ul
                  (List.map in_group ~f:(fun (p : Doc.Page.t) ->
                     let active = String.equal p.slug current in
                     Node.li
                       [ Node.a
                           ~attrs:
                             ([ Attr.href (href p.slug)
                              ; Attr.class_ "docs-nav-link"
                              ; Attr.create "data-slug" p.slug
                              ]
                              @ if active then [ Attr.create "aria-current" "page" ] else [])
                           [ Node.text p.title ]
                       ]))
              ])))
;;

let toc ~slug outline =
  match outline with
  | [] -> Node.none
  | outline ->
    Node.nav
      ~attrs:[ Attr.class_ "docs-toc"; Attr.create "aria-label" "On this page" ]
      [ Node.div ~attrs:[ Attr.class_ "docs-toc-title" ] [ Node.text "On this page" ]
      ; Node.ul
          (List.map outline ~f:(fun (id, title, level) ->
             Node.li
               [ Node.a
                   ~attrs:
                     [ Attr.href (Route.to_hash (Page slug) ^ "/" ^ id)
                     ; Attr.classes [ "docs-toc-link"; sprintf "docs-toc-level-%d" level ]
                     ; Attr.create "data-target" id
                     ]
                   [ Node.text title ]
               ]))
      ; Node.a
          ~attrs:([ Attr.class_ "docs-toc-star"; Attr.href github ] @ external_attrs)
          [ Icon.view Github; Node.text "Star loon on GitHub" ]
      ]
;;

(* {1 Examples and pages} *)

let example_view ~(page : Doc.Page.t) index (example : Doc.Example.t) (local_ graph) =
  let preview = example.view graph in
  let tab, set_tab = Bonsai.state "preview" graph in
  let%arr preview and tab and set_tab in
  let id = Doc.anchor example.title in
  Node.section
    ~attrs:[ Attr.class_ "docs-example" ]
    [ Node.h3
        ~attrs:
          [ Attr.class_ "docs-example-title"
          ; Attr.id id
          ; Attr.create "data-outline" example.title
          ]
        [ Node.a
            ~attrs:
              [ Attr.href (Route.to_hash (Page page.slug) ^ "/" ^ id)
              ; Attr.class_ "docs-anchor"
              ]
            [ Node.text example.title ]
        ]
    ; (match example.description with
       | None -> Node.none
       | Some d ->
         Node.p ~attrs:[ Attr.class_ "docs-example-description" ] [ Node.text d ])
    ; Node.div
        ~attrs:[ Attr.class_ "docs-example-card" ]
        [ Loon.Tabs.view
            ~variant:Underline
            ~name:(sprintf "ex-%s-%d" page.slug index)
            ~active:tab
            ~on_change:set_tab
            [ Loon.Tabs.Tab.create
                ~id:"preview"
                ~label:"Preview"
                (Node.div ~attrs:[ Attr.class_ "docs-preview" ] [ preview ])
            ; Loon.Tabs.Tab.create
                ~id:"code"
                ~label:"Code"
                (Node.pre
                   ~attrs:[ Attr.class_ "docs-pre docs-example-code" ]
                   [ Highlight.view example.source ])
            ]
        ; Code_block.copy_button ~label:"Copy example" example.source
        ]
    ]
;;

let page_header (page : Doc.Page.t) =
  let is_component = not (Doc.Group.equal page.group Guide) in
  let module_ = String.tr page.slug ~target:'-' ~replacement:'_' in
  Node.header
    ~attrs:[ Attr.class_ "docs-page-header" ]
    [ Node.div
        ~attrs:[ Attr.class_ "docs-eyebrow" ]
        [ Node.text (Doc.Group.title page.group) ]
    ; Node.h1 ~attrs:[ Attr.class_ "docs-h1" ] [ Node.text page.title ]
    ; Node.p ~attrs:[ Attr.class_ "docs-lede" ] [ Node.text page.description ]
    ; (if is_component
       then
         Node.div
           ~attrs:[ Attr.class_ "docs-page-links" ]
           [ Node.a
               ~attrs:
                 ([ Attr.class_ "docs-chip"
                  ; Attr.href (sprintf "%s/blob/main/src/%s.mli" github module_)
                  ]
                  @ external_attrs)
               [ Icon.view Github; Node.text "Source" ]
           ; Node.span
               ~attrs:[ Attr.class_ "docs-chip docs-chip-code" ]
               [ Node.code [ Node.text ("loon add " ^ page.slug) ]
               ; Code_block.copy_button ~label:"Copy command" ("loon add " ^ page.slug)
               ]
           ]
       else Node.none)
    ]
;;

let hero =
  Node.header
    ~attrs:[ Attr.class_ "docs-hero" ]
    [ Node.div
        ~attrs:[ Attr.class_ "docs-hero-pill" ]
        [ Node.span ~attrs:[ Attr.class_ "docs-hero-dot" ] []
        ; Node.text "Bonsai_web · OxCaml · js_of_ocaml"
        ]
    ; Node.h1
        ~attrs:[ Attr.class_ "docs-hero-title" ]
        [ Node.text "Calm, well-made components for "
        ; Node.span ~attrs:[ Attr.class_ "docs-hero-em" ] [ Node.text "Bonsai" ]
        ; Node.text "."
        ]
    ; Node.p
        ~attrs:[ Attr.class_ "docs-lede docs-hero-lede" ]
        [ Node.text
            "loon is a set of accessible, themeable components for Bonsai_web. Use it as \
             a library, or copy a component's source into your project with "
        ; Node.code ~attrs:[ Attr.class_ "docs-code-inline" ] [ Node.text "loon add" ]
        ; Node.text " and make it yours."
        ]
    ; Node.div
        ~attrs:[ Attr.class_ "docs-hero-actions" ]
        [ Loon.Button.link
            ~size:Lg
            ~href:"#/installation"
            [ Node.text "Get started"; Icon.view Arrow_right ]
        ; Loon.Button.link
            ~size:Lg
            ~variant:Outline
            ~href:(href first_component)
            [ Node.text "Browse components" ]
        ]
    ]
;;

let pager ~slug =
  let rec find prev = function
    | [] -> None, None
    | (p : Doc.Page.t) :: rest ->
      if String.equal p.slug slug then prev, List.hd rest else find (Some p) rest
  in
  let prev, next = find None pages in
  let link ~dir (p : Doc.Page.t option) =
    match p with
    | None -> Node.div []
    | Some p ->
      Node.a
        ~attrs:
          [ Attr.href (href p.slug)
          ; Attr.classes [ "docs-pager-link"; "docs-pager-" ^ dir ]
          ]
        [ Node.span
            ~attrs:[ Attr.class_ "docs-pager-dir" ]
            [ Node.text (if String.equal dir "prev" then "Previous" else "Next") ]
        ; Node.span ~attrs:[ Attr.class_ "docs-pager-title" ] [ Node.text p.title ]
        ]
  in
  Node.nav
    ~attrs:[ Attr.class_ "docs-pager"; Attr.create "aria-label" "Pages" ]
    [ link ~dir:"prev" prev; link ~dir:"next" next ]
;;

let page_view (page : Doc.Page.t) (local_ graph) =
  let examples =
    List.mapi page.examples ~f:(fun i e -> example_view ~page i e graph) |> Bonsai.all
  in
  let%arr examples in
  let is_home = String.equal page.slug Route.home_slug in
  Node.article
    ~attrs:[ Attr.class_ "docs-article"; Attr.create "data-page" page.slug ]
    ([ (if is_home then hero else page_header page) ]
     @ (match page.usage with
        | None -> []
        | Some usage -> [ Doc.h2 "Usage"; Code_block.view usage ])
     @ (match examples with
        | [] -> []
        | examples -> if is_home then examples else Doc.h2 "Examples" :: examples)
     @ page.body
     @ [ pager ~slug:page.slug ])
;;

let not_found =
  Node.article
    ~attrs:[ Attr.class_ "docs-article"; Attr.create "data-page" "" ]
    [ Node.header
        ~attrs:[ Attr.class_ "docs-page-header" ]
        [ Node.div ~attrs:[ Attr.class_ "docs-eyebrow" ] [ Node.text "404" ]
        ; Node.h1 ~attrs:[ Attr.class_ "docs-h1" ] [ Node.text "Page not found" ]
        ; Node.p
            ~attrs:[ Attr.class_ "docs-lede" ]
            [ Node.text
                "That page has flown off. Try the search, or start from the \
                 introduction."
            ]
        ]
    ; Loon.Button.link ~href:"#/" [ Icon.view Arrow_left; Node.text "Back home" ]
    ]
;;

(* {1 Search} *)

module Result = struct
  type t =
    { title : string
    ; context : string
    ; hash : string
    ; is_page : bool
    }
end

let search_items =
  List.concat_map pages ~f:(fun (p : Doc.Page.t) ->
    { Result.title = p.title
    ; context = Doc.Group.title p.group
    ; hash = href p.slug
    ; is_page = true
    }
    :: List.map p.examples ~f:(fun (e : Doc.Example.t) ->
      { Result.title = e.title
      ; context = p.title
      ; hash = Route.to_hash (Page p.slug) ^ "/" ^ Doc.anchor e.title
      ; is_page = false
      }))
;;

let search_results query =
  if String.is_empty (String.strip query)
  then List.filter search_items ~f:(fun r -> r.is_page)
  else
    Search.rank ~query search_items ~fields:(fun (r : Result.t) ->
      [ r.title; r.context ^ " " ^ r.title ])
    |> fun l -> List.take l 30
;;

let search_dialog ~query ~set_query ~selected ~set_selected ~close ~go =
  let results = search_results query in
  let count = List.length results in
  let selected =
    if count = 0 then 0 else Int.clamp_exn selected ~min:0 ~max:(count - 1)
  in
  let on_keydown ev =
    match Loon.Dom_util.key ev with
    | ArrowDown when count > 0 ->
      Effect.Many [ Loon.Dom_util.prevent_default ev; set_selected ((selected + 1) % count) ]
    | ArrowUp when count > 0 ->
      Effect.Many
        [ Loon.Dom_util.prevent_default ev; set_selected ((selected - 1 + count) % count) ]
    | Enter ->
      (match List.nth results selected with
       | None -> Effect.Ignore
       | Some r -> Effect.Many [ Loon.Dom_util.prevent_default ev; go r.hash ])
    | Escape -> Effect.Many [ Loon.Dom_util.prevent_default ev; close ]
    | _ -> Effect.Ignore
  in
  Node.div
    ~attrs:[ Attr.class_ "docs-search-layer" ]
    [ Node.div ~attrs:[ Attr.class_ "docs-scrim"; Attr.on_click (fun _ -> close) ] []
    ; Node.div
        ~attrs:
          [ Attr.class_ "docs-search"
          ; Attr.create "role" "dialog"
          ; Attr.create "aria-modal" "true"
          ; Attr.create "aria-label" "Search the documentation"
          ]
        [ Node.div
            ~attrs:[ Attr.class_ "docs-search-field" ]
            [ Icon.view Search
            ; Node.input
                ~attrs:
                  [ Attr.id "docs-search-input"
                  ; Attr.type_ "text"
                  ; Attr.class_ "docs-search-input"
                  ; Attr.placeholder "Search components and examples…"
                  ; Attr.create "autocomplete" "off"
                  ; Attr.create "spellcheck" "false"
                  ; Attr.create "role" "combobox"
                  ; Attr.create "aria-expanded" "true"
                  ; Attr.create "aria-controls" "docs-search-results"
                  ; Attr.create "aria-activedescendant" (sprintf "docs-search-%d" selected)
                  ; Attr.value query
                  ; Attr.on_input (fun _ q -> Effect.Many [ set_query q; set_selected 0 ])
                  ; Attr.on_keydown on_keydown
                  ]
                ()
            ; Node.button
                ~attrs:
                  [ Attr.type_ "button"
                  ; Attr.class_ "docs-search-close"
                  ; Attr.create "aria-label" "Close search"
                  ; Attr.on_click (fun _ -> close)
                  ]
                [ kbd "Esc" ]
            ]
        ; (match results with
           | [] ->
             Node.div
               ~attrs:[ Attr.class_ "docs-search-empty" ]
               [ Node.textf "Nothing matches “%s”." query ]
           | results ->
             Node.ul
               ~attrs:
                 [ Attr.id "docs-search-results"
                 ; Attr.class_ "docs-search-results"
                 ; Attr.create "role" "listbox"
                 ]
               (List.mapi results ~f:(fun i (r : Result.t) ->
                  Node.li
                    ~attrs:
                      ([ Attr.id (sprintf "docs-search-%d" i)
                       ; Attr.create "role" "option"
                       ; Attr.create "aria-selected" (Bool.to_string (i = selected))
                       ; Attr.create "data-hash" r.hash
                       ; Attr.class_ "docs-search-result"
                       ; Attr.on_click (fun _ -> go r.hash)
                       ; Attr.on_mousemove (fun _ ->
                           if i = selected then Effect.Ignore else set_selected i)
                       ]
                       @ if i = selected then [ Attr.create "data-selected" "" ] else [])
                    [ Icon.view (if r.is_page then File else Arrow_right)
                    ; Node.span
                        ~attrs:[ Attr.class_ "docs-search-title" ]
                        [ Node.text r.title ]
                    ; Node.span
                        ~attrs:[ Attr.class_ "docs-search-context" ]
                        [ Node.text r.context ]
                    ])))
        ; Node.div
            ~attrs:[ Attr.class_ "docs-search-footer" ]
            [ Node.span [ kbd "↑"; kbd "↓"; Node.text "to move" ]
            ; Node.span [ kbd "↵"; Node.text "to open" ]
            ]
        ]
    ]
;;

(* {1 The accent picker} *)

let accent_picker ~accent ~set_accent ~open_ ~set_open =
  Node.div
    ~attrs:[ Attr.class_ "docs-accent" ]
    ([ Node.button
         ~attrs:
           [ Attr.type_ "button"
           ; Attr.class_ "docs-icon-button docs-accent-trigger"
           ; Attr.create "aria-label" "Accent colour"
           ; Attr.title "Accent colour"
           ; Attr.create "aria-haspopup" "menu"
           ; Attr.create "aria-expanded" (Bool.to_string open_)
           ; Attr.on_click (fun _ ->
               if open_
               then set_open false
               else
                 Effect.Many
                   [ set_open true
                   ; Loon.Dom_util.focus_selector
                       ".docs-accent-option[aria-checked=\"true\"]"
                   ])
           ]
         [ Node.span
             ~attrs:
               [ Attr.class_ "docs-swatch"
               ; Attr.create "data-loon-accent" (Theme.Accent.name accent)
               ]
             []
         ]
     ]
     @
     if not open_
     then []
     else
       [ Node.div
           ~attrs:[ Attr.class_ "docs-click-away"; Attr.on_click (fun _ -> set_open false) ]
           []
       ; Node.div
           ~attrs:
             [ Attr.class_ "docs-accent-menu"
             ; Attr.create "role" "menu"
             ; Attr.create "aria-label" "Accent colour"
             ; Attr.on_keydown (fun ev ->
                 match Loon.Dom_util.key ev with
                 | Tab -> set_open false
                 | Escape ->
                   Effect.Many
                     [ set_open false; Loon.Dom_util.focus_selector ".docs-accent-trigger" ]
                 | ArrowDown ->
                   Effect.Many
                     [ Loon.Dom_util.prevent_default ev
                     ; Effect.of_thunk (fun () -> Browser.move_focus ".docs-accent-option" 1)
                     ]
                 | ArrowUp ->
                   Effect.Many
                     [ Loon.Dom_util.prevent_default ev
                     ; Effect.of_thunk (fun () -> Browser.move_focus ".docs-accent-option" (-1))
                     ]
                 | _ -> Effect.Ignore)
             ]
           [ Node.div ~attrs:[ Attr.class_ "docs-accent-heading" ] [ Node.text "Accent" ]
           ; Node.div
               ~attrs:[ Attr.class_ "docs-accent-options" ]
               (List.map Theme.Accent.all ~f:(fun a ->
                  let name = Theme.Accent.name a in
                  let checked = Theme.Accent.equal a accent in
                  Node.button
                    ~attrs:
                      [ Attr.type_ "button"
                      ; Attr.class_ "docs-accent-option"
                      ; Attr.create "role" "menuitemradio"
                      ; Attr.create "aria-checked" (Bool.to_string checked)
                      ; Attr.create "data-accent" name
                      ; Attr.tabindex (-1)
                      ; Attr.on_click (fun _ ->
                          Effect.Many
                            [ set_accent a
                            ; set_open false
                            ; Loon.Dom_util.focus_selector ".docs-accent-trigger"
                            ])
                      ]
                    [ Node.span
                        ~attrs:
                          [ Attr.class_ "docs-swatch"; Attr.create "data-loon-accent" name ]
                        []
                    ; Node.span [ Node.text (String.capitalize name) ]
                    ; (if checked
                       then Icon.view ~attrs:[ Attr.class_ "docs-accent-check" ] Check
                       else Node.none)
                    ]))
           ]
       ])
;;

(* {1 The app} *)

let anchor_of_hash hash =
  match String.split (String.chop_prefix_if_exists hash ~prefix:"#/") ~on:'/' with
  | _ :: anchor :: _ when not (String.is_empty anchor) -> Some anchor
  | _ -> None
;;

let component (local_ graph) =
  let hash_var = Bonsai.Expert.Var.create (Browser.hash ()) in
  Browser.on_hash_change (fun h -> Bonsai.Expert.Var.set hash_var h);
  Browser.install_scroll_spy ();
  let hash = Bonsai.Expert.Var.value hash_var in
  let shown = Bonsai.map hash ~f:shown_of_hash in
  let initial_mode =
    match Browser.get_item "loon-docs-mode" with
    | Some "dark" -> Theme.Mode.Dark
    | Some "light" -> Light
    | _ -> Theme.Mode.preferred ()
  in
  let initial_accent =
    Option.bind (Browser.get_item "loon-docs-accent") ~f:accent_of_name
    |> Option.value ~default:Theme.Accent.Teal
  in
  let mode, set_mode = Bonsai.state initial_mode graph in
  let accent, set_accent = Bonsai.state initial_accent graph in
  let nav_open, set_nav_open = Bonsai.state false graph in
  let search_open, set_search_open = Bonsai.state false graph in
  let query, set_query = Bonsai.state "" graph in
  let selected, set_selected = Bonsai.state 0 graph in
  let accent_open, set_accent_open = Bonsai.state false graph in
  let outline, set_outline = Bonsai.state [] graph in
  (* The document follows the theme: its background and scrollbars. *)
  Bonsai.Edge.on_change
    ~trigger:`Before_display
    ~equal:[%equal: Theme.Mode.t * Theme.Accent.t]
    (Bonsai.both mode accent)
    ~callback:
      (Bonsai.return (fun (mode, accent) ->
         Effect.of_thunk (fun () ->
           Browser.set_root_theme
             ~mode:(mode_name mode)
             ~accent:(Theme.Accent.name accent))))
    graph;
  Bonsai.Edge.on_change'
    ~trigger:`After_display
    ~equal:String.equal
    hash
    ~callback:
      (let%arr set_nav_open and set_search_open in
       fun prev hash ->
         let slug = shown_of_hash hash in
         let same_page =
           Option.value_map prev ~default:false ~f:(fun p ->
             String.equal (shown_of_hash p) slug)
         in
         Effect.Many
           [ set_nav_open false
           ; set_search_open false
           ; Effect.of_thunk (fun () ->
               Browser.set_title
                 (match find_page slug with
                  | Some p when not (String.equal slug Route.home_slug) ->
                    p.title ^ " · loon"
                  | Some _ -> "loon — components for Bonsai"
                  | None -> "Not found · loon");
               match anchor_of_hash hash with
               | Some id -> Browser.scroll_to_anchor id
               | None -> if not same_page then Browser.scroll_to_top ())
           ])
    graph;
  (* The outline is read from the page drawn: after each frame whose article
     is not the one last outlined (in WebKit, the page's first frame after a
     change of hash may still show the old one). *)
  let outlined, set_outlined = Bonsai.state "" graph in
  Bonsai.Edge.after_display
    (let%arr outlined and set_outlined and set_outline in
     let%bind.Effect page = Effect.of_thunk Browser.article_page in
     match page with
     | Some page when not (String.equal page outlined) ->
       let%bind.Effect outline = Effect.of_thunk Browser.outline in
       Effect.Many
         [ set_outlined page
         ; set_outline outline
         ; Effect.of_thunk Browser.update_scroll_spy
         ]
     | _ -> Effect.Ignore)
    graph;
  Bonsai.Edge.on_change
    ~trigger:`After_display
    ~equal:Bool.equal
    (Bonsai.map2 nav_open search_open ~f:( || ))
    ~callback:
      (Bonsai.return (fun locked ->
         Effect.of_thunk (fun () -> Browser.set_body_scroll_locked locked)))
    graph;
  let open_search =
    let%arr set_search_open and set_query and set_selected in
    Effect.Many
      [ set_query ""
      ; set_selected 0
      ; set_search_open true
      ; Loon.Dom_util.focus_selector "#docs-search-input"
      ]
  in
  let article =
    Bonsai.enum
      (module Shown)
      ~match_:shown
      ~with_:(fun slug (local_ graph) ->
        match find_page slug with
        | None -> Bonsai.return not_found
        | Some page -> page_view page graph)
      graph
  in
  let%arr article
  and current = shown
  and mode
  and set_mode
  and accent
  and set_accent
  and nav_open
  and set_nav_open
  and search_open
  and set_search_open
  and query
  and set_query
  and selected
  and set_selected
  and accent_open
  and set_accent_open
  and outline
  and open_search in
  let set_mode m =
    Effect.Many
      [ set_mode m
      ; Effect.of_thunk (fun () -> Browser.set_item "loon-docs-mode" (mode_name m))
      ]
  in
  let set_accent a =
    Effect.Many
      [ set_accent a
      ; Effect.of_thunk (fun () ->
          Browser.set_item "loon-docs-accent" (Theme.Accent.name a))
      ]
  in
  let go hash =
    Effect.Many
      [ set_search_open false; Effect.of_thunk (fun () -> Browser.set_hash hash) ]
  in
  let global_keys =
    Vdom.Attr.Global_listeners.keydown ~phase:Bubbling ~f:(fun ev ->
      let ctrl =
        Js_of_ocaml.Js.to_bool ev##.ctrlKey || Js_of_ocaml.Js.to_bool ev##.metaKey
      in
      match Loon.Dom_util.key ev with
      | KeyK when ctrl ->
        Effect.Many
          [ Loon.Dom_util.prevent_default ev
          ; (if search_open then set_search_open false else open_search)
          ]
      | Slash when (not search_open) && not (Browser.active_element_is_editable ()) ->
        Effect.Many [ Loon.Dom_util.prevent_default ev; open_search ]
      | Escape when nav_open -> set_nav_open false
      | Escape when accent_open -> set_accent_open false
      | _ -> Effect.Ignore)
  in
  let mod_key = if Browser.is_mac () then "⌘" else "Ctrl" in
  let section_active label =
    match find_page current with
    | Some p ->
      if String.equal label "Docs"
      then Doc.Group.equal p.group Guide
      else not (Doc.Group.equal p.group Guide)
    | None -> false
  in
  Theme.root
    ~mode
    ~accent
    ~attrs:[ Attr.class_ "docs-app"; global_keys ]
    [ Node.a
        ~attrs:
          [ Attr.href "#main"
          ; Attr.class_ "docs-skip"
          ; Attr.on_click (fun ev ->
              Effect.Many
                [ Loon.Dom_util.prevent_default ev
                ; Effect.of_thunk (fun () -> Browser.focus "main")
                ])
          ]
        [ Node.text "Skip to content" ]
    ; Node.header
        ~attrs:[ Attr.class_ "docs-header" ]
        [ Node.div
            ~attrs:[ Attr.class_ "docs-header-inner" ]
            [ icon_button
                ~attrs:
                  [ Attr.class_ "docs-menu-button"
                  ; Attr.create "aria-expanded" (Bool.to_string nav_open)
                  ; Attr.create "aria-controls" "docs-sidebar"
                  ]
                ~label:"Menu"
                ~on_click:(set_nav_open (not nav_open))
                (Icon.view (if nav_open then X else Menu))
            ; brand
            ; Node.nav
                ~attrs:[ Attr.class_ "docs-topnav"; Attr.create "aria-label" "Main" ]
                (List.map
                   [ "Docs", "installation"; "Components", first_component ]
                   ~f:(fun (label, slug) ->
                     Node.a
                       ~attrs:
                         ([ Attr.href (href slug); Attr.class_ "docs-topnav-link" ]
                          @
                          if section_active label
                          then [ Attr.create "data-active" "" ]
                          else [])
                       [ Node.text label ]))
            ; Node.div ~attrs:[ Attr.class_ "docs-header-spacer" ] []
            ; Node.button
                ~attrs:
                  [ Attr.type_ "button"
                  ; Attr.class_ "docs-search-trigger"
                  ; Attr.create "aria-label" "Search"
                  ; Attr.create "aria-keyshortcuts" "Control+K Meta+K /"
                  ; Attr.on_click (fun _ -> open_search)
                  ]
                [ Icon.view Search
                ; Node.span
                    ~attrs:[ Attr.class_ "docs-search-trigger-text" ]
                    [ Node.text "Search docs…" ]
                ; Node.kbd
                    ~attrs:[ Attr.class_ "docs-kbd docs-search-trigger-kbd" ]
                    [ Node.text (mod_key ^ " K") ]
                ]
            ; accent_picker
                ~accent
                ~set_accent
                ~open_:accent_open
                ~set_open:set_accent_open
            ; icon_button
                ~attrs:
                  [ Attr.class_ "docs-theme-toggle"
                  ; Attr.create "data-mode" (mode_name mode)
                  ]
                ~label:
                  (match mode with
                   | Light -> "Switch to dark theme"
                   | Dark -> "Switch to light theme")
                ~on_click:(set_mode (Theme.Mode.toggle mode))
                (Icon.view
                   (match mode with
                    | Light -> Moon
                    | Dark -> Sun))
            ; Node.a
                ~attrs:
                  ([ Attr.href github
                   ; Attr.class_ "docs-icon-button docs-github"
                   ; Attr.create "aria-label" "loon on GitHub"
                   ; Attr.title "loon on GitHub"
                   ]
                   @ external_attrs)
                [ Icon.view Github ]
            ]
        ]
    ; Node.div
        ~attrs:[ Attr.class_ "docs-layout" ]
        [ Node.aside
            ~attrs:
              ([ Attr.id "docs-sidebar"; Attr.class_ "docs-sidebar" ]
               @ if nav_open then [ Attr.create "data-open" "" ] else [])
            [ sidebar ~current
            ; Node.div
                ~attrs:[ Attr.class_ "docs-sidebar-footer" ]
                [ Node.a
                    ~attrs:([ Attr.href github; Attr.class_ "docs-nav-link" ] @ external_attrs)
                    [ Icon.view Github; Node.text "GitHub" ]
                ]
            ]
        ; (if nav_open
           then
             Node.div
               ~attrs:
                 [ Attr.class_ "docs-scrim docs-nav-scrim"
                 ; Attr.on_click (fun _ -> set_nav_open false)
                 ]
               []
           else Node.none)
        ; Node.main
            ~attrs:[ Attr.id "main"; Attr.class_ "docs-main"; Attr.tabindex (-1) ]
            [ article
            ; Node.footer
                ~attrs:[ Attr.class_ "docs-footer" ]
                [ Node.text "loon is MIT licensed, and built with Bonsai on OxCaml. "
                ; Node.a
                    ~attrs:([ Attr.href github; Attr.class_ "docs-link" ] @ external_attrs)
                    [ Node.text "Source on GitHub" ]
                ; Node.text "."
                ]
            ]
        ; Node.aside ~attrs:[ Attr.class_ "docs-toc-column" ] [ toc ~slug:current outline ]
        ]
    ; (if search_open
       then
         search_dialog
           ~query
           ~set_query
           ~selected
           ~set_selected
           ~close:(set_search_open false)
           ~go
       else Node.none)
    ]
;;
