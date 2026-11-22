open! Import
open Js_of_ocaml

module Align = struct
  type t =
    | Inline_start
    | Inline_end
    | Block_start
    | Block_end
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Inline_start -> "inline-start"
    | Inline_end -> "inline-end"
    | Block_start -> "block-start"
    | Block_end -> "block-end"
  ;;

  let classes = function
    | Inline_start ->
      "cn-input-group-addon-align-inline-start order-first"
    | Inline_end -> "cn-input-group-addon-align-inline-end order-last"
    | Block_start ->
      "cn-input-group-addon-align-block-start order-first w-full justify-start"
    | Block_end ->
      "cn-input-group-addon-align-block-end order-last w-full justify-start"
  ;;
end

module Button_size = struct
  type t =
    | Xs
    | Sm
    | Icon_xs
    | Icon_sm
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Xs -> "xs"
    | Sm -> "sm"
    | Icon_xs -> "icon-xs"
    | Icon_sm -> "icon-sm"
  ;;

  let classes = function
    | Xs ->
      "cn-input-group-button-size-xs"
    | Sm -> "cn-input-group-button-size-sm"
    | Icon_xs -> "cn-input-group-button-size-icon-xs"
    | Icon_sm -> "cn-input-group-button-size-icon-sm"
  ;;
end

let root ?(attrs = []) ?class_ ?(disabled = false) children =
  Node.div
    ~attrs:
      ([ data "slot" "input-group"
       ; Attr.role "group"
       ; Cn.with_class
           ?class_
           [ "group/input-group cn-input-group relative flex w-full min-w-0 items-center \
              outline-none has-[>textarea]:h-auto"
           ]
       ]
       @ (if disabled then [ data "disabled" "true" ] else [])
       @ attrs)
    children
;;

let focus_input (ev : Dom_html.mouseEvent Js.t) =
  Effect.of_thunk (fun () ->
    let target : Dom_html.element Js.t = Js.Unsafe.get ev "target" in
    let current : Dom_html.element Js.t = Js.Unsafe.get ev "currentTarget" in
    let in_button =
      Js.Opt.test
        (Js.Unsafe.meth_call target "closest" [| Js.Unsafe.inject (Js.string "button") |]
         : Dom_html.element Js.t Js.Opt.t)
    in
    if not in_button
    then
      Js.Opt.iter current##.parentNode (fun parent ->
        let parent : Dom_html.element Js.t = Js.Unsafe.coerce parent in
        Js.Opt.iter (parent##querySelector (Js.string "input")) (fun input -> input##focus)))
;;

let addon ?(attrs = []) ?class_ ?(align = Align.Inline_start) children =
  Node.div
    ~attrs:
      ([ Attr.role "group"
       ; data "slot" "input-group-addon"
       ; data "align" (Align.name align)
       ; Cn.with_class
           ?class_
           [ "cn-input-group-addon flex cursor-text items-center justify-center \
              select-none"
           ; Align.classes align
           ]
       ; Attr.on_click focus_input
       ]
       @ attrs)
    children
;;

let button
  ?(attrs = [])
  ?class_
  ?(variant = Button.Variant.Ghost)
  ?(size = Button_size.Xs)
  ?disabled
  ?type_
  ?on_click
  children
  =
  Button.view
    ~attrs:(Attr.suppress_merge_warnings (data "size" (Button_size.name size)) :: attrs)
    ~class_:
      (Cn.cn
         ([ "cn-input-group-button flex items-center shadow-none"; Button_size.classes size ]
          @ Option.to_list class_))
    ~variant
    ?disabled
    ?type_
    ?on_click
    children
;;

let text ?(attrs = []) ?class_ children =
  Node.span
    ~attrs:
      (Cn.with_class
         ?class_
         [ "cn-input-group-text flex items-center [&_svg]:pointer-events-none"
         ]
       :: attrs)
    children
;;

let control_slot = Attr.suppress_merge_warnings (data "slot" "input-group-control")

let input
  ?(attrs = [])
  ?class_
  ?type_
  ?id
  ?name
  ?placeholder
  ?disabled
  ?required
  ?invalid
  ?value
  ?on_input
  ()
  =
  Input.view
    ~attrs:(control_slot :: attrs)
    ~class_:
      (Cn.cn
         ([ "cn-input-group-input flex-1"
          ]
          @ Option.to_list class_))
    ?type_
    ?id
    ?name
    ?placeholder
    ?disabled
    ?required
    ?invalid
    ?value
    ?on_input
    ()
;;

let textarea
  ?(attrs = [])
  ?class_
  ?id
  ?name
  ?placeholder
  ?rows
  ?disabled
  ?required
  ?invalid
  ?value
  ?on_input
  ()
  =
  Textarea.view
    ~attrs:(control_slot :: attrs)
    ~class_:
      (Cn.cn
         ([ "cn-input-group-textarea flex-1 resize-none"
          ]
          @ Option.to_list class_))
    ?id
    ?name
    ?placeholder
    ?rows
    ?disabled
    ?required
    ?invalid
    ?value
    ?on_input
    ()
;;
