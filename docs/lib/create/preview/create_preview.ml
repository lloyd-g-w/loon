open! Core
open Bonsai_web
open Bonsai.Let_syntax

let items = [ "preview-02", "01"; "preview", "02" ]

let component item (local_ graph) =
  match%sub item with
  | "preview" -> Create_preview_01.component graph
  | _ -> Create_preview_02.component graph
;;
