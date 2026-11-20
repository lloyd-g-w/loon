open! Import
open Js_of_ocaml

let css = Stylesheet_contents.css

let install () =
  let id = Js.string "loon-stylesheet" in
  if Js.Opt.test (Dom_html.document##getElementById id)
  then ()
  else (
    let style = Dom_html.createStyle Dom_html.document in
    style##.id := id;
    style##.textContent := Js.some (Js.string css);
    Dom.appendChild Dom_html.document##.head style)
;;
