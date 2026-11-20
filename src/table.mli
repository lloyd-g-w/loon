(** Tables of data: the parts of a table, styled, and [view] building one
    from columns and rows. For sorting, filtering and selection, see
    [Data_table]. *)

open! Import

module Align : sig
  type t =
    | Left
    | Center
    | Right
  [@@deriving enumerate, sexp_of, compare, equal]

  val attr : t -> Attr.t
end

(** The parts, for tables of any shape. [table] scrolls sideways in its own
    box when it is too wide for the page. *)

val table
  :  ?attrs:Attr.t list
  -> ?striped:bool
  -> ?hover:bool
  -> ?dense:bool
  -> ?caption:string
  -> Node.t list
  -> Node.t

val header : ?attrs:Attr.t list -> Node.t list -> Node.t
val body : ?attrs:Attr.t list -> Node.t list -> Node.t
val footer : ?attrs:Attr.t list -> Node.t list -> Node.t
val row : ?attrs:Attr.t list -> ?key:string -> ?selected:bool -> Node.t list -> Node.t
val head : ?attrs:Attr.t list -> ?align:Align.t -> Node.t list -> Node.t
val cell : ?attrs:Attr.t list -> ?align:Align.t -> ?colspan:int -> Node.t list -> Node.t

module Column : sig
  type 'row t =
    { header : string
    ; align : Align.t
    ; cell : 'row -> Node.t
    }

  val create : ?align:Align.t -> string -> ('row -> Node.t) -> 'row t

  (** A column of text. *)
  val text : ?align:Align.t -> string -> ('row -> string) -> 'row t
end

(** A whole table: a header row from [columns], a row per element of
    [rows], and an optional [footer] row (its cells as given). *)
val view
  :  ?attrs:Attr.t list
  -> ?striped:bool
  -> ?hover:bool
  -> ?dense:bool
  -> ?caption:string
  -> ?footer:Node.t list
  -> columns:'row Column.t list
  -> 'row list
  -> Node.t
