(** Small helpers for writing the preview blocks' cards as their JSX reads. *)

open! Core
open Bonsai_web

(** A card of a preview block. *)
type card = local_ Bonsai.graph -> Vdom.Node.t Bonsai.t

(** A card without state. *)
val static : Vdom.Node.t -> card

val text : string -> Vdom.Node.t

(** An element with [class_] (and the [attrs] after it). *)
val el
  :  string
  -> ?attrs:Vdom.Attr.t list
  -> ?class_:string
  -> Vdom.Node.t list
  -> Vdom.Node.t

val div : ?attrs:Vdom.Attr.t list -> ?class_:string -> Vdom.Node.t list -> Vdom.Node.t
val span : ?attrs:Vdom.Attr.t list -> ?class_:string -> Vdom.Node.t list -> Vdom.Node.t

(** A [<span class>] of text. *)
val tspan : string -> string -> Vdom.Node.t

(** A Lucide icon. *)
val icon : ?class_:string -> Loon.Icon.t -> Vdom.Node.t

(** The cards' close button: [<Button variant="ghost" size="icon-sm"
    className="bg-muted"><XIcon/></Button>]. *)
val close_button : unit -> Vdom.Node.t

(** An [<Empty className="p-4">] of an icon [media] (in the header with
    [media_in_header]), a title, description and a [button]. *)
val empty_card
  :  ?media_in_header:bool
  -> media:Vdom.Node.t
  -> title:string
  -> description:string
  -> button:Vdom.Node.t
  -> unit
  -> Vdom.Node.t

(** An input's [defaultValue]. *)
val default_value : string -> Vdom.Attr.t

(** The id of {!select}'s trigger, for a label's [for]. *)
val select_trigger_id : string -> string

(** A [Select] with [default_value], [id] (its trigger's is
    [select_trigger_id id]) and [class_] (the
    trigger's), and one group of [(value, label)] items. *)
val select
  :  ?class_:string
  -> ?content_class:string
  -> ?placeholder:string
  -> id:string
  -> default_value:string
  -> (string * string) list
  -> local_ Bonsai.graph
  -> Vdom.Node.t Bonsai.t

(** A [Slider]'s state, for a slider the card also reads. *)
val slider_state
  :  float
  -> local_ Bonsai.graph
  -> (float * (float -> unit Effect.t)) Bonsai.t

(** A [DropdownMenu] of plain items (an item [None] is a separator) on a
    [trigger] button. *)
val dropdown
  :  ?align:Loon.Popper.Align.t
  -> ?group:bool
  -> trigger:Vdom.Node.t
  -> string option list
  -> local_ Bonsai.graph
  -> Vdom.Node.t Bonsai.t

(** A fixed-size chart state for tests, else measured. *)
val chart : local_ Bonsai.graph -> Loon.Chart.t Bonsai.t

(** [sprintf "%g"]. *)
val num : float -> string
