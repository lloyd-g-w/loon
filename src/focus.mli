(** Moving focus within a part of the page (keeping it inside a modal). *)

open! Import

(** The first, or last, focusable element inside the element with id [id]. *)
val first_in : string -> unit Effect.t

val last_in : string -> unit Effect.t

(** An invisible focusable element that, when focused (by Tab leaving the
    modal at one end), sends focus to the other end of the element [id]. *)
val guard : id:string -> [ `Start | `End ] -> Node.t

(** Focuses the element when it is added to the page (an overlay's content
    that just opened), without scrolling: its item with [data-highlighted]
    if it has one, else the first element inside matching the selector
    ([`Selector]), else the first focusable element inside
    ([`First_tabbable]), else the element itself; [`Keep] leaves the focus
    where it is (Radix's prevented [onOpenAutoFocus]). When it leaves the page
    with the focus, the focus goes back to the element that had it before
    (Radix's FocusScope). *)
val on_mount : [ `First_tabbable | `Keep | `Self | `Selector of string ] -> Attr.t

(** Focuses the element with id [id], without scrolling, after the next
    render, unless an open dialog not containing it has taken focus meanwhile
    (a dialog a menu item opened). *)
val restore : string -> unit Effect.t

(** Focuses the element whenever [focused] becomes true (an item highlighted
    from the keyboard). *)
val when_ : bool -> Attr.t
