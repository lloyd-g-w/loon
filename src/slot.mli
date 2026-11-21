(** Radix's [asChild]: a part's attributes put on the caller's element (a
    [Button.view], an [<a>]) instead of an element of its own. *)

open! Import

(** [merge ~defaults attrs node]: [node] with [attrs] added (classes and
    styles merge, handlers for the same event both run), and each of
    [defaults] (attribute name, attribute) unless [node] has that attribute
    already: as Radix's Slot, the child's own [data-slot] or [type] wins. A
    node that is not an element (text, a fragment) is wrapped in a [<span>]. *)
val merge : ?defaults:(string * Attr.t) list -> Attr.t list -> Node.t -> Node.t
