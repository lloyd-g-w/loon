(** The home page: shadcn's hero, and its showcase of cards. *)

open! Core
open Bonsai_web

val title : string

(** shadcn's Announcement: the badge above the heading. *)
val announcement : Vdom.Node.t
val view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
