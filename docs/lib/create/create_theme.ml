open! Core

type t =
  { name : string
  ; title : string
  ; light : (string * string) list
  ; dark : (string * string) list
  }
[@@deriving sexp_of]
