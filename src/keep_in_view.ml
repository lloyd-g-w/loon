open! Import
open Js_of_ocaml

let margin = 8.

let adjust (el : Dom_html.element Js.t) =
  let vw = Float.of_int Dom_html.window##.innerWidth in
  let vh = Float.of_int Dom_html.window##.innerHeight in
  let rect () = el##getBoundingClientRect in
  let side () =
    Js.Opt.case
      (el##getAttribute (Js.string "data-side"))
      (fun () -> "")
      Js.to_string
  in
  let set name value = el##setAttribute (Js.string name) (Js.string value) in
  let r = rect () in
  if
    (String.equal (side ()) "left" || String.equal (side ()) "right")
    && Float.(
         Js.to_float r##.left < margin || Js.to_float r##.right > vw - margin)
  then (
    set "data-side" "bottom";
    set "data-align" "start");
  let r = rect () in
  if
    String.equal (side ()) "bottom"
    && Float.(Js.to_float r##.bottom > vh - margin)
  then
    Js.Opt.iter el##.parentNode (fun parent ->
      Js.Opt.iter (Dom_html.CoerceTo.element parent) (fun parent ->
        let p = parent##getBoundingClientRect in
        let height = Js.to_float r##.bottom -. Js.to_float r##.top in
        if Float.(Js.to_float p##.top -. height -. margin > 0.)
        then set "data-side" "top"));
  let r = rect () in
  let shift =
    if Float.(Js.to_float r##.right > vw - margin)
    then vw -. margin -. Js.to_float r##.right
    else if Float.(Js.to_float r##.left < margin)
    then margin -. Js.to_float r##.left
    else 0.
  in
  let shift =
    if Float.(Js.to_float r##.left +. shift < margin)
    then margin -. Js.to_float r##.left
    else shift
  in
  if Float.(abs shift > 0.5)
  then el##.style##.marginLeft := Js.string (sprintf "%.0fpx" shift)
;;

module Hook = Vdom.Attr.Hooks.Make (struct
    module State = Unit

    module Input = struct
      include Unit

      let combine () () = ()
    end

    let init () _ = ()

    let on_mount =
      `Schedule_immediately_after_this_dom_patch_completes
        (fun () () el -> adjust el)
    ;;

    let update ~old_input:() ~new_input:() () _ = ()
    let destroy () () _ = ()
  end)

let attr = Vdom.Attr.create_hook "loon-keep-in-view" (Hook.create ())
