(** Typeset's state: a port of shadcn's [(typeset)/lib/search-params.ts]
    (and its fixtures' [CONTENT_OPTIONS]). Each param takes one of a fixed
    set of values; in the query an absent or unknown value is the default,
    and a default value is left out. *)

open! Core

module Key : sig
  type t =
    | Body
    | Heading
    | Mono
    | Scale
    | Measure
    | Flow
    | Leading
    | Item
  [@@deriving enumerate, sexp_of, compare, equal]

  (** The query's name: ["body"], ..., ["item"]. *)
  val name : t -> string
end

module Option_ : sig
  type t =
    { value : string
    ; label : string
    }
end

val sizes : Option_.t list
val leadings : Option_.t list
val flows : Option_.t list

(** With their widths: [("60", "60ch", "28em")]. *)
val measures : (Option_.t * string) list

(** The fixtures the toolbar offers. *)
val content_options : Option_.t list

(** The CSS width of a measure (["37em"] for ["80"]). *)
val measure_width : string -> string option

type t =
  { body : string
  ; heading : string (** ["inherit"]: the body's font *)
  ; mono : string
  ; scale : string
  ; measure : string
  ; flow : string
  ; leading : string
  ; item : string
  }
[@@deriving sexp_of, equal]

val default : t
val get : t -> Key.t -> string
val set : t -> Key.t -> string -> t

(** The values [key] accepts. *)
val values : Key.t -> string list

(** [Some value] if [key] accepts it (shadcn's [coerceTypesetValue]). *)
val coerce : Key.t -> string -> string option

(** Each key from the query, its default when absent or invalid. *)
val of_query : string -> t

(** The non-default params, in {!Key.all}'s order. *)
val to_query : t -> string

(** Params to apply over others, as a hover preview or a shuffle does. *)
val apply : t -> (Key.t * string) list -> t
