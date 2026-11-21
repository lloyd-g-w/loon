(** The docs' #/create page: a port of ui.shadcn.com's /create. *)

open! Core
open Bonsai_web

(** [query] is the hash's query (after the [?]), where the page keeps its
    state; [set_query] replaces it (no history entry). [mode] is the site's
    light or dark mode, which the page's mode switcher sets. *)
val component
  :  mode:Loon.Theme.Mode.t Bonsai.t
  -> set_mode:(Loon.Theme.Mode.t -> unit Effect.t) Bonsai.t
  -> query:string Bonsai.t
  -> set_query:(string -> unit Effect.t) Bonsai.t
  -> local_ Bonsai.graph
  -> Vdom.Node.t Bonsai.t

(** The site header's actions on this page (shadcn's [DesignerActions]):
    Get Code, for the preset in [query]. *)
val header_actions : query:string Bonsai.t -> local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
