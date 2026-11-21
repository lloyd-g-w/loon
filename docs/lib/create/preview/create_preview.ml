open! Core
open Bonsai_web
open Bonsai.Let_syntax

let items = [ "preview-02", "01"; "preview", "02" ]

let component item (local_ _graph) =
  let%arr item in
  Vdom.Node.div
    ~attrs:[ Vdom.Attr.class_ "p-6 text-sm text-muted-foreground" ]
    [ Vdom.Node.text ("Preview: " ^ item) ]
;;
