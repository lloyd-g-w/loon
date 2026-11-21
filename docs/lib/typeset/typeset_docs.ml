open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Js_of_ocaml
module Node = Vdom.Node
module Attr = Vdom.Attr
module Button = Typeset_nova.Button
module Code = Typeset_code

let data name value = Attr.create ("data-" ^ name) value

let copy_to_clipboard text =
  Effect.of_thunk (fun () ->
    if Browser.in_browser ()
    then (
      try
        let clipboard = Js.Unsafe.get Dom_html.window##.navigator "clipboard" in
        if Js.Optdef.test clipboard
        then ignore (Js.Unsafe.meth_call clipboard "writeText" [| Js.Unsafe.inject (Js.string text) |] : Js.Unsafe.any)
      with
      | _ -> ()))
;;

(* A copy button showing a check for two seconds after it copies. *)
let copy_button ~copy ~label (text : string Bonsai.t) (local_ graph) =
  let copied, set_copied = Bonsai.state false graph in
  let sleep = Bonsai.Clock.sleep graph in
  let%arr copied and set_copied and sleep and text in
  Node.button
    ~attrs:
      [ Attr.type_ "button"
      ; data "slot" "button"
      ; Attr.class_ (Button.classes ~class_:"w-fit" Outline Sm)
      ; Attr.on_click (fun _ ->
          Effect.Many
            [ copy text
            ; set_copied true
            ; (let%bind.Effect () = sleep (Time_ns.Span.of_sec 2.) in
               set_copied false)
            ])
      ]
    [ Loon.Icon.view
        ~attrs:[ data "icon" "inline-start" ]
        (if copied then Check else Copy)
    ; Node.text label
    ]
;;

let section ~step ~title children =
  Node.section
    ~attrs:[ Attr.class_ "flex flex-col gap-2.5" ]
    (Node.h3
       ~attrs:[ Attr.class_ "text-sm font-medium" ]
       [ Node.text (sprintf "%d. %s" step title) ]
     :: children)
;;

let prose children =
  Node.p ~attrs:[ Attr.class_ "text-sm leading-relaxed text-muted-foreground" ] children
;;

let mono text = Node.code ~attrs:[ Attr.class_ "font-mono" ] [ Node.text text ]

let code ?(class_ = "") text =
  Node.div
    ~attrs:[ Attr.class_ "relative rounded-lg bg-muted/60" ]
    [ Node.pre
        ~attrs:
          [ Loon.Cn.attr
              [ "no-scrollbar overflow-x-auto p-3 font-mono text-sm leading-relaxed"
              ; class_
              ]
          ]
        [ Node.text text ]
    ]
;;

let package_manager_key = "loon-docs-package-manager"

let command ~package_manager ~set_package_manager text =
  Node.div
    ~attrs:[ Attr.class_ "rounded-lg bg-muted/60" ]
    [ Node.div
        ~attrs:[ Attr.class_ "flex items-center gap-3 px-3 pt-2" ]
        (List.map Code.Package_manager.all ~f:(fun pm ->
           Node.button
             ~attrs:
               [ Attr.type_ "button"
               ; data
                   "active"
                   (Bool.to_string (Code.Package_manager.equal pm package_manager))
               ; Attr.class_
                   "font-mono text-xs text-muted-foreground transition-colors \
                    hover:text-foreground data-[active=true]:text-foreground"
               ; Attr.on_click (fun _ -> set_package_manager pm)
               ]
             [ Node.text (Code.Package_manager.name pm) ]))
    ; Node.pre
        ~attrs:
          [ Attr.class_ "no-scrollbar overflow-x-auto p-3 font-mono text-xs leading-relaxed"
          ]
        [ Node.text (Code.Package_manager.command package_manager text) ]
    ]
;;

let content ?(copy = copy_to_clipboard) params (local_ graph) =
  let package_manager, set_package_manager =
    Bonsai.state
      (Option.bind (Browser.get_item package_manager_key) ~f:(fun s ->
         List.find Code.Package_manager.all ~f:(fun pm ->
           String.equal (Code.Package_manager.name pm) s))
       |> Option.value ~default:Code.Package_manager.Pnpm)
      graph
  in
  let set_package_manager =
    let%arr set_package_manager in
    fun pm ->
      Effect.Many
        [ set_package_manager pm
        ; Effect.of_thunk (fun () ->
            Browser.set_item package_manager_key (Code.Package_manager.name pm))
        ]
  in
  let framework_value, framework_picker =
    let picker =
      Loon.Select.component
        ~default_value:"next"
        (Bonsai.return (Loon.Select.trigger ~size:Sm ()))
        (Bonsai.return
           (Loon.Select.content
              ~position:Popper
              ~align:End
              [ Loon.Select.group
                  (List.map Code.Framework.all ~f:(fun f ->
                     Loon.Select.item
                       ~value:(Code.Framework.name f)
                       [ Node.text (Code.Framework.title f) ]))
              ]))
        graph
    in
    Bonsai.map picker ~f:fst, Bonsai.map picker ~f:snd
  in
  let framework =
    let%arr framework_value in
    Option.bind framework_value ~f:Code.Framework.of_name
    |> Option.value ~default:Code.Framework.Next
  in
  let prompt =
    let%arr params and framework in
    Code.prompt params framework
  in
  let copy_css =
    copy_button ~copy ~label:"Copy typeset.css" (Bonsai.return Typeset_css.css) graph
  in
  let copy_prompt = copy_button ~copy ~label:"Copy Prompt" prompt graph in
  Loon.Tabs.component
    ~class_:"flex min-h-0 flex-1 flex-col gap-0"
    ~default_value:"docs"
    (let%arr params
     and framework
     and framework_picker
     and prompt
     and copy_css
     and copy_prompt
     and package_manager
     and set_package_manager in
     fun tabs ->
       let fonts = Code.picked_fonts params in
       let fonts_step =
         match framework with
         | Next ->
           [ prose
               [ Node.text "Load the fonts with "
               ; mono "next/font"
               ; Node.text " in your root layout:"
               ]
           ; code (Code.next_font_code fonts)
           ]
         | _ ->
           [ command ~package_manager ~set_package_manager (Code.fontsource_command fonts)
           ; prose [ Node.text "Then import them in your CSS file:" ]
           ; code (Code.fontsource_css fonts)
           ]
       in
       [ Node.div
           ~attrs:
             [ Attr.class_ "flex items-center justify-between gap-2 border-b px-4 py-3" ]
           [ Loon.Tabs.list
               tabs
               [ Loon.Tabs.trigger ~value:"docs" [ Node.text "Docs" ]
               ; Loon.Tabs.trigger ~value:"prompt" [ Node.text "Prompt" ]
               ]
           ; framework_picker
           ]
       ; Node.div
           ~attrs:
             [ Attr.class_
                 "min-h-0 flex-1 scroll-fade no-scrollbar overflow-y-auto p-4 md:p-6"
             ]
           [ Loon.Tabs.content
               tabs
               ~class_:"flex flex-col gap-6"
               ~value:"docs"
               [ section
                   ~step:1
                   ~title:"Create typeset.css"
                   [ prose
                       [ Node.text "Copy the stylesheet into a "
                       ; mono "typeset.css"
                       ; Node.text " file next to your main CSS file, then import it:"
                       ]
                   ; copy_css
                   ; code "@import \"tailwindcss\";\n@import \"./typeset.css\";"
                   ]
               ; section ~step:2 ~title:"Add the fonts" fonts_step
               ; section
                   ~step:3
                   ~title:"Create your custom typeset"
                   [ code (Code.preset params) ]
               ; section ~step:4 ~title:"Wrap your content" [ code (Code.usage params) ]
               ]
           ; Loon.Tabs.content
               tabs
               ~class_:"flex flex-col gap-2.5"
               ~value:"prompt"
               [ prose
                   [ Node.text
                       "One prompt with your picks baked in. Copy it and paste it into \
                        your coding agent."
                   ]
               ; code
                   ~class_:"max-h-102 scroll-fade overflow-y-auto whitespace-pre-wrap"
                   prompt
               ; copy_prompt
               ]
           ]
       ])
    graph
;;

let panel params (local_ graph) =
  let content = content params graph in
  let%arr content in
  Node.div
    ~attrs:[ Attr.class_ "hidden w-88 flex-col items-start gap-3 xl:flex 2xl:w-104" ]
    [ Node.div
        ~attrs:
          [ Attr.class_
              "isolate flex max-h-[calc(100vh-16rem)] w-full flex-col overflow-hidden \
               rounded-2xl bg-background ring-1 ring-foreground/10"
          ]
        [ content ]
    ; Node.a
        ~attrs:
          [ Attr.href Code.docs_url
          ; Attr.target "_blank"
          ; Attr.create "rel" "noreferrer"
          ; data "slot" "button"
          ; Attr.class_ (Button.classes ~class_:"text-muted-foreground" Link Sm)
          ]
        [ Node.text "Read the docs" ]
    ]
;;
