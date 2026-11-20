(** A table that the user can sort (by pressing a column's header), filter
    (with a search box) and select rows of, optionally paginated. The state
    is kept in Bonsai. *)

open! Import

module Direction : sig
  type t =
    | Ascending
    | Descending
  [@@deriving sexp_of, compare, equal]
end

module Column : sig
  type 'row t =
    { id : string
    ; header : string
    ; align : Table.Align.t
    ; cell : 'row -> Node.t
    ; sort : ('row -> 'row -> int) option (** [Some]: sortable *)
    ; search : ('row -> string) option (** [Some]: the filter matches it *)
    }

  val create
    :  ?align:Table.Align.t
    -> ?sort:('row -> 'row -> int)
    -> ?search:('row -> string)
    -> id:string
    -> string
    -> ('row -> Node.t)
    -> 'row t

  (** A column of text, sorted by it and searched. *)
  val text
    :  ?align:Table.Align.t
    -> id:string
    -> string
    -> ('row -> string)
    -> 'row t
end

(** The rows the filter matches (case-insensitively, any searchable
    column), sorted by [sort]. *)
val visible_rows
  :  columns:'row Column.t list
  -> filter:string
  -> sort:(string * Direction.t) option
  -> 'row list
  -> 'row list

type t =
  { view : Node.t
  ; selected : String.Set.t (** the selected rows' keys *)
  }

(** [key] names a row (stably, for selection). Pressing a sortable header
    sorts by it ascending, then descending, then not. [selectable] adds a
    checkbox column (and one in the header for every visible row).
    [page_size] paginates. [empty] shows when no row matches. *)
val component
  :  ?attrs:Attr.t list
  -> ?striped:bool
  -> ?dense:bool
  -> ?caption:string
  -> ?filter_placeholder:string
  -> ?selectable:bool
  -> ?page_size:int
  -> ?empty:Node.t
  -> ?toolbar:Node.t list
  -> columns:'row Column.t list Bonsai.t
  -> key:('row -> string)
  -> 'row list Bonsai.t
  -> local_ Bonsai.graph
  -> t Bonsai.t
