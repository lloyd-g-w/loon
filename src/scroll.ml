open! Import
open Js_of_ocaml

let scroll selector =
  match
    Js.Opt.to_option (Dom_html.document##querySelector (Js.string selector))
  with
  | None -> ()
  | Some el ->
    (Js.Unsafe.coerce el)##scrollIntoView
      object%js
        val block = Js.string "nearest"
      end
;;

let into_view selector =
  Effect.of_thunk (fun () ->
    if Js.Optdef.test (Js.Unsafe.global##.document : _ Js.Optdef.t)
    then (
      let (_ : Dom_html.animation_frame_request_id) =
        Dom_html.window##requestAnimationFrame
          (Js.wrap_callback (fun (_ : Js.number_t) -> scroll selector))
      in
      ()))
;;

let locks = ref 0

(* As react-remove-scroll-bar (Radix's RemoveScroll): the body hides its
   overflow and takes the page scrollbar's width as a right margin, so that
   nothing moves when the scrollbar goes. *)
let lock_style_id = "loon-scroll-lock"

let lock_css ~left ~top ~right ~gap =
  sprintf
    {|body[data-scroll-locked]{overflow:hidden !important;overscroll-behavior:contain;position:relative !important;padding-left:%dpx;padding-top:%dpx;padding-right:%dpx;margin-left:0;margin-top:0;margin-right:%dpx !important;--removed-body-scroll-bar-size:%dpx}.right-scroll-bar-position{right:%dpx !important}.width-before-scroll-bar{margin-right:%dpx !important}.right-scroll-bar-position .right-scroll-bar-position{right:0 !important}.width-before-scroll-bar .width-before-scroll-bar{margin-right:0 !important}|}
    left
    top
    right
    gap
    gap
    gap
    gap
;;

let px_of s =
  match Float.of_string_opt (String.chop_suffix_if_exists s ~suffix:"px") with
  | Some f -> Float.to_int f
  | None -> 0
;;

let add_lock () =
  let doc = Dom_html.document in
  let body = doc##.body in
  if !locks = 0
  then (
    let cs = Dom_html.window##getComputedStyle body in
    let left = px_of (Js.to_string cs##.marginLeft) in
    let top = px_of (Js.to_string cs##.marginTop) in
    let right = px_of (Js.to_string cs##.marginRight) in
    let window_width = Dom_html.window##.innerWidth in
    let gap = Int.max 0 (window_width - doc##.documentElement##.clientWidth + right - left) in
    let style = Dom_html.createStyle doc in
    style##.id := Js.string lock_style_id;
    Dom.appendChild style (doc##createTextNode (Js.string (lock_css ~left ~top ~right ~gap)));
    Dom.appendChild doc##.head style);
  incr locks;
  body##setAttribute (Js.string "data-scroll-locked") (Js.string (Int.to_string !locks))
;;

let remove_lock () =
  let doc = Dom_html.document in
  decr locks;
  if !locks <= 0
  then (
    locks := 0;
    doc##.body##removeAttribute (Js.string "data-scroll-locked");
    Js.Opt.iter (doc##getElementById (Js.string lock_style_id)) (fun el ->
      Js.Opt.iter el##.parentNode (fun p -> Dom.removeChild p el)))
  else
    doc##.body##setAttribute
      (Js.string "data-scroll-locked")
      (Js.string (Int.to_string !locks))
;;

module Lock_hook = Vdom.Attr.Hooks.Make (struct
    module State = Unit

    module Input = struct
      type t = unit [@@deriving sexp_of]

      let combine () () = ()
    end

    let init () _ = add_lock ()
    let on_mount = `Do_nothing
    let update ~old_input:() ~new_input:() () _ = ()
    let destroy () () _ = remove_lock ()
  end)

let lock = Vdom.Attr.create_hook "loon-scroll-lock" (Lock_hook.create ())
