(** shadcn's [preview-02] block (the /create preview "01"): a finance and
    smart-home dashboard of cards. *)

open! Core
open Bonsai_web

val component
  :  Create_preview_01_a.Info.t Bonsai.t
  -> local_ Bonsai.graph
  -> Vdom.Node.t Bonsai.t
