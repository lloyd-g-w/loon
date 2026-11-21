(** The customisers' menus: a port of shadcn's [picker.tsx] (in [(create)]
    and [(typeset)], over Base UI's Menu) on loon's {!Loon.Menu}. A trigger
    button showing the current value, opening a dark translucent menu of
    radio items with a check on the chosen one; Base UI's radio items stay
    open when chosen ([close_on_select] [false]), and an [on_item_preview]
    on the group hears the item under the pointer or focus. *)

open! Core
open Bonsai_web
module Node = Vdom.Node
module Attr = Vdom.Attr

module State : sig
  type t =
    | Closed
    | Open of Loon.Menu.State.t
  [@@deriving sexp_of, equal]

  val is_open : t -> bool
end

(** The menu's state, for its parts. *)
type t

(** Controlled. [id] (unique on the page) prefixes the parts' ids.
    The menu is not modal: the page stays live while it is open, as Base
    UI's. *)
val view : id:string -> state:State.t -> on_change:(State.t -> unit Effect.t) -> (t -> Node.t list) -> Node.t

(** Keeps the state; [on_open_change] hears it open and close. *)
val component
  :  ?on_open_change:(bool -> unit Effect.t) Bonsai.t
  -> (t -> Node.t list) Bonsai.t
  -> local_ Bonsai.graph
  -> Node.t Bonsai.t

val is_open : t -> bool
val set_open : t -> bool -> unit Effect.t

(** The [<button>] opening it, [data-popup-open] while open. *)
val trigger
  :  ?attrs:Attr.t list
  -> ?class_:string
  -> ?disabled:bool
  -> t
  -> Node.t list
  -> Node.t

(** The menu ([side] [Bottom], [side_offset] 20, [align] [Start] by default).
    [anchor]: the id of the element to place it against (default the
    trigger), as the pickers on a phone use the whole card. *)
val content
  :  ?attrs:Attr.t list
  -> ?class_:string
  -> ?side:Loon.Popper.Side.t
  -> ?side_offset:float
  -> ?align:Loon.Popper.Align.t
  -> ?align_offset:float
  -> ?anchor:string
  -> t
  -> Loon.Menu.Item.t list
  -> Node.t

val group : ?attrs:Attr.t list -> Loon.Menu.Item.t list -> Loon.Menu.Item.t
val label : ?attrs:Attr.t list -> ?class_:string -> ?inset:bool -> Node.t list -> Loon.Menu.Item.t

val item
  :  ?attrs:Attr.t list
  -> ?class_:string
  -> ?disabled:bool
  -> ?text_value:string
  -> ?close_on_select:bool
  -> ?on_select:unit Effect.t
  -> Node.t list
  -> Loon.Menu.Item.t

module Radio_item : sig
  type t
end

(** Radio items ([role="menuitemradio"]): [value] is checked; choosing one
    calls [on_value_change]; [on_item_preview] hears the item the pointer
    moves over or focus reaches. *)
val radio_group
  :  ?attrs:Attr.t list
  -> ?on_item_preview:(string -> unit Effect.t)
  -> value:string
  -> on_value_change:(string -> unit Effect.t)
  -> Radio_item.t list
  -> Loon.Menu.Item.t

val radio_item
  :  ?attrs:Attr.t list
  -> ?class_:string
  -> ?disabled:bool
  -> ?text_value:string
  -> ?close_on_select:bool
  -> value:string
  -> Node.t list
  -> Radio_item.t

val separator : ?attrs:Attr.t list -> ?class_:string -> unit -> Loon.Menu.Item.t
val shortcut : ?attrs:Attr.t list -> ?class_:string -> Node.t list -> Node.t

(** Any node among the items. *)
val node : Node.t -> Loon.Menu.Item.t
