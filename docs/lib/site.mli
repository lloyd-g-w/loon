(** Pieces of ui.shadcn.com's site shared by the docs' pages. *)

open! Core
open Bonsai_web

val github : string

(** An [<svg>] hidden from assistive technology. *)
val svg
  :  ?attrs:Vdom.Attr.t list
  -> view_box:string
  -> Vdom.Node.t list
  -> Vdom.Node.t

val path : ?attrs:Vdom.Attr.t list -> string -> Vdom.Node.t

(** shadcn's [Icons.gitHub]: the filled mark. *)
val github_icon : unit -> Vdom.Node.t

(** loon's bird, in the colour of the text. *)
val logo : ?class_:string -> unit -> Vdom.Node.t

(** shadcn's PageHeader, PageHeaderHeading, PageHeaderDescription and
    PageActions; [before] goes above the heading (the announcement). *)
val page_header
  :  ?class_:string
  -> ?before:Vdom.Node.t list
  -> title:string
  -> description:Vdom.Node.t list
  -> ?actions:Vdom.Node.t list
  -> unit
  -> Vdom.Node.t
