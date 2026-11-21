(** dashboard-01's [data.json]: the data table's rows. *)

open! Core

type t =
  { id : int
  ; header : string
  ; type_ : string
  ; status : string
  ; target : string
  ; limit : string
  ; reviewer : string
  }
[@@deriving sexp_of, equal]

val all : t list
