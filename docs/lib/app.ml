open! Core
open Bonsai_web
open Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr
module Icon = Loon.Icon
module Button = Loon.Button
module Cn = Loon.Cn

let github = Site.github

let section_index s =
  List.findi_exn Doc.Section.all ~f:(fun _ x -> Doc.Section.equal s x) |> fst
;;

let pages =
  List.sort Pages.all ~compare:(fun (a : Doc.Page.t) (b : Doc.Page.t) ->
    Comparable.lexicographic
      [ (fun (a : Doc.Page.t) (b : Doc.Page.t) ->
          Int.compare (section_index a.section) (section_index b.section))
      ; (fun a b -> Int.compare a.order b.order)
      ; (fun a b -> String.compare a.title b.title)
      ]
      a
      b)
;;

let find_page slug = List.find pages ~f:(fun p -> String.equal p.slug slug)
let in_section s = List.filter pages ~f:(fun p -> Doc.Section.equal p.section s)
let href slug = Route.to_hash (Page slug)

(* The index of the components: shadcn's /docs/components. *)
let components_slug = "components"

(* Where a section's link in the header goes. *)
let section_href (s : Doc.Section.t) =
  match s, in_section s with
  | Components, _ -> href components_slug
  | Get_started, _ -> href "installation"
  | _, p :: _ -> href p.slug
  | _, [] -> "#/"
;;

let nav_items : (string * Doc.Section.t) list =
  [ "Docs", Get_started
  ; "Components", Components
  ; "Blocks", Blocks
  ; "Charts", Charts
  ; "Create", Create
  ; "Typeset", Typeset
  ]
;;

(* What is shown: the home page, a page (by slug), or nothing found. *)
module Shown = struct
  type t =
    | Home
    | Page of string
    | Not_found
  [@@deriving compare, equal, sexp_of]

  let all =
    Home :: Page components_slug :: Not_found :: List.map pages ~f:(fun p -> Page p.slug)
  ;;

  let of_hash hash =
    match Route.of_hash hash with
    | Home -> Home
    | Page slug when String.equal slug components_slug -> Page slug
    | Page slug -> if Option.is_some (find_page slug) then Page slug else Not_found
  ;;

  let section = function
    | Page s when String.equal s components_slug -> Some Doc.Section.Components
    | Page s -> Option.map (find_page s) ~f:(fun p -> p.section)
    | Home | Not_found -> None
  ;;
end

let external_attrs = [ Attr.create "target" "_blank"; Attr.create "rel" "noreferrer" ]
let sr_only text = Node.span ~attrs:[ Attr.class_ "sr-only" ] [ Node.text text ]
let svg = Site.svg
let path = Site.path

(* {1 The header} *)

let section_active ~section s =
  Option.value_map section ~default:false ~f:(fun cur ->
    Doc.Section.equal cur s
    || (Doc.Section.equal s Get_started && Doc.Section.equal cur Forms))
;;

let main_nav ~section =
  Node.nav
    ~attrs:
      [ Attr.create "data-slot" "main-nav"; Attr.class_ "hidden items-center gap-0 lg:flex" ]
    (Button.link
       ~variant:Ghost
       ~size:Sm
       ~class_:"mr-2 gap-2 px-2"
       ~attrs:[ Attr.create "data-docs" "logo" ]
       ~href:"#/"
       [ Site.logo (); Node.span ~attrs:[ Attr.class_ "font-semibold" ] [ Node.text "loon" ] ]
     :: List.map nav_items ~f:(fun (label, s) ->
       Button.link
         ~variant:Ghost
         ~size:Sm
         ~class_:"relative items-center px-2.5"
         ~attrs:[ Attr.create "data-active" (Bool.to_string (section_active ~section s)) ]
         ~href:(section_href s)
         [ Node.text label ]))
;;

let mobile_link ?(attrs = []) ~close ~href:h children =
  Node.a
    ~attrs:
      ([ Attr.href h
       ; Attr.class_ "flex items-center gap-2 text-2xl font-medium"
       ; Attr.on_click (fun _ -> close)
       ]
       @ attrs)
    children
;;

let mobile_group title links =
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col gap-4" ]
    [ Node.div
        ~attrs:[ Attr.class_ "text-sm font-medium text-muted-foreground" ]
        [ Node.text title ]
    ; Node.div ~attrs:[ Attr.class_ "flex flex-col gap-3" ] links
    ]
;;

let top_level_sections =
  [ "Introduction", "introduction"
  ; "Components", components_slug
  ; "Installation", "installation"
  ; "Theming", "theming"
  ; "CLI", "cli"
  ]
  |> List.filter ~f:(fun (_, slug) ->
    String.equal slug components_slug || Option.is_some (find_page slug))
;;

(* The sidebar's groups after "Sections": the docs' sections and their
   pages (the introduction is under "Sections" only, as shadcn's). *)
let docs_groups =
  List.filter_map Doc.Section.all ~f:(fun s ->
    if not (Doc.Section.is_docs s)
    then None
    else (
      match
        List.filter (in_section s) ~f:(fun p -> not (String.equal p.slug "introduction"))
      with
      | [] -> None
      | ps -> Some (s, ps)))
;;

let mobile_nav ~open_ ~set_open =
  let close = set_open false in
  let bar ~open_cls ~closed_cls =
    Node.span
      ~attrs:
        [ Attr.class_
            (Cn.cn
               [ "absolute left-0 block h-0.5 w-4 bg-foreground transition-all duration-100"
               ; (if open_ then open_cls else closed_cls)
               ])
        ]
      []
  in
  Node.fragment
    [ Button.view
        ~variant:Ghost
        ~class_:
          "extend-touch-target flex h-8 touch-manipulation items-center justify-start \
           gap-2.5 p-0! hover:bg-transparent focus-visible:bg-transparent \
           focus-visible:ring-0 active:bg-transparent lg:hidden dark:hover:bg-transparent"
        ~attrs:
          [ Attr.create "data-docs" "mobile-nav-trigger"
          ; Attr.create "aria-expanded" (Bool.to_string open_)
          ; Attr.create "aria-controls" "mobile-nav"
          ; Attr.create "data-state" (if open_ then "open" else "closed")
          ]
        ~on_click:(set_open (not open_))
        [ Node.div
            ~attrs:[ Attr.class_ "relative flex h-8 w-4 items-center justify-center" ]
            [ Node.div
                ~attrs:[ Attr.class_ "relative size-4" ]
                [ bar ~open_cls:"top-[0.4rem] -rotate-45" ~closed_cls:"top-1"
                ; bar ~open_cls:"top-[0.4rem] rotate-45" ~closed_cls:"top-2.5"
                ]
            ; sr_only "Toggle Menu"
            ]
        ; Node.span
            ~attrs:[ Attr.class_ "flex h-8 items-center text-lg leading-none font-medium" ]
            [ Node.text "Menu" ]
        ]
    ; (if not open_
       then Node.none
       else
         Node.div
           ~attrs:
             [ Attr.id "mobile-nav"
             ; Attr.create "data-slot" "mobile-nav"
             ; Attr.create "data-state" "open"
             ; Attr.class_
                 "no-scrollbar fixed inset-x-0 top-(--header-height) bottom-0 z-50 \
                  overflow-y-auto overscroll-contain bg-background/90 p-0 backdrop-blur \
                  lg:hidden"
             ]
           [ Node.div
               ~attrs:[ Attr.class_ "flex flex-col gap-12 overflow-auto px-6 py-6" ]
               [ mobile_group
                   "Menu"
                   (mobile_link ~close ~href:"#/" [ Node.text "Home" ]
                    :: List.map nav_items ~f:(fun (label, s) ->
                      mobile_link ~close ~href:(section_href s) [ Node.text label ]))
               ; mobile_group
                   "Sections"
                   (List.map top_level_sections ~f:(fun (name, slug) ->
                      mobile_link
                        ~attrs:[ Attr.create "data-slug" slug ]
                        ~close
                        ~href:(href slug)
                        [ Node.text name ]))
               ; Node.div
                   ~attrs:[ Attr.class_ "flex flex-col gap-8" ]
                   (List.map docs_groups ~f:(fun (s, ps) ->
                      mobile_group
                        (Doc.Section.title s)
                        (List.map ps ~f:(fun (p : Doc.Page.t) ->
                           mobile_link
                             ~attrs:[ Attr.create "data-slug" p.slug ]
                             ~close
                             ~href:(href p.slug)
                             [ Node.text p.title ]))))
               ]
           ])
    ]
;;

let separator ?class_ () = Loon.Separator.view ~orientation:Vertical ?class_ ()

let mode_switcher ~on_click =
  Button.view
    ~variant:Ghost
    ~size:Icon
    ~class_:"group/toggle extend-touch-target size-8"
    ~attrs:[ Attr.create "data-docs" "mode-switcher"; Attr.title "Toggle theme" ]
    ~on_click
    [ svg
        ~attrs:
          [ Attr.create "width" "24"
          ; Attr.create "height" "24"
          ; Attr.create "fill" "none"
          ; Attr.create "stroke" "currentColor"
          ; Attr.create "stroke-width" "2"
          ; Attr.create "stroke-linecap" "round"
          ; Attr.create "stroke-linejoin" "round"
          ; Attr.class_ "size-4.5"
          ]
        ~view_box:"0 0 24 24"
        [ path ~attrs:[ Attr.create "stroke" "none"; Attr.create "fill" "none" ] "M0 0h24v24H0z"
        ; path "M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0"
        ; path "M12 3l0 18"
        ; path "M12 9l4.65 -4.65"
        ; path "M12 14.3l7.37 -7.37"
        ; path "M12 19.6l8.85 -8.85"
        ]
    ; sr_only "Toggle theme"
    ]
;;

let github_link =
  Button.link
    ~size:Sm
    ~variant:Ghost
    ~class_:"h-8 shadow-none"
    ~attrs:
      (Attr.create "data-docs" "github-link" :: Attr.title "loon on GitHub" :: external_attrs)
    ~href:github
    [ Site.github_icon (); sr_only "GitHub" ]
;;

let search_trigger ~open_search =
  Button.view
    ~variant:Outline
    ~class_:
      "relative h-8 w-full justify-start rounded-lg border-none bg-muted pl-3 \
       text-foreground shadow-none transition-colors hover:bg-muted/50 md:w-48 lg:w-40 \
       xl:w-64 dark:bg-card"
    ~attrs:
      [ Attr.create "data-docs" "command-menu-trigger"
      ; Attr.create "aria-keyshortcuts" "Control+K Meta+K /"
      ; Attr.create "aria-haspopup" "dialog"
      ]
    ~on_click:open_search
    [ Node.span
        ~attrs:[ Attr.class_ "hidden xl:inline-flex" ]
        [ Node.text "Search documentation..." ]
    ; Node.span ~attrs:[ Attr.class_ "inline-flex xl:hidden" ] [ Node.text "Search..." ]
    ]
;;

let site_header ~section ~mobile_open ~set_mobile_open ~open_search ~toggle_mode =
  Node.header
    ~attrs:[ Attr.class_ "sticky top-0 z-50 w-full bg-background" ]
    [ Node.div
        ~attrs:[ Attr.class_ "container-wrapper px-6 3xl:fixed:px-0" ]
        [ Node.div
            ~attrs:
              [ Attr.class_
                  "flex h-(--header-height) items-center **:data-[slot=separator]:h-4! \
                   3xl:fixed:container"
              ]
            [ mobile_nav ~open_:mobile_open ~set_open:set_mobile_open
            ; main_nav ~section
            ; Node.div
                ~attrs:
                  [ Attr.class_ "ml-auto flex items-center gap-2 md:flex-1 md:justify-end" ]
                [ Node.div
                    ~attrs:
                      [ Attr.class_ "hidden w-full flex-1 md:flex md:w-auto md:flex-none" ]
                    [ search_trigger ~open_search ]
                ; separator ~class_:"ml-2 hidden lg:block" ()
                ; github_link
                ; separator ()
                ; mode_switcher ~on_click:toggle_mode
                ; Node.div
                    ~attrs:[ Attr.class_ "flex items-center gap-2 md:hidden" ]
                    [ separator ()
                    ; Button.view
                        ~variant:Ghost
                        ~size:Icon
                        ~class_:"extend-touch-target size-8"
                        ~attrs:[ Attr.create "data-docs" "command-menu-trigger-mobile" ]
                        ~on_click:open_search
                        [ Icon.view Search; sr_only "Search" ]
                    ]
                ]
            ]
        ]
    ]
;;

let site_footer =
  let link ~href:h text =
    Node.a
      ~attrs:
        ([ Attr.href h; Attr.class_ "font-medium underline underline-offset-4" ]
         @ external_attrs)
      [ Node.text text ]
  in
  Node.footer
    ~attrs:
      [ Attr.class_
          "group-has-[.section-soft]/body:bg-surface/40 \
           group-has-[[data-slot=docs]]/body:hidden dark:bg-transparent \
           dark:group-has-[.section-soft]/body:bg-surface/40 3xl:fixed:bg-transparent"
      ]
    [ Node.div
        ~attrs:[ Attr.class_ "container-wrapper px-4 xl:px-6" ]
        [ Node.div
            ~attrs:[ Attr.class_ "flex h-(--footer-height) items-center justify-between" ]
            [ Node.div
                ~attrs:
                  [ Attr.class_
                      "w-full px-1 text-center text-xs leading-loose text-muted-foreground \
                       sm:text-sm"
                  ]
                [ Node.text "A port of "
                ; link ~href:"https://ui.shadcn.com" "shadcn/ui"
                ; Node.text " to Bonsai on OxCaml. The source code is available on "
                ; link ~href:github "GitHub"
                ; Node.text "."
                ]
            ]
        ]
    ]
;;

(* {1 The docs' sidebar} *)

let sidebar_link ~current ~slug title =
  Loon.Sidebar.menu_item
    [ Loon.Sidebar.menu_button
        ~is_active:(String.equal current slug)
        ~class_:
          "relative h-[30px] w-fit overflow-visible border border-transparent \
           text-[0.8rem] font-medium after:absolute after:inset-x-0 after:-inset-y-1 \
           after:z-0 after:rounded-md data-[active=true]:border-accent \
           data-[active=true]:bg-accent 3xl:fixed:w-full 3xl:fixed:max-w-48"
        ~attrs:[ Attr.create "data-slug" slug ]
        ~href:(href slug)
        [ Node.span
            ~attrs:
              [ Attr.class_ "absolute inset-0 flex w-(--sidebar-menu-width) bg-transparent" ]
            []
        ; Node.text title
        ]
    ]
;;

let sidebar_group ?class_ ?menu_class title items =
  Loon.Sidebar.group
    ?class_
    [ Loon.Sidebar.group_label ~class_:"font-medium text-muted-foreground" [ Node.text title ]
    ; Loon.Sidebar.group_content [ Loon.Sidebar.menu ?class_:menu_class items ]
    ]
;;

let docs_sidebar ~current =
  Node.div
    ~attrs:
      [ Attr.create "data-slot" "sidebar"
      ; Attr.class_
          (Cn.cn
             [ "flex h-full w-(--sidebar-width) flex-col bg-sidebar text-sidebar-foreground"
             ; "sticky top-[calc(var(--header-height)+0.6rem)] z-30 hidden \
                h-[calc(100svh-10rem)] overflow-hidden overscroll-none bg-transparent \
                [--sidebar-menu-width:--spacing(56)] lg:flex"
             ])
      ]
    [ Node.div
        ~attrs:
          [ Attr.class_
              "absolute top-12 right-2 bottom-0 hidden h-full w-px \
               bg-[linear-gradient(to_bottom,transparent_0%,var(--border)_10%,var(--border)_90%,transparent_100%)] \
               lg:flex"
          ]
        []
    ; Loon.Sidebar.content
        ~attrs:[ Attr.create "data-docs-sidebar-content" "" ]
        ~class_:
          "w-(--sidebar-menu-width) scroll-fade scrollbar-none overflow-x-hidden pl-2.5"
        (sidebar_group
           ~class_:"pt-12"
           "Sections"
           (List.map top_level_sections ~f:(fun (name, slug) ->
              sidebar_link ~current ~slug name))
         :: List.map docs_groups ~f:(fun (s, ps) ->
           sidebar_group
             ~menu_class:"gap-0.5"
             (Doc.Section.title s)
             (List.map ps ~f:(fun (p : Doc.Page.t) ->
                sidebar_link ~current ~slug:p.slug p.title))))
    ]
;;

(* {1 Pages} *)

let toc ~slug outline =
  match outline with
  | [] -> Node.none
  | outline ->
    Node.div
      ~attrs:
        [ Attr.class_ "flex scroll-fade scrollbar-none flex-col gap-8 overflow-y-auto px-8" ]
      [ Node.div
          ~attrs:
            [ Attr.create "data-slot" "toc"
            ; Attr.class_ "flex flex-col gap-2 p-4 pt-0 text-sm"
            ]
          (Node.p
             ~attrs:
               [ Attr.class_ "h-6 bg-background text-xs font-medium text-muted-foreground" ]
             [ Node.text "On This Page" ]
           :: List.map outline ~f:(fun (id, title, level) ->
             Node.a
               ~attrs:
                 [ Attr.href (Route.to_hash (Page slug) ^ "/" ^ id)
                 ; Attr.create "data-slot" "toc-link"
                 ; Attr.create "data-target" id
                 ; Attr.create "data-active" "false"
                 ; Attr.create "data-depth" (Int.to_string level)
                 ; Attr.class_
                     "text-[0.8rem] text-muted-foreground no-underline transition-colors \
                      hover:text-foreground data-[active=true]:font-medium \
                      data-[active=true]:text-foreground data-[depth=3]:pl-4 \
                      data-[depth=4]:pl-6"
                 ]
               [ Node.text title ]))
      ]
;;

(* shadcn's ComponentPreviewTabs: the example, and below it the first lines
   of its source under a "View Code" button that shows all of it. The
   preview grows with the example (no inner scrolling), and nothing around
   it makes a containing block or stacking context, so overlays positioned
   fixed escape it. *)
let component_preview ?(heading = true) ~level (example : Doc.Example.t) (local_ graph) =
  let preview = example.view graph in
  let code_visible, set_code_visible = Bonsai.state false graph in
  let%arr preview and code_visible and set_code_visible in
  let id = Doc.anchor example.title in
  let source_preview =
    List.take (String.split_lines example.source) 3 |> String.concat ~sep:"\n"
  in
  let figure source = Code_block.view ~class_:"[&>pre]:max-h-96" source in
  let title =
    if not heading
    then []
    else
      [ (match level with
         | `H2 -> Node.h2
         | `H3 -> Node.h3)
          ~attrs:[ Attr.id id; Attr.create "data-outline" example.title ]
          [ Node.text example.title ]
      ]
  in
  Node.div
    ~attrs:[ Attr.create "data-slot" "example"; Attr.create "data-example" id ]
    (title
     @ (match example.description with
        | None -> []
        | Some d -> [ Node.p (Doc.inline d) ])
     @ [ Node.div
           ~attrs:
             [ Attr.create "data-slot" "component-preview"
             ; Attr.create "data-not-typeset" ""
             ; Attr.class_
                 "group relative mt-4 mb-12 flex flex-col overflow-hidden rounded-2xl border"
             ]
           [ Node.div
               ~attrs:[ Attr.create "data-slot" "preview"; Attr.create "dir" "ltr" ]
               [ Node.div
                   ~attrs:
                     [ Attr.create "data-align" "center"
                     ; Attr.create "data-chromeless" "false"
                     ; Attr.class_
                         (Cn.cn
                            [ "preview relative flex h-72 w-full justify-center p-10 \
                               data-[align=center]:items-center \
                               data-[align=end]:items-start data-[align=start]:items-start \
                               data-[chromeless=true]:h-auto data-[chromeless=true]:p-0 \
                               sm:data-[align=end]:items-end"
                            ; "h-auto min-h-72"
                            ])
                     ]
                   [ preview ]
               ]
           ; Node.div
               ~attrs:
                 [ Attr.create "data-slot" "code"
                 ; Attr.create "data-mobile-code-visible" (Bool.to_string code_visible)
                 ; Attr.class_
                     "relative overflow-hidden **:data-[slot=copy-button]:right-4 \
                      **:data-[slot=copy-button]:hidden \
                      data-[mobile-code-visible=true]:**:data-[slot=copy-button]:flex \
                      [&_[data-rehype-pretty-code-figure]]:m-0! \
                      [&_[data-rehype-pretty-code-figure]]:rounded-t-none \
                      [&_[data-rehype-pretty-code-figure]]:border-t [&_pre]:max-h-72"
                 ]
               [ (if code_visible
                  then figure example.source
                  else
                    Node.div
                      ~attrs:[ Attr.class_ "relative" ]
                      [ figure source_preview
                      ; Node.div
                          ~attrs:
                            [ Attr.class_
                                "absolute inset-0 flex items-center justify-center pb-4"
                            ]
                          [ Node.div
                              ~attrs:
                                [ Attr.class_
                                    "absolute inset-0 \
                                     bg-[linear-gradient(to_top,var(--color-code),color-mix(in_oklab,var(--color-code)_60%,transparent),transparent)]"
                                ]
                              []
                          ; Button.view
                              ~size:Sm
                              ~variant:Outline
                              ~class_:
                                "relative z-10 rounded-lg bg-background text-foreground \
                                 shadow-none hover:bg-muted dark:bg-background \
                                 dark:text-foreground dark:hover:bg-muted"
                              ~attrs:[ Attr.create "data-docs" "view-code" ]
                              ~on_click:(set_code_visible true)
                              [ Node.text "View Code" ]
                          ]
                      ])
               ]
           ]
       ])
;;

(* The previous and next pages: along the sidebar's order. *)
let sidebar_order =
  List.filter_map top_level_sections ~f:(fun (_, slug) -> find_page slug)
  @ List.concat_map docs_groups ~f:snd
  |> List.stable_dedup ~compare:(fun (a : Doc.Page.t) b -> String.compare a.slug b.slug)
;;

let neighbours slug =
  let rec find prev = function
    | [] -> None, None
    | (p : Doc.Page.t) :: rest ->
      if String.equal p.slug slug then prev, List.hd rest else find (Some p) rest
  in
  find None sidebar_order
;;

let pager_icon_button ~dir (p : Doc.Page.t) =
  Button.link
    ~variant:Secondary
    ~size:Icon
    ~class_:"extend-touch-target size-8 shadow-none md:size-7"
    ~attrs:[ Attr.create "data-pager-icon" dir ]
    ~href:(href p.slug)
    (match dir with
     | "previous" -> [ Icon.view Arrow_left; sr_only "Previous" ]
     | _ -> [ sr_only "Next"; Icon.view Arrow_right ])
;;

let docs_page ~slug ~title ~description ~outline content =
  let prev, next = neighbours slug in
  let opt o ~f = Option.value_map o ~default:Node.none ~f in
  Node.div
    ~attrs:
      [ Attr.create "data-slot" "docs"
      ; Attr.class_
          "flex scroll-mt-24 items-stretch pb-8 text-[1.05rem] sm:text-[15px] xl:w-full"
      ]
    [ Node.div
        ~attrs:[ Attr.class_ "flex min-w-0 flex-1 flex-col" ]
        [ Node.div ~attrs:[ Attr.class_ "h-(--top-spacing) shrink-0" ] []
        ; Node.div
            ~attrs:
              [ Attr.create "data-page" slug
              ; Attr.class_
                  "mx-auto flex w-full max-w-160 min-w-0 flex-1 flex-col gap-6 px-4 py-6 \
                   text-foreground md:px-0 lg:py-8 dark:text-foreground"
              ]
            [ Node.div
                ~attrs:[ Attr.class_ "flex flex-col gap-2" ]
                [ Node.div
                    ~attrs:[ Attr.class_ "flex flex-col gap-2" ]
                    [ Node.div
                        ~attrs:
                          [ Attr.class_ "flex items-center justify-between md:items-start" ]
                        [ Node.h1
                            ~attrs:
                              [ Attr.class_
                                  "scroll-m-24 text-3xl font-semibold tracking-tight \
                                   sm:text-3xl"
                              ]
                            [ Node.text title ]
                        ; Node.div
                            ~attrs:[ Attr.class_ "docs-nav flex items-center gap-2" ]
                            [ Node.div
                                ~attrs:[ Attr.class_ "ml-auto flex gap-2" ]
                                [ opt prev ~f:(pager_icon_button ~dir:"previous")
                                ; opt next ~f:(pager_icon_button ~dir:"next")
                                ]
                            ]
                        ]
                    ; Node.p
                        ~attrs:
                          [ Attr.class_
                              "text-[1.05rem] text-muted-foreground sm:text-base \
                               sm:text-balance md:max-w-[80%]"
                          ]
                        description
                    ]
                ]
            ; Node.div
                ~attrs:
                  [ Attr.class_
                      "typeset w-full flex-1 pb-16 *:data-[slot=alert]:first:mt-0 sm:pb-0"
                  ]
                content
            ; Node.div
                ~attrs:
                  [ Attr.create "data-slot" "docs-pager"
                  ; Attr.class_ "hidden h-16 w-full items-center gap-2 px-4 sm:flex sm:px-0"
                  ]
                [ opt prev ~f:(fun p ->
                    Button.link
                      ~variant:Secondary
                      ~size:Sm
                      ~class_:"shadow-none"
                      ~attrs:[ Attr.create "data-pager" "previous" ]
                      ~href:(href p.slug)
                      [ Icon.view Arrow_left; Node.text p.title ])
                ; opt next ~f:(fun p ->
                    Button.link
                      ~variant:Secondary
                      ~size:Sm
                      ~class_:"ml-auto shadow-none"
                      ~attrs:[ Attr.create "data-pager" "next" ]
                      ~href:(href p.slug)
                      [ Node.text p.title; Icon.view Arrow_right ])
                ]
            ]
        ]
    ; Node.div
        ~attrs:
          [ Attr.class_
              "sticky top-[calc(var(--header-height)+1px)] z-30 ml-auto hidden h-[90svh] \
               w-(--sidebar-width) flex-col gap-4 overflow-hidden overscroll-none pb-8 \
               xl:flex"
          ]
        [ Node.div ~attrs:[ Attr.class_ "h-(--top-spacing) shrink-0" ] []; toc ~slug outline ]
    ]
;;

let is_component_page (page : Doc.Page.t) =
  not (Doc.Section.equal page.section Get_started)
;;

(* A component's page, as shadcn's mdx: the first example (its demo) under
   the description, then Installation, Usage, the other examples under
   Examples, and the page's body (its API reference). *)
let page_content (page : Doc.Page.t) (local_ graph) =
  let component = is_component_page page in
  let examples =
    List.mapi page.examples ~f:(fun i e ->
      if component && i = 0
      then component_preview ~heading:false ~level:`H2 e graph
      else component_preview ~level:(if component then `H3 else `H2) e graph)
    |> Bonsai.all
  in
  let install, set_install = Bonsai.state "loon" graph in
  let%arr examples and install and set_install in
  let demo, rest =
    match component, examples with
    | true, demo :: rest -> [ demo ], rest
    | _ -> [], examples
  in
  demo
  @ (if component
     then
       [ Doc.h2 "Installation"
       ; Code_block.command
           ~id:("install-" ^ page.slug)
           ~value:install
           ~on_change:set_install
           [ "loon", "loon add " ^ page.slug ]
       ]
     else [])
  @ (match page.usage with
     | None -> []
     | Some usage -> [ Doc.h2 "Usage"; Code_block.view usage ])
  @ (match rest with
     | [] -> []
     | rest -> if component then Doc.h2 "Examples" :: rest else rest)
  @ page.body
;;

(* shadcn's /docs/components: every component, in columns. *)
let components_index =
  Node.div
    ~attrs:
      [ Attr.class_
          "grid grid-cols-2 gap-x-8 gap-y-4 sm:grid-cols-3 sm:gap-x-12 lg:gap-x-16 \
           xl:gap-x-20"
      ]
    (List.map (in_section Components) ~f:(fun (p : Doc.Page.t) ->
       Node.a
         ~attrs:
           [ Attr.href (href p.slug)
           ; Attr.create "data-slug" p.slug
           ; Attr.class_ "text-lg font-medium underline-offset-4 hover:underline md:text-base"
           ]
         [ Node.text p.title ]))
;;

(* A page of a section outside the docs (Blocks, Charts, ...): shadcn's page
   header, the section's pages in a bar (when there are several), then the
   page's examples and body. *)
let section_page (page : Doc.Page.t) (local_ graph) =
  let examples =
    List.map page.examples ~f:(fun e -> component_preview ~level:`H2 e graph)
    |> Bonsai.all
  in
  let%arr examples in
  let siblings = in_section page.section in
  Node.div
    ~attrs:[ Attr.class_ "flex flex-1 flex-col"; Attr.create "data-page" page.slug ]
    [ Site.page_header
        ~title:page.title
        ~description:(Doc.inline page.description)
        ()
    ; (match siblings with
       | [] | [ _ ] -> Node.none
       | siblings ->
         Node.div
           ~attrs:[ Attr.id "section-nav"; Attr.class_ "container-wrapper scroll-mt-24" ]
           [ Node.div
               ~attrs:
                 [ Attr.class_ "container flex items-center justify-between gap-4 py-4" ]
               [ Node.div
                   ~attrs:
                     [ Attr.class_
                         "no-scrollbar flex max-w-full items-center gap-1 overflow-x-auto"
                     ]
                   (List.map siblings ~f:(fun (p : Doc.Page.t) ->
                      Node.a
                        ~attrs:
                          [ Attr.href (href p.slug)
                          ; Attr.create "data-slug" p.slug
                          ; Attr.create
                              "data-active"
                              (Bool.to_string (String.equal p.slug page.slug))
                          ; Attr.class_
                              "flex h-7 shrink-0 items-center justify-center px-4 \
                               text-center text-base font-medium text-muted-foreground \
                               transition-colors hover:text-primary \
                               data-[active=true]:text-primary"
                          ]
                        [ Node.text p.title ]))
               ]
           ])
    ; Node.div
        ~attrs:[ Attr.class_ "container-wrapper section-soft flex-1 pb-6" ]
        [ Node.div ~attrs:[ Attr.class_ "container typeset" ] (examples @ page.body) ]
    ]
;;

let not_found =
  Node.div
    ~attrs:[ Attr.class_ "flex flex-1 flex-col"; Attr.create "data-page" "" ]
    [ Site.page_header
        ~title:"Page not found"
        ~description:
          [ Node.text "That page has flown off. Try the search, or start from the home page."
          ]
        ~actions:[ Button.link ~href:"#/" [ Icon.view Arrow_left; Node.text "Back home" ] ]
        ()
    ]
;;

(* {1 Search} *)

module Result = struct
  type t =
    { title : string
    ; group : string
    ; hash : string
    ; kind : [ `Nav | `Page | `Component | `Example ]
    }
end

let search_items =
  List.map nav_items ~f:(fun (label, s) ->
    { Result.title = label; group = "Pages"; hash = section_href s; kind = `Nav })
  @ List.map sidebar_order ~f:(fun (p : Doc.Page.t) ->
    { Result.title = p.title
    ; group = Doc.Section.title p.section
    ; hash = href p.slug
    ; kind = (if is_component_page p then `Component else `Page)
    })
  @ List.concat_map pages ~f:(fun (p : Doc.Page.t) ->
    List.map p.examples ~f:(fun (e : Doc.Example.t) ->
      { Result.title = e.title
      ; group = "Examples"
      ; hash = Route.to_hash (Page p.slug) ^ "/" ^ Doc.anchor e.title
      ; kind = `Example
      }))
;;

let group_order = [ "Pages"; "Get Started"; "Components"; "Forms"; "Examples" ]

(* The results in their groups, in the groups' order (as cmdk), best first
   within each. An empty query lists the pages. *)
let search_results query =
  let results =
    if String.is_empty (String.strip query)
    then
      List.filter search_items ~f:(fun r ->
        match r.kind with
        | `Example -> false
        | `Nav | `Page | `Component -> true)
    else
      Search.rank ~query search_items ~fields:(fun (r : Result.t) ->
        [ r.title; r.group ^ " " ^ r.title ])
      |> fun l -> List.take l 30
  in
  List.filter_map group_order ~f:(fun g ->
    match List.filter results ~f:(fun r -> String.equal r.group g) with
    | [] -> None
    | rs -> Some (g, rs))
;;

let flat_results query = List.concat_map (search_results query) ~f:snd

(* Moves the search's selection: from the query as it is when the key is
   handled, not as last drawn, so that keys typed faster than frames count. *)
let move_selection (query, selected) delta =
  let count = List.length (flat_results query) in
  if count = 0
  then query, 0
  else query, (Int.clamp_exn selected ~min:0 ~max:(count - 1) + delta + count) % count
;;

let command_kbd children =
  Node.kbd
    ~attrs:
      [ Attr.class_
          "pointer-events-none flex h-5 items-center justify-center gap-1 rounded border \
           bg-background px-1 font-sans text-[0.7rem] font-medium text-muted-foreground \
           select-none [&_svg:not([class*='size-'])]:size-3"
      ]
    children
;;

let search_item ~selected ~set_selected ~go i (r : Result.t) =
  let is_selected = i = selected in
  Node.div
    ~attrs:
      [ Attr.id (sprintf "docs-search-%d" i)
      ; Attr.create "cmdk-item" ""
      ; Attr.create "role" "option"
      ; Attr.create "data-slot" "command-item"
      ; Attr.create "data-hash" r.hash
      ; Attr.create "aria-selected" (Bool.to_string is_selected)
      ; Attr.create "data-selected" (Bool.to_string is_selected)
      ; Attr.class_
          (Cn.cn
             [ "relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 \
                text-sm outline-hidden select-none data-[disabled=true]:pointer-events-none \
                data-[disabled=true]:opacity-50 data-[selected=true]:bg-accent \
                data-[selected=true]:text-accent-foreground [&_svg]:pointer-events-none \
                [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 \
                [&_svg:not([class*='text-'])]:text-muted-foreground"
             ; "h-9 rounded-md border border-transparent px-3! font-medium \
                data-[selected=true]:border-input data-[selected=true]:bg-input/50"
             ])
      ; Attr.on_click (fun _ -> go r.hash)
      ; Attr.on_mousemove (fun _ -> if is_selected then Effect.Ignore else set_selected i)
      ]
    [ (match r.kind with
       | `Component ->
         Node.div
           ~attrs:
             [ Attr.class_
                 "aspect-square size-4 rounded-full border border-dashed \
                  border-muted-foreground"
             ]
           []
       | `Nav | `Page -> Icon.view Arrow_right
       | `Example -> Icon.view Square_dashed)
    ; Node.span ~attrs:[ Attr.create "data-slot" "command-item-title" ] [ Node.text r.title ]
    ]
;;

(* shadcn's CommandMenu: a Command in a Dialog (with no overlay; a click
   outside closes it). *)
let search_dialog ~query ~set_query ~selected ~set_selected ~move ~close ~go =
  let groups = search_results query in
  let flat = List.concat_map groups ~f:snd in
  let count = List.length flat in
  let selected =
    if count = 0 then 0 else Int.clamp_exn selected ~min:0 ~max:(count - 1)
  in
  let on_keydown ev =
    match Loon.Dom_util.key ev with
    | ArrowDown -> Effect.Many [ Loon.Dom_util.prevent_default ev; move 1 ]
    | ArrowUp -> Effect.Many [ Loon.Dom_util.prevent_default ev; move (-1) ]
    | Enter ->
      (match List.nth flat selected with
       | None -> Effect.Ignore
       | Some r -> Effect.Many [ Loon.Dom_util.prevent_default ev; go r.hash ])
    | Escape -> Effect.Many [ Loon.Dom_util.prevent_default ev; close ]
    | _ -> Effect.Ignore
  in
  let _, groups =
    List.fold_map groups ~init:0 ~f:(fun start (heading, rs) ->
      ( start + List.length rs
      , Node.div
          ~attrs:
            [ Attr.create "data-slot" "command-group"
            ; Attr.create "cmdk-group" ""
            ; Attr.class_
                (Cn.cn
                   [ "overflow-hidden p-1 text-foreground [&_[cmdk-group-heading]]:px-2 \
                      [&_[cmdk-group-heading]]:py-1.5 [&_[cmdk-group-heading]]:text-xs \
                      [&_[cmdk-group-heading]]:font-medium \
                      [&_[cmdk-group-heading]]:text-muted-foreground"
                   ; "p-0! **:[[cmdk-group-heading]]:scroll-mt-16 \
                      **:[[cmdk-group-heading]]:p-3! **:[[cmdk-group-heading]]:pb-1!"
                   ])
            ]
          [ Node.div
              ~attrs:[ Attr.create "cmdk-group-heading" ""; Attr.create "aria-hidden" "true" ]
              [ Node.text heading ]
          ; Node.div
              ~attrs:[ Attr.create "role" "group"; Attr.create "aria-label" heading ]
              (List.mapi rs ~f:(fun i r ->
                 search_item ~selected ~set_selected ~go (start + i) r))
          ] ))
  in
  Node.div
    ~attrs:[ Attr.create "data-slot" "dialog-portal" ]
    [ Node.div
        ~attrs:
          [ Attr.create "data-slot" "dialog-overlay"
          ; Attr.create "data-state" "open"
          ; Attr.class_ "fixed inset-0 z-50"
          ; Attr.on_click (fun _ -> close)
          ]
        []
    ; Node.div
        ~attrs:
          [ Attr.create "data-slot" "dialog-content"
          ; Attr.create "data-state" "open"
          ; Attr.create "role" "dialog"
          ; Attr.create "aria-modal" "true"
          ; Attr.create "aria-labelledby" "docs-search-title"
          ; Attr.class_
              (Cn.cn
                 [ "fixed top-[15%] left-[50%] z-50 grid w-full max-w-[calc(100%-2rem)] \
                    translate-x-[-50%] gap-4 rounded-lg border bg-background p-6 shadow-lg \
                    duration-200 outline-none sm:max-w-lg"
                 ; "rounded-xl border-none bg-clip-padding p-2 pb-11 shadow-2xl ring-4 \
                    ring-neutral-200/80 dark:bg-neutral-900 dark:ring-neutral-800"
                 ])
          ]
        [ Node.div
            ~attrs:[ Attr.class_ "sr-only" ]
            [ Node.h2
                ~attrs:[ Attr.id "docs-search-title" ]
                [ Node.text "Search documentation..." ]
            ; Node.p [ Node.text "Search for a command to run..." ]
            ]
        ; Node.div
            ~attrs:
              [ Attr.create "data-slot" "command"
              ; Attr.class_
                  (Cn.cn
                     [ "flex h-full w-full flex-col overflow-hidden rounded-md bg-popover \
                        text-popover-foreground"
                     ; "rounded-none bg-transparent **:data-[slot=command-input]:h-9! \
                        **:data-[slot=command-input]:py-0 \
                        **:data-[slot=command-input-wrapper]:mb-0 \
                        **:data-[slot=command-input-wrapper]:h-9! \
                        **:data-[slot=command-input-wrapper]:rounded-md \
                        **:data-[slot=command-input-wrapper]:border \
                        **:data-[slot=command-input-wrapper]:border-input \
                        **:data-[slot=command-input-wrapper]:bg-input/50"
                     ])
              ]
            [ Node.div
                ~attrs:[ Attr.class_ "relative" ]
                [ Node.div
                    ~attrs:
                      [ Attr.create "data-slot" "command-input-wrapper"
                      ; Attr.class_ "flex h-9 items-center gap-2 border-b px-3"
                      ]
                    [ Icon.view ~class_:"size-4 shrink-0 opacity-50" Search
                    ; Node.input
                        ~attrs:
                          [ Attr.id "docs-search-input"
                          ; Attr.create "data-slot" "command-input"
                          ; Attr.type_ "text"
                          ; Attr.class_
                              "flex h-10 w-full rounded-md bg-transparent py-3 text-sm \
                               outline-hidden placeholder:text-muted-foreground \
                               disabled:cursor-not-allowed disabled:opacity-50"
                          ; Attr.placeholder "Search documentation..."
                          ; Attr.create "autocomplete" "off"
                          ; Attr.create "spellcheck" "false"
                          ; Attr.create "role" "combobox"
                          ; Attr.create "aria-expanded" "true"
                          ; Attr.create "aria-controls" "docs-search-results"
                          ; Attr.create
                              "aria-activedescendant"
                              (sprintf "docs-search-%d" selected)
                          ; Attr.value query
                          ; Attr.on_input (fun _ q -> set_query q)
                          ; Attr.on_keydown on_keydown
                          ]
                        ()
                    ]
                ]
            ; Node.div
                ~attrs:
                  [ Attr.id "docs-search-results"
                  ; Attr.create "data-slot" "command-list"
                  ; Attr.create "role" "listbox"
                  ; Attr.class_
                      (Cn.cn
                         [ "max-h-[300px] scroll-py-1 overflow-x-hidden overflow-y-auto"
                         ; "no-scrollbar min-h-80 scroll-pt-2 scroll-pb-1.5"
                         ])
                  ]
                (match groups with
                 | [] ->
                   [ Node.div
                       ~attrs:
                         [ Attr.create "data-slot" "command-empty"
                         ; Attr.class_ "py-12 text-center text-sm text-muted-foreground"
                         ]
                       [ Node.text "No results found." ]
                   ]
                 | groups -> groups)
            ]
        ; Node.div
            ~attrs:
              [ Attr.class_
                  "absolute inset-x-0 bottom-0 z-20 flex h-10 items-center gap-2 \
                   rounded-b-xl border-t border-t-neutral-100 bg-neutral-50 px-4 text-xs \
                   font-medium text-muted-foreground dark:border-t-neutral-700 \
                   dark:bg-neutral-800"
              ]
            [ Node.div
                ~attrs:[ Attr.class_ "flex items-center gap-2" ]
                [ command_kbd [ Icon.view Corner_down_left ]; Node.text "Go to Page" ]
            ]
        ]
    ]
;;

(* {1 The app} *)

let mode_name : Loon.Theme.Mode.t -> string = function
  | Light -> "light"
  | Dark -> "dark"
;;

let title_of (shown : Shown.t) =
  match shown with
  | Home -> "loon - The Foundation for your Design System"
  | Not_found -> "Not found - loon"
  | Page slug when String.equal slug components_slug -> "Components - loon"
  | Page slug ->
    (match find_page slug with
     | Some p -> p.title ^ " - loon"
     | None -> "loon")
;;

let docs_layout ~current content =
  Node.div
    ~attrs:[ Attr.class_ "container-wrapper flex flex-1 flex-col px-2" ]
    [ Node.div
        ~attrs:
          [ Attr.create "data-slot" "sidebar-wrapper"
          ; Attr.__css_vars_no_kebabs
              [ "--sidebar-width", "calc(var(--spacing) * 72)"
              ; "--sidebar-width-icon", "3rem"
              ]
          ; Attr.class_
              (Cn.cn
                 [ "group/sidebar-wrapper flex min-h-svh w-full \
                    has-data-[variant=inset]:bg-sidebar"
                 ; "min-h-min flex-1 items-start px-0 [--top-spacing:0] lg:grid \
                    lg:grid-cols-[var(--sidebar-width)_minmax(0,1fr)] \
                    lg:[--top-spacing:calc(var(--spacing)*4)] 3xl:fixed:container \
                    3xl:fixed:px-3"
                 ])
          ]
        [ docs_sidebar ~current
        ; Node.div ~attrs:[ Attr.class_ "h-full w-full" ] [ content ]
        ]
    ]
;;

let main_view (shown : Shown.t) ~outline (local_ graph) =
  match shown with
  | Home -> Home.view graph
  | Not_found -> Bonsai.return not_found
  | Page slug when String.equal slug components_slug ->
    Bonsai.return
      (docs_layout
         ~current:slug
         (docs_page
            ~slug
            ~title:"Components"
            ~description:
              [ Node.text
                  "Here you can find all the components available in the library. We are \
                   working on adding more components."
              ]
            ~outline:[]
            [ components_index ]))
  | Page slug ->
    (match find_page slug with
     | None -> Bonsai.return not_found
     | Some page when not (Doc.Section.is_docs page.section) -> section_page page graph
     | Some page ->
       let content = page_content page graph in
       let%arr content and outline in
       docs_layout
         ~current:slug
         (docs_page
            ~slug
            ~title:page.title
            ~description:(Doc.inline page.description)
            ~outline
            content))
;;

let component (local_ graph) =
  let hash_var = Bonsai.Expert.Var.create (Browser.hash ()) in
  Browser.on_hash_change (fun h -> Bonsai.Expert.Var.set hash_var h);
  Browser.install_scroll_spy ();
  let hash = Bonsai.Expert.Var.value hash_var in
  let shown = Bonsai.map hash ~f:Shown.of_hash in
  let initial_mode =
    match Browser.get_item "loon-docs-mode" with
    | Some "dark" -> Loon.Theme.Mode.Dark
    | Some "light" -> Light
    | _ -> Loon.Theme.Mode.preferred ()
  in
  let mode, set_mode = Bonsai.state initial_mode graph in
  let nav_open, set_nav_open = Bonsai.state false graph in
  let search_open, set_search_open = Bonsai.state false graph in
  let search, update_search = Bonsai.state' ("", 0) graph in
  let query = search >>| fst in
  let selected = search >>| snd in
  let set_query =
    let%arr update_search in
    fun q -> update_search (fun _ -> q, 0)
  in
  let set_selected =
    let%arr update_search in
    fun i -> update_search (fun (q, _) -> q, i)
  in
  let move_selected =
    let%arr update_search in
    fun delta -> update_search (fun m -> move_selection m delta)
  in
  let outline, set_outline = Bonsai.state [] graph in
  (* The document follows the theme: the class [dark] on <html>. *)
  Bonsai.Edge.on_change
    ~trigger:`Before_display
    ~equal:[%equal: Loon.Theme.Mode.t]
    mode
    ~callback:
      (Bonsai.return (fun mode ->
         Effect.of_thunk (fun () -> Browser.set_root_theme ~mode:(mode_name mode))))
    graph;
  Bonsai.Edge.on_change'
    ~trigger:`After_display
    ~equal:String.equal
    hash
    ~callback:
      (let%arr set_nav_open and set_search_open in
       fun prev hash ->
         let shown = Shown.of_hash hash in
         let same_page =
           Option.value_map prev ~default:false ~f:(fun p ->
             Shown.equal (Shown.of_hash p) shown)
         in
         Effect.Many
           [ set_nav_open false
           ; set_search_open false
           ; Effect.of_thunk (fun () ->
               Browser.set_title (title_of shown);
               Browser.reveal_current_nav ();
               match Route.anchor hash with
               | Some id -> Browser.scroll_to_anchor id
               | None -> if not same_page then Browser.scroll_to_top ())
           ])
    graph;
  (* The outline is read from the page drawn: after each frame whose page is
     not the one last outlined (in WebKit, the page's first frame after a
     change of hash may still show the old one). *)
  let outlined, set_outlined = Bonsai.state "" graph in
  Bonsai.Edge.after_display
    (let%arr outlined and set_outlined and set_outline in
     let%bind.Effect page = Effect.of_thunk Browser.article_page in
     match page with
     | Some page when not (String.equal page outlined) ->
       let%bind.Effect outline = Effect.of_thunk Browser.outline in
       Effect.Many
         [ set_outlined page; set_outline outline; Effect.of_thunk Browser.update_scroll_spy ]
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
  let main =
    Bonsai.enum
      (module Shown)
      ~match_:shown
      ~with_:(fun shown (local_ graph) -> main_view shown ~outline graph)
      graph
  in
  let%arr main
  and shown
  and mode
  and set_mode
  and nav_open
  and set_nav_open
  and search_open
  and set_search_open
  and query
  and set_query
  and selected
  and set_selected
  and move_selected
  and open_search in
  let toggle_mode =
    let m = Loon.Theme.Mode.toggle mode in
    Effect.Many
      [ set_mode m
      ; Effect.of_thunk (fun () -> Browser.set_item "loon-docs-mode" (mode_name m))
      ]
  in
  let go hash =
    Effect.Many [ set_search_open false; Effect.of_thunk (fun () -> Browser.set_hash hash) ]
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
      | _ -> Effect.Ignore)
  in
  Node.div
    ~attrs:
      [ Attr.create "data-slot" "layout"
      ; Attr.class_ "group/layout relative z-10 flex min-h-svh flex-col bg-background"
      ; global_keys
      ]
    [ site_header
        ~section:(Shown.section shown)
        ~mobile_open:nav_open
        ~set_mobile_open:set_nav_open
        ~open_search
        ~toggle_mode
    ; Node.main ~attrs:[ Attr.id "main"; Attr.class_ "flex min-h-0 flex-1 flex-col" ] [ main ]
    ; site_footer
    ; (if search_open
       then
         search_dialog
           ~query
           ~set_query
           ~selected
           ~set_selected
           ~move:move_selected
           ~close:(set_search_open false)
           ~go
       else Node.none)
    ]
;;
