(** Where a page is in a hierarchy: links to its ancestors, then the page.
    Long trails collapse their middle into "…". *)

open! Import

module Item : sig
  type t =
    { label : string
    ; href : string option (** [None]: not a link (the current page, last) *)
    ; on_click : unit Effect.t option
    }

  val create : ?href:string -> ?on_click:unit Effect.t -> string -> t
end

(** Past [max_items] items, the first and the last [max_items - 2] show,
    with an ellipsis between. [separator] defaults to a chevron. *)
val view
  :  ?attrs:Attr.t list
  -> ?max_items:int
  -> ?separator:Node.t
  -> Item.t list
  -> Node.t
