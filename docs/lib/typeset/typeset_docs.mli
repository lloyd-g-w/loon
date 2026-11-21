(** Typeset's install steps for the chosen params: a port of shadcn's
    [(typeset)/components/docs-panel.tsx] (the panel beside the preview on
    wide screens, and the content of the "Get Code" drawer). *)

open! Core
open Bonsai_web

(** Writes [text] to the clipboard. *)
val copy_to_clipboard : string -> unit Effect.t

(** The Docs and Prompt tabs, with the framework picker. [copy] (default
    {!copy_to_clipboard}) is what the copy buttons call. *)
val content
  :  ?copy:(string -> unit Effect.t)
  -> Typeset_params.t Bonsai.t
  -> local_ Bonsai.graph
  -> Vdom.Node.t Bonsai.t

(** The panel: {!content} in a card, and a link to shadcn's Typeset docs;
    shown from Tailwind's [xl]. *)
val panel : Typeset_params.t Bonsai.t -> local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
