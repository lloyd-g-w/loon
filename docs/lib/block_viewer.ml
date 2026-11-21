open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Js_of_ocaml
module Node = Vdom.Node
module Attr = Vdom.Attr
module Block = Loon_blocks.Block
module Icon = Loon.Icon

let prefix = "#/blocks/"
let hash (block : Block.t) = prefix ^ block.name

let block_of_hash hash =
  match String.chop_prefix hash ~prefix with
  | None -> None
  | Some rest ->
    String.take_while rest ~f:(fun c -> not (Char.equal c '/' || Char.equal c '?'))
    |> Block.find
;;

(* The frame's URL: this page with a query of its own (a frame may not
   load its parent's URL), changed to reload it. *)
let frame_src (block : Block.t) ~reload = sprintf "?view=%d%s" reload (hash block)

let page_slug = function
  | None -> "blocks"
  | Some c -> "blocks-" ^ Block.Category.slug c
;;

let nav ~page =
  Node.div
    ~attrs:[ Attr.class_ "relative overflow-hidden" ]
    [ Node.div
        ~attrs:[ Attr.class_ "flex items-center overflow-x-auto" ]
        (List.filter_map
           (None :: List.map Block.Category.all ~f:Option.some)
           ~f:(fun category ->
             match category with
             | Some c when Block.Category.hidden c -> None
             | _ ->
               let slug = page_slug category in
               let name = Option.value_map category ~default:"Featured" ~f:Block.Category.name in
               Some
                 (Node.a
                    ~attrs:
                      [ Attr.href ("#/" ^ slug)
                      ; Attr.class_
                          "flex h-7 items-center justify-center px-4 text-center \
                           text-base font-medium text-muted-foreground \
                           transition-colors hover:text-primary \
                           data-[active=true]:text-primary"
                      ; Attr.create "data-active" (Bool.to_string (String.equal slug page))
                      ]
                    [ Node.text name ])))
    ]
;;

let files (block : Block.t) =
  let m = Block.module_name block in
  List.filter Block_sources.all ~f:(fun (file, _) ->
    String.equal file (m ^ ".ml") || String.is_prefix file ~prefix:(m ^ "_"))
;;

module View = struct
  type t =
    | Preview
    | Code
  [@@deriving sexp_of, compare, equal]

  let name = function
    | Preview -> "preview"
    | Code -> "code"
  ;;
end

let full_layout = [ 100.; 0. ]

let sizes =
  [ "100%", 100., Icon.Monitor, "Desktop"
  ; "60%", 60., Tablet, "Tablet"
  ; "30%", 30., Smartphone, "Mobile"
  ]
;;

let viewer ~page (block : Block.t) (local_ graph) =
  let view, set_view = Bonsai.state View.Preview graph in
  let layout, set_layout = Bonsai.state full_layout graph in
  let reload, set_reload = Bonsai.state 0 graph in
  let size, set_size = Bonsai.state (Some "100%") graph in
  let files = files block in
  let active, set_active =
    Bonsai.state (List.hd files |> Option.value_map ~default:"" ~f:fst) graph
  in
  let sidebar =
    Loon.Sidebar.create
      ~persist:false
      ~open_:true
      ~on_open_change:(fun _ -> Effect.Ignore)
      ~open_mobile:false
      ~on_open_mobile_change:(fun _ -> Effect.Ignore)
      ~is_mobile:false
      ()
  in
  let%arr view
  and set_view
  and layout
  and set_layout
  and reload
  and set_reload
  and size
  and set_size
  and active
  and set_active in
  let description = String.chop_suffix_if_exists block.description ~suffix:"." in
  let separator ?(class_ = "h-4!") () =
    Loon.Separator.view ~orientation:Vertical ~class_ ()
  in
  let toolbar =
    Node.div
      ~attrs:[ Attr.class_ "hidden w-full items-center gap-2 pl-2 md:pr-6 lg:flex" ]
      [ Loon.Tabs.view
          ~id:("block-" ^ block.name)
          ~value:(View.name view)
          ~on_change:(fun v ->
            set_view (if String.equal v "code" then View.Code else Preview))
          (fun tabs ->
             [ Loon.Tabs.list
                 ~class_:
                   "grid h-8! grid-cols-2 items-center rounded-lg p-1 \
                    *:data-[slot=tabs-trigger]:h-6 \
                    *:data-[slot=tabs-trigger]:rounded-sm \
                    *:data-[slot=tabs-trigger]:px-2 \
                    *:data-[slot=tabs-trigger]:text-xs"
                 tabs
                 [ Loon.Tabs.trigger ~value:"preview" [ Node.text "Preview" ]
                 ; Loon.Tabs.trigger ~value:"code" [ Node.text "Code" ]
                 ]
             ])
      ; separator ~class_:"mx-2 h-4!" ()
      ; Node.a
          ~attrs:
            [ Attr.href (sprintf "#/%s/%s" page block.name)
            ; Attr.class_
                "flex-1 text-center text-sm font-medium underline-offset-2 \
                 hover:underline md:flex-auto md:text-left"
            ]
          [ Node.text description ]
      ; Node.div
          ~attrs:[ Attr.class_ "ml-auto flex items-center gap-2" ]
          [ Node.div
              ~attrs:
                [ Attr.class_
                    "h-8 items-center gap-1.5 rounded-md border p-[3px] shadow-none"
                ]
              [ Loon.Toggle_group.single
                  ~class_:
                    "gap-1 *:data-[slot=toggle-group-item]:size-6! \
                     *:data-[slot=toggle-group-item]:rounded-sm!"
                  ~value:size
                  ~on_change:(fun value ->
                    match value with
                    | None -> Effect.Ignore
                    | Some v ->
                      let percent =
                        List.find_map sizes ~f:(fun (s, p, _, _) ->
                          Option.some_if (String.equal s v) p)
                        |> Option.value ~default:100.
                      in
                      Effect.Many
                        [ set_size value
                        ; set_view Preview
                        ; set_layout [ percent; 100. -. percent ]
                        ])
                  (fun group ->
                     List.map sizes ~f:(fun (value, _, icon, title) ->
                       Loon.Toggle_group.item
                         ~attrs:[ Attr.title title; Attr.create "aria-label" title ]
                         group
                         ~value
                         [ Icon.view icon ])
                     @ [ separator ()
                       ; Loon.Button.link
                           ~size:Icon
                           ~variant:Ghost
                           ~class_:"size-6 rounded-sm p-0"
                           ~attrs:
                             [ Attr.title "Open in New Tab"
                             ; Attr.create "target" "_blank"
                             ]
                           ~href:(hash block)
                           [ Node.span
                               ~attrs:[ Attr.class_ "sr-only" ]
                               [ Node.text "Open in New Tab" ]
                           ; Icon.view Fullscreen
                           ]
                       ; separator ()
                       ; Loon.Button.view
                           ~size:Icon
                           ~variant:Ghost
                           ~class_:"size-6 rounded-sm p-0"
                           ~attrs:[ Attr.title "Refresh Preview" ]
                           ~on_click:(set_reload (reload + 1))
                           [ Icon.view Rotate_cw
                           ; Node.span
                               ~attrs:[ Attr.class_ "sr-only" ]
                               [ Node.text "Refresh Preview" ]
                           ]
                       ])
              ]
          ]
      ]
  in
  let frame =
    Node.create
      "iframe"
      ~attrs:
        [ Attr.src (frame_src block ~reload)
        ; Attr.title block.name
        ; Attr.create "loading" "lazy"
        ; Attr.create "height" block.iframe_height
        ; Attr.create "data-block" block.name
        ; Attr.class_ "relative z-20 no-scrollbar w-full bg-background"
        ]
      []
  in
  let preview =
    Node.div
      ~attrs:
        [ Attr.class_
            "h-(--height) group-data-[view=code]/block-view-wrapper:hidden lg:flex"
        ]
      [ Node.div
          ~attrs:[ Attr.class_ "relative grid w-full gap-4" ]
          [ Node.div
              ~attrs:
                [ Attr.class_
                    "absolute inset-0 right-4 \
                     [background-image:radial-gradient(#d4d4d4_1px,transparent_1px)] \
                     [background-size:20px_20px] \
                     dark:[background-image:radial-gradient(#404040_1px,transparent_1px)]"
                ]
              []
          ; Loon.Resizable.view
              ~id:("block-" ^ block.name)
              ~orientation:Horizontal
              ~layout
              ~on_layout_change:(fun l -> Effect.Many [ set_layout l; set_size None ])
              ~class_:
                "relative z-10 after:absolute after:inset-0 after:right-3 after:z-0 \
                 after:rounded-xl after:bg-muted/50"
              [ Loon.Resizable.panel
                  ~class_:
                    "relative overflow-hidden rounded-lg border bg-background \
                     md:rounded-xl"
                  ~default_size:100.
                  ~min_size:30.
                  [ frame ]
              ; Loon.Resizable.handle
                  ~class_:
                    "relative hidden w-3 bg-transparent p-0 after:absolute \
                     after:top-1/2 after:right-0 after:h-8 after:w-[6px] \
                     after:translate-x-[-1px] after:-translate-y-1/2 \
                     after:rounded-full after:bg-border after:transition-all \
                     after:hover:h-10 md:block"
                  ()
              ; Loon.Resizable.panel ~default_size:0. ~min_size:0. []
              ]
          ]
      ]
  in
  let code =
    let file = List.Assoc.find files active ~equal:String.equal in
    Node.div
      ~attrs:
        [ Attr.class_
            "mr-[14px] flex overflow-hidden rounded-xl border bg-muted/30 \
             group-data-[view=preview]/block-view-wrapper:hidden md:h-(--height)"
        ]
      [ Node.div
          ~attrs:[ Attr.class_ "w-72" ]
          [ Loon.Sidebar.provider
              ~keyboard_shortcut:false
              ~class_:"flex min-h-full! flex-col border-r"
              sidebar
              [ Loon.Sidebar.root
                  ~collapsible:None
                  ~class_:"w-full flex-1"
                  sidebar
                  [ Loon.Sidebar.group_label
                      ~class_:"h-12 rounded-none border-b px-4 text-sm"
                      [ Node.text "Files" ]
                  ; Loon.Sidebar.group
                      ~class_:"p-0"
                      [ Loon.Sidebar.group_content
                          [ Loon.Sidebar.menu
                              ~class_:"translate-x-0 gap-1.5"
                              (List.map files ~f:(fun (name, _) ->
                                 Loon.Sidebar.menu_item
                                   [ Loon.Sidebar.menu_button
                                       ~is_active:(String.equal name active)
                                       ~on_click:(set_active name)
                                       ~class_:
                                         "rounded-none pl-[1.3rem] whitespace-nowrap \
                                          hover:bg-muted-foreground/15 \
                                          focus:bg-muted-foreground/15 \
                                          focus-visible:bg-muted-foreground/15 \
                                          active:bg-muted-foreground/15 \
                                          data-[active=true]:bg-muted-foreground/15"
                                       [ Icon.view ~class_:"invisible" Chevron_right
                                       ; Icon.view ~class_:"h-4 w-4" File
                                       ; Node.text name
                                       ]
                                   ]))
                          ]
                      ]
                  ]
              ]
          ]
      ; Node.create
          "figure"
          ~attrs:
            [ Attr.class_ "mx-0! mt-0 flex min-w-0 flex-1 flex-col rounded-xl border-none"
            ]
          [ Node.create
              "figcaption"
              ~attrs:
                [ Attr.class_
                    "flex h-12 shrink-0 items-center gap-2 border-b px-4 py-2 \
                     [&_svg]:size-4 [&_svg]:opacity-70"
                ]
              [ Icon.view File_code
              ; Node.text active
              ; Node.div
                  ~attrs:[ Attr.class_ "ml-auto flex items-center gap-2" ]
                  [ Code_block.copy_button (Option.value file ~default:"")
                  ]
              ]
          ; Node.pre
              ~attrs:[ Attr.class_ "docs-pre no-scrollbar m-0 overflow-auto p-4 text-sm" ]
              [ Highlight.view (Option.value file ~default:"") ]
          ]
      ]
  in
  let mobile =
    Node.div
      ~attrs:[ Attr.class_ "flex flex-col gap-2 lg:hidden" ]
      [ Node.div
          ~attrs:[ Attr.class_ "flex items-center gap-2 px-2" ]
          [ Node.div
              ~attrs:[ Attr.class_ "line-clamp-1 text-sm font-medium" ]
              [ Node.text block.description ]
          ; Node.div
              ~attrs:
                [ Attr.class_ "ml-auto shrink-0 font-mono text-xs text-muted-foreground" ]
              [ Node.text block.name ]
          ]
      ]
  in
  Node.div
    ~attrs:
      [ Attr.id block.name
      ; Attr.create "data-view" (View.name view)
      ; Attr.class_
          "group/block-view-wrapper flex min-w-0 scroll-mt-24 flex-col-reverse \
           items-stretch gap-4 overflow-hidden md:flex-col"
      ; Attr.__css_vars_no_kebabs [ "--height", block.iframe_height ]
      ]
    [ toolbar
    ; (match view with
       | Preview -> preview
       | Code -> code)
    ; mobile
    ]
;;

let gallery ~page blocks (local_ graph) =
  let viewers =
    List.map blocks ~f:(fun block -> viewer ~page block graph) |> Bonsai.all
  in
  let%arr viewers in
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col gap-12 md:gap-24"; Attr.create "data-blocks" "" ]
    (nav ~page :: viewers
     @
     if String.equal page "blocks"
     then
       [ Node.div
           ~attrs:[ Attr.class_ "flex justify-center py-6" ]
           [ Loon.Button.link
               ~variant:Outline
               ~href:"#/blocks-sidebar"
               [ Node.text "Browse more blocks" ]
           ]
       ]
     else [])
;;

let mode_var =
  lazy
    (let initial () =
       match Browser.get_item "loon-docs-mode" with
       | Some "dark" -> Loon.Theme.Mode.Dark
       | Some "light" -> Light
       | _ -> Loon.Theme.Mode.preferred ()
     in
     let var = Bonsai.Expert.Var.create (initial ()) in
     if Browser.in_browser ()
     then
       ignore
         (Dom_html.addEventListener
            Dom_html.window
            (Dom_html.Event.make "storage")
            (Dom_html.handler (fun _ ->
               Bonsai.Expert.Var.set var (initial ());
               Js._true))
            Js._false
          : Dom_html.event_listener_id);
     var)
;;

let full_page (block : Block.t) (local_ graph) =
  let mode = Bonsai.Expert.Var.value (force mode_var) in
  Bonsai.Edge.on_change
    ~trigger:`Before_display
    ~equal:[%equal: Loon.Theme.Mode.t]
    mode
    ~callback:
      (Bonsai.return (fun (mode : Loon.Theme.Mode.t) ->
         Effect.of_thunk (fun () ->
           Browser.set_root_theme
             ~mode:
               (match mode with
                | Dark -> "dark"
                | Light -> "light");
           Browser.set_title (block.name ^ " · loon"))))
    graph;
  let view = block.view graph in
  let%arr view in
  Node.div
    ~attrs:
      [ Attr.class_
          (Loon.Cn.cn
             [ "bg-background *:data-[slot=card]:has-[[data-slot=chart]]:shadow-none"
             ; Option.value block.container ~default:""
             ])
      ; Attr.create "data-block-page" block.name
      ]
    [ view ]
;;
