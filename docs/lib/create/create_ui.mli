(** The chrome of #/create: shadcn draws its customiser with the base-nova
    style ([registry/bases/base/ui/*.tsx] with [styles/style-nova.css]'s
    [cn-*] classes), smaller than new-york-v4; these are those classes,
    resolved, for loon's elements. *)

open! Core
open Bonsai_web

module Variant : sig
  type t =
    | Default
    | Outline
    | Ghost
end

module Size : sig
  type t =
    | Default
    | Sm
    | Lg
    | Icon
    | Icon_sm
end

(** base-nova's [buttonVariants]. *)
val button_classes : ?variant:Variant.t -> ?size:Size.t -> ?class_:string -> unit -> string

(** A [<button type="button" data-slot="button">]. *)
val button
  :  ?attrs:Vdom.Attr.t list
  -> ?class_:string
  -> ?variant:Variant.t
  -> ?size:Size.t
  -> ?disabled:bool
  -> ?on_click:unit Effect.t
  -> Vdom.Node.t list
  -> Vdom.Node.t

(** base-nova's [Card size="sm"] and its parts. *)
val card : ?attrs:Vdom.Attr.t list -> ?class_:string -> Vdom.Node.t list -> Vdom.Node.t

val card_header
  :  ?attrs:Vdom.Attr.t list
  -> ?class_:string
  -> Vdom.Node.t list
  -> Vdom.Node.t

val card_content
  :  ?attrs:Vdom.Attr.t list
  -> ?class_:string
  -> Vdom.Node.t list
  -> Vdom.Node.t

val card_footer
  :  ?attrs:Vdom.Attr.t list
  -> ?class_:string
  -> Vdom.Node.t list
  -> Vdom.Node.t

val field_group
  :  ?attrs:Vdom.Attr.t list
  -> ?class_:string
  -> Vdom.Node.t list
  -> Vdom.Node.t

val field_separator : ?class_:string -> unit -> Vdom.Node.t

(** base-nova's dialog content, for {!Loon.Dialog.content}'s [class_]. *)
val dialog_content_class : string

val dialog_footer_class : string
val dialog_title_class : string
val input_class : string

(** Whether the window is a phone's (shadcn's [useIsMobile]: under 768px);
    [false] outside a browser. *)
val is_mobile : unit -> bool
