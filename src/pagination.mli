(** Links to the pages of a long list: previous, the pages around the
    current one (with ellipses for the rest), next. Pages count from 1. *)

open! Import

module Entry : sig
  type t =
    | Page of int
    | Ellipsis
  [@@deriving sexp_of, compare, equal]
end

(** The entries shown for [page] of [pages]: always the first and last,
    [siblings] (default 1) either side of [page], and ellipses for gaps of
    more than one page; the count stays the same as [page] moves. *)
val entries : ?siblings:int -> page:int -> pages:int -> unit -> Entry.t list

(** Controlled. [compact] shows "Page 3 of 10" in place of the numbers. *)
val view
  :  ?attrs:Attr.t list
  -> ?siblings:int
  -> ?compact:bool
  -> page:int
  -> pages:int
  -> on_change:(int -> unit Effect.t)
  -> unit
  -> Node.t

type t =
  { page : int
  ; view : Node.t
  }

(** Keeps the page ([default] 1, clamped as [pages] changes). *)
val component
  :  ?attrs:Attr.t list
  -> ?siblings:int
  -> ?compact:bool
  -> ?default:int
  -> pages:int Bonsai.t
  -> local_ Bonsai.graph
  -> t Bonsai.t
