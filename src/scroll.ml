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
let saved_overflow = ref ""

module Lock_hook = Vdom.Attr.Hooks.Make (struct
    module State = Unit

    module Input = struct
      type t = unit [@@deriving sexp_of]

      let combine () () = ()
    end

    let body () = Dom_html.document##.body

    let init () _ =
      if !locks = 0
      then (
        saved_overflow := Js.to_string (body ())##.style##.overflow;
        (body ())##.style##.overflow := Js.string "hidden");
      incr locks
    ;;

    let on_mount = `Do_nothing
    let update ~old_input:() ~new_input:() () _ = ()

    let destroy () () _ =
      decr locks;
      if !locks = 0 then (body ())##.style##.overflow := Js.string !saved_overflow
    ;;
  end)

let lock = Vdom.Attr.create_hook "loon-scroll-lock" (Lock_hook.create ())
