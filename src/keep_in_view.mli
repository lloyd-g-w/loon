(** Keeps floating content on screen: when it is placed beside its trigger
    but would stick out of the viewport, it moves below it; when it would go
    off the bottom and fits above, it moves above; and it shifts sideways to
    stay within the viewport's edges. Measured once, when it appears. *)

open! Import

val attr : Attr.t
