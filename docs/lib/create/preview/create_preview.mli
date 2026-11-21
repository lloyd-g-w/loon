(** What #/create previews: ports of shadcn's preview blocks
    ([registry/bases/radix/blocks/preview-02] and [preview]), built from
    loon's components, themed by the CSS variables of the preview root they
    are drawn in. *)

open! Core
open Bonsai_web

(** The preview switcher's items: shadcn's value and label,
    [("preview-02", "01"); ("preview", "02")]. *)
val items : (string * string) list

(** The item named [item] (one of [items]; the first for any other). *)
val component : string Bonsai.t -> local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
