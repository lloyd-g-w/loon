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
