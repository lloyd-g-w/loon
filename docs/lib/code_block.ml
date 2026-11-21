open! Core
open Bonsai_web
open Js_of_ocaml
module Node = Vdom.Node
module Attr = Vdom.Attr

let fallback_copy text =
  let doc = Dom_html.document in
  let area = Dom_html.createTextarea doc in
  area##.value := Js.string text;
  area##setAttribute (Js.string "readonly") (Js.string "");
  area##.style##.position := Js.string "fixed";
  area##.style##.opacity := Js.string "0";
  Dom.appendChild doc##.body area;
  area##select;
  (try ignore (Js.Unsafe.meth_call doc "execCommand" [| Js.Unsafe.inject (Js.string "copy") |] : bool Js.t) with
   | _ -> ());
  Dom.removeChild doc##.body area
;;

let write_clipboard text =
  (* e2e tests read what was copied from here *)
  Js.Unsafe.set Js.Unsafe.global "loonLastCopy" (Js.string text);
  let clipboard = Js.Unsafe.get Js.Unsafe.global##.navigator "clipboard" in
  if Js.Optdef.test clipboard && Js.Opt.test clipboard
  then (
    try
      let promise =
        Js.Unsafe.meth_call clipboard "writeText" [| Js.Unsafe.inject (Js.string text) |]
      in
      ignore
        (Js.Unsafe.meth_call
           promise
           "catch"
           [| Js.Unsafe.inject (Js.wrap_callback (fun _ -> fallback_copy text)) |]
         : Js.Unsafe.any)
    with
    | _ -> fallback_copy text)
  else fallback_copy text
;;

(* Marks the button copied for two seconds, as shadcn's [hasCopied]. *)
let copy ~text (ev : Dom_html.mouseEvent Js.t) =
  Effect.of_thunk (fun () ->
    write_clipboard text;
    match Js.Opt.to_option ev##.currentTarget with
    | None -> ()
    | Some (el : Dom_html.element Js.t) ->
      el##setAttribute (Js.string "data-copied") (Js.string "true");
      ignore
        (Dom_html.window##setTimeout
           (Js.wrap_callback (fun () ->
              el##setAttribute (Js.string "data-copied") (Js.string "false")))
           (Js.number_of_float 2000.)
         : Dom_html.timeout_id))
;;

let copy_icons =
  [ Node.span ~attrs:[ Attr.class_ "sr-only" ] [ Node.text "Copy" ]
  ; Loon.Icon.view ~class_:"group-data-[copied=true]/copy:hidden" Copy
  ; Loon.Icon.view ~class_:"hidden group-data-[copied=true]/copy:block" Check
  ]
;;

(* shadcn's CopyButton. *)
let copy_button ?class_ text =
  Node.button
    ~attrs:
      [ Attr.type_ "button"
      ; Attr.create "data-slot" "copy-button"
      ; Attr.create "data-copied" "false"
      ; Attr.class_
          (Loon.Button.classes
             ~variant:Ghost
             ~size:Icon
             ~class_:
               (Loon.Cn.cn
                  [ "group/copy absolute top-3 right-2 z-10 size-7 bg-code \
                     hover:opacity-100 focus-visible:opacity-100"
                  ; Option.value class_ ~default:""
                  ])
             ())
      ; Attr.on_click (fun ev -> copy ~text ev)
      ]
    copy_icons
;;

let pre_classes =
  "no-scrollbar min-w-0 overflow-x-auto overflow-y-auto overscroll-x-contain \
   overscroll-y-auto px-4 py-3.5 outline-none has-data-highlighted-line:px-0 \
   has-data-line-numbers:px-0 has-data-[slot=tabs]:p-0"
;;

(* A fenced block in shadcn's mdx: rehype-pretty-code's figure. *)
let view ?lang ?(line_numbers = false) ?class_ source =
  Node.create
    "figure"
    ~attrs:
      ([ Attr.create "data-rehype-pretty-code-figure" "" ]
       @ match class_ with
       | None -> []
       | Some c -> [ Attr.class_ c ])
    [ Node.pre
        ~attrs:
          [ Attr.create "data-not-typeset" ""
            (* pr-12: the copy button covers no code (at rest) *)
          ; Attr.class_ (Loon.Cn.cn [ pre_classes; "pr-12" ])
          ]
        [ copy_button source; Highlight.view ?lang ~line_numbers source ]
    ]
;;

(* shadcn's CodeBlockCommand: a command, run one of several ways. *)
let command ~id ~value ~on_change commands =
  let current =
    List.Assoc.find commands value ~equal:String.equal
    |> Option.value ~default:(Option.value_map (List.hd commands) ~default:"" ~f:snd)
  in
  Node.create
    "figure"
    ~attrs:[ Attr.create "data-rehype-pretty-code-figure" "" ]
    [ Node.pre
        ~attrs:[ Attr.create "data-not-typeset" ""; Attr.class_ pre_classes ]
        [ Node.div
            ~attrs:[ Attr.class_ "overflow-x-auto" ]
            [ Loon.Tabs.view
                ~id
                ~value
                ~on_change
                ~class_:"gap-0"
                (fun tabs ->
                   [ Node.div
                       ~attrs:
                         [ Attr.class_
                             "flex items-center gap-2 border-b border-border/50 px-3 py-1"
                         ]
                       [ Node.div
                           ~attrs:
                             [ Attr.class_
                                 "flex size-4 items-center justify-center rounded-[1px] \
                                  bg-foreground opacity-70"
                             ]
                           [ Loon.Icon.view ~class_:"size-3 text-code" Terminal ]
                       ; Loon.Tabs.list
                           ~class_:"rounded-none bg-transparent p-0"
                           tabs
                           (List.map commands ~f:(fun (key, _) ->
                              Loon.Tabs.trigger
                                ~class_:
                                  "h-7 border border-transparent pt-0.5 shadow-none! \
                                   data-[state=active]:border-input \
                                   data-[state=active]:bg-background!"
                                ~value:key
                                [ Node.text key ]))
                       ]
                   ; Node.div
                       ~attrs:[ Attr.class_ "no-scrollbar overflow-x-auto" ]
                       (List.map commands ~f:(fun (key, command) ->
                          Loon.Tabs.content
                            ~class_:"mt-0 px-4 py-3.5"
                            tabs
                            ~value:key
                            [ Node.pre
                                [ Node.code
                                    ~attrs:
                                      [ Attr.class_ "relative font-mono text-sm leading-none"
                                      ; Attr.create "data-language" "bash"
                                      ]
                                    [ Node.text command ]
                                ]
                            ]))
                   ])
            ; Node.button
                ~attrs:
                  [ Attr.type_ "button"
                  ; Attr.create "data-slot" "copy-button"
                  ; Attr.create "data-copied" "false"
                  ; Attr.class_
                      (Loon.Button.classes
                         ~variant:Ghost
                         ~size:Icon
                         ~class_:
                           "group/copy absolute top-2 right-2 z-10 size-7 opacity-70 \
                            hover:opacity-100 focus-visible:opacity-100"
                         ())
                  ; Attr.on_click (fun ev -> copy ~text:current ev)
                  ]
                copy_icons
            ]
        ]
    ]
;;
