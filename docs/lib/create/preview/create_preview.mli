(** What #/create previews: ports of shadcn's preview blocks
    ([registry/bases/radix/blocks/preview-02] and [preview]), built from
    loon's components, themed by the CSS variables of the preview root they
    are drawn in. *)

open! Core
open Bonsai_web

(** The preview switcher's items: shadcn's value and label,
    [("preview-02", "01"); ("preview", "02")]. *)
val items : (string * string) list

(** What the [preview] block's overview cards name: the style's title and
    the fonts' names ([font_heading] equal to [font] when it inherits). *)
module Info : sig
  type t = Create_preview_01_a.Info.t =
    { style : string
    ; font : string
    ; font_heading : string
    }

  (** New York, Geist. *)
  val default : t
end

(** The item named [item] (one of [items]; the first for any other); [info]
    is [Info.default] by default. *)
val component
  :  ?info:Info.t Bonsai.t
  -> string Bonsai.t
  -> local_ Bonsai.graph
  -> Vdom.Node.t Bonsai.t
