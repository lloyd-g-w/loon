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

let copy ~text (ev : Dom_html.mouseEvent Js.t) =
  Effect.of_thunk (fun () ->
    write_clipboard text;
    match Js.Opt.to_option ev##.currentTarget with
    | None -> ()
    | Some (el : Dom_html.element Js.t) ->
      el##setAttribute (Js.string "data-copied") (Js.string "");
      el##setAttribute (Js.string "aria-label") (Js.string "Copied");
      ignore
        (Dom_html.window##setTimeout
           (Js.wrap_callback (fun () ->
              el##removeAttribute (Js.string "data-copied");
              el##setAttribute (Js.string "aria-label") (Js.string "Copy code")))
           (Js.number_of_float 2000.)
         : Dom_html.timeout_id))
;;

let copy_button ?(label = "Copy code") text =
  Node.button
    ~attrs:
      [ Attr.type_ "button"
      ; Attr.class_ "docs-copy"
      ; Attr.create "aria-label" label
      ; Attr.title label
      ; Attr.on_click (fun ev -> copy ~text ev)
      ]
    [ Loon.Icon.view ~attrs:[ Attr.class_ "docs-copy-idle" ] Copy
    ; Loon.Icon.view ~attrs:[ Attr.class_ "docs-copy-done" ] Check
    ]
;;

let view ?lang source =
  Node.div
    ~attrs:[ Attr.class_ "docs-codeblock" ]
    [ Node.pre ~attrs:[ Attr.class_ "docs-pre" ] [ Highlight.view ?lang source ]
    ; copy_button source
    ]
;;
